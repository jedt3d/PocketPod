#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARTER_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
RELEASE_DIR="${1:-$STARTER_DIR/build/pocketpod-release}"
API_PORT="${POCKETPOD_SMOKE_API_PORT:-18080}"
INSIGHTS_PORT="${POCKETPOD_SMOKE_INSIGHTS_PORT:-18081}"
WEB_PORT="${POCKETPOD_SMOKE_WEB_PORT:-18082}"
LOG_FILE="$RELEASE_DIR/logs/smoke.log"
PID_FILE="$RELEASE_DIR/logs/smoke.pid"

if [[ ! -x "$RELEASE_DIR/bin/main" ]]; then
  echo "Missing release executable: $RELEASE_DIR/bin/main" >&2
  echo "Run tool/deploy/build_release.sh first." >&2
  exit 1
fi

if command -v lsof >/dev/null 2>&1; then
  for port in "$API_PORT" "$INSIGHTS_PORT" "$WEB_PORT"; do
    if lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
      echo "Port $port is already in use. Set POCKETPOD_SMOKE_*_PORT or stop the existing process." >&2
      exit 1
    fi
  done
fi

mkdir -p "$RELEASE_DIR/config" "$RELEASE_DIR/.serverpod/smoke" "$RELEASE_DIR/logs"

cat > "$RELEASE_DIR/config/development.yaml" <<YAML
apiServer:
  port: $API_PORT
  publicHost: localhost
  publicPort: $API_PORT
  publicScheme: http

insightsServer:
  port: $INSIGHTS_PORT
  publicHost: localhost
  publicPort: $INSIGHTS_PORT
  publicScheme: http

webServer:
  port: $WEB_PORT
  publicHost: localhost
  publicPort: $WEB_PORT
  publicScheme: http

database:
  filePath: .serverpod/smoke/database.sqlite
  maxConnectionCount: 5

maxRequestSize: 524288

sessionLogs:
  persistentEnabled: false
  consoleEnabled: true
  consoleLogFormat: json
YAML

cat > "$RELEASE_DIR/config/passwords.yaml" <<'YAML'
shared:
  mySharedPassword: 'smoke-shared-password'
  emailSecretHashPepper: 'smoke-email-pepper'
  jwtHmacSha512PrivateKey: 'smoke-jwt-private-key'
  jwtRefreshTokenHashPepper: 'smoke-refresh-pepper'

development:
  database: 'smoke-database-password'
  redis: 'smoke-redis-password'
  serviceSecret: 'smoke-service-secret'
  emailSecretHashPepper: 'smoke-email-pepper'
  jwtHmacSha512PrivateKey: 'smoke-jwt-private-key'
  jwtRefreshTokenHashPepper: 'smoke-refresh-pepper'
YAML

cleanup() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid="$(cat "$PID_FILE")"
    if kill -0 "$pid" >/dev/null 2>&1; then
      kill "$pid" >/dev/null 2>&1 || true
      wait "$pid" >/dev/null 2>&1 || true
    fi
    rm -f "$PID_FILE"
  fi
}
trap cleanup EXIT

rm -f "$LOG_FILE"

(
  cd "$RELEASE_DIR"
  DYLD_LIBRARY_PATH="$RELEASE_DIR/lib:${DYLD_LIBRARY_PATH:-}" \
  LD_LIBRARY_PATH="$RELEASE_DIR/lib:${LD_LIBRARY_PATH:-}" \
    ./bin/main --mode development --apply-migrations > "$LOG_FILE" 2>&1
) &
echo "$!" > "$PID_FILE"

for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:$WEB_PORT/app/" >/tmp/pocketpod-smoke-app.html 2>/dev/null; then
    break
  fi

  if ! kill -0 "$(cat "$PID_FILE")" >/dev/null 2>&1; then
    echo "PocketPod release server exited before /app/ became ready." >&2
    cat "$LOG_FILE" >&2 || true
    exit 1
  fi

  sleep 1
done

curl -fsS "http://127.0.0.1:$WEB_PORT/app/" >/tmp/pocketpod-smoke-app.html
curl -fsS "http://127.0.0.1:$WEB_PORT/app/assets/assets/config.json" >/tmp/pocketpod-smoke-config.json

if [[ ! -f "$RELEASE_DIR/.serverpod/smoke/database.sqlite" ]]; then
  echo "Smoke SQLite database was not created." >&2
  cat "$LOG_FILE" >&2 || true
  exit 1
fi

echo "PASS: release smoke test"
echo "Admin app: http://127.0.0.1:$WEB_PORT/app/"
echo "API config: http://127.0.0.1:$WEB_PORT/app/assets/assets/config.json"
echo "SQLite: $RELEASE_DIR/.serverpod/smoke/database.sqlite"
