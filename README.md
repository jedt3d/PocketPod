# PocketPod

PocketPod is a Serverpod + SQLite starter structure for a small single-server e-commerce/CMS backend.

It is not a new backend server. The backend is still Serverpod. PocketPod keeps the starter app, SQLite configuration, benchmark harness, and local Serverpod SQLite tuning patch together in one repository.

## Serverpod Credit

PocketPod is built on top of [Serverpod](https://serverpod.dev), and the core framework, generated protocol model, endpoint runtime, client generation, and project structure all come from the Serverpod team's work.

This repository only adds a focused PocketPod layer around Serverpod for the SQLite use case: a starter layout, SQLite-oriented configuration, a small tuning patch in the copied Serverpod source, and benchmark tooling. The Serverpod team deserves full credit for the framework foundation that makes this possible.

## Version

Current Serverpod baseline:

```text
3.5.0-beta.10
```

PocketPod uses the same release tag as the Serverpod version it is built against:

```text
v3.5.0-beta.10
```

We name PocketPod releases this way so it is immediately clear which Serverpod source version is inside `serverpod-pocketpod`. PocketPod-specific changes are tracked by commits and documentation, while the release number identifies the matching Serverpod baseline.

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
