# Phase 5 Test Report: Zero-Docker Packaging

Status:
Cycle 0 through Cycle 4 complete for the local macOS ARM64 validation target.

## Cycle 0: Deployment Baseline

Decision:

```text
Use `dart build cli`, not `dart compile exe`, because the SQLite packages use native-assets build hooks.
```

Validation:

```sh
cd pocketpod_server
dart compile exe bin/main.dart -o build/pocketpod_server_test
dart build cli --target bin/main.dart --output build/phase5_probe
```

Result:

```text
PASS
dart compile exe failed as expected with:
'dart compile' does not support build hooks, use 'dart build' instead.

dart build cli succeeded and generated:
build/phase5_probe/bundle/bin/main
build/phase5_probe/bundle/lib/libsqlite3.dylib
build/phase5_probe/bundle/lib/libsqlite3_connection_pool.dylib
```

## Cycle 1: Build Artifact Script

Validation:

```sh
tool/deploy/build_release.sh
```

Expected artifact:

```text
build/pocketpod-release/bin/main
build/pocketpod-release/lib/
build/pocketpod-release/config/
build/pocketpod-release/migrations/
build/pocketpod-release/web/app/
build/pocketpod-release/.serverpod/production/
```

Result:

```text
PASS
The script builds the Flutter admin app, builds the Serverpod CLI bundle, and assembles the release directory.
```

## Cycle 2: SQLite Runtime Layout

Validation:

```sh
test -d build/pocketpod-release/.serverpod/production
rg -n "filePath: .serverpod/production/database.sqlite" build/pocketpod-release/config/production.yaml
```

Result:

```text
PASS
The production SQLite runtime directory and production database path are present in the release artifact.
```

## Cycle 3: Smoke Test Script

Validation:

```sh
tool/deploy/smoke_release.sh
```

Result:

```text
PASS
The compiled release binary starts in Serverpod development mode on alternate smoke ports, applies migrations, serves /app/, serves /app/assets/assets/config.json, creates .serverpod/smoke/database.sqlite, and then stops cleanly.
```

## Cycle 4: VPS Deployment Docs

Validation:

```sh
test -f tool/deploy/README.md
test -f tool/deploy/TASKS.md
test -f tool/deploy/TEST_REPORT.md
```

Result:

```text
PASS
Phase 5 deployment tooling and validation docs are present.
```
