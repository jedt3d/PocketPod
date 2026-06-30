#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ADMIN_UI_DIR="$ROOT_DIR/admin_ui"
OUTPUT_DIR="$ROOT_DIR/pocketpod_server/web/app"
API_URL="${POCKETPOD_API_URL:-http://localhost:8080/}"

rm -rf "$OUTPUT_DIR"

(
  cd "$ADMIN_UI_DIR"
  flutter build web \
    --base-href /app/ \
    --dart-define "POCKETPOD_API_URL=$API_URL" \
    -o "$OUTPUT_DIR"
)

echo "Built PocketPod Flutter admin to $OUTPUT_DIR"
echo "API URL: $API_URL"
