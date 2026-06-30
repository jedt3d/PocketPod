# PocketPod

PocketPod is a Serverpod + SQLite starter structure for a small single-server e-commerce/CMS backend.

It is not a new backend server. The backend is still Serverpod. PocketPod keeps the starter app, SQLite configuration, benchmark harness, and local Serverpod SQLite tuning patch together in one repository.

## Repository Layout

```text
pocketpod-starter/       canonical starter app/template
serverpod-pocketpod/     local Serverpod source copy with SQLite tuning
tool/automation/         repository maintenance scripts
```

## Main Directories

`pocketpod-starter` contains the app you start from:

```text
pocketpod_client/      generated Dart client package
pocketpod_server/      Serverpod backend configured for SQLite
pocketpod_flutter/     Flutter companion app
tool/benchmarks/       benchmark runner and HTML report generator
system-summary.md      architecture, benchmark, and setup notes
```

`serverpod-pocketpod` contains the local Serverpod source copy used by the starter through path dependency overrides. The SQLite tuning patch is in:

```text
serverpod-pocketpod/packages/serverpod_database/lib/src/adapters/sqlite/sqlite_pool_manager.dart
```

## Current Workflow

Refresh the local starter metadata and dependency overrides from the repository root:

```sh
tool/automation/create_pocketpod_repos.sh
```

Refresh the local Serverpod source copy from `../ServerPod`:

```sh
tool/automation/create_pocketpod_repos.sh --force
```

Validate the starter:

```sh
cd pocketpod-starter
flutter pub get
flutter analyze
dart run tool/benchmarks/run_bench.dart --profile production --targets serverpod-sqlite-tuned
dart run tool/benchmarks/render_report.dart
```

Open the benchmark report at:

```text
pocketpod-starter/tool/benchmarks/results/benchmark-report.html
```
