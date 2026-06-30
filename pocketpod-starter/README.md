# PocketPod Starter

This directory is the reusable PocketPod starter app/template.

It is built on [Serverpod](https://serverpod.dev). PocketPod does not replace Serverpod; it uses Serverpod as the backend framework and adds a SQLite-focused starter configuration, benchmark harness, and local tuning patch.

The Serverpod baseline used by this starter is:

```text
3.5.0-beta.10
```

PocketPod release tags intentionally match the Serverpod baseline, for example:

```text
v3.5.0-beta.10
```

This makes it easy to know which Serverpod version the starter and `serverpod-pocketpod` source copy are aligned with.

From the repository root, refresh the local path overrides and README files with:

```sh
tool/automation/create_pocketpod_repos.sh
```

## What Is Inside

```text
pocketpod_client/      generated Dart client package
pocketpod_server/      Serverpod backend configured for SQLite
pocketpod_flutter/     Flutter companion app
tool/benchmarks/       benchmark runner and HTML report generator
system-summary.md      architecture, benchmark, and setup notes
```

This starter points to the in-repo Serverpod copy:

```text
../serverpod-pocketpod/packages/...
```

## Main PocketPod Configuration

SQLite database configuration lives in:

```text
pocketpod_server/config/development.yaml
pocketpod_server/config/test.yaml
pocketpod_server/config/staging.yaml
pocketpod_server/config/production.yaml
```

The important production baseline is:

```yaml
database:
  filePath: .serverpod/production/database.sqlite
  maxConnectionCount: 5
```

Serverpod's generated password file is intentionally local-only:

```text
pocketpod_server/config/passwords.yaml
```

Do not commit real project secrets. Generate or copy local passwords when creating a new app from this starter.

The SQLite runtime tuning itself is in:

```text
../serverpod-pocketpod/packages/serverpod_database/lib/src/adapters/sqlite/sqlite_pool_manager.dart
```

Look for:

```dart
SqliteOptions(
  journalMode: SqliteJournalMode.wal,
  synchronous: SqliteSynchronous.normal,
  lockTimeout: const Duration(seconds: 5),
  maxReaders: maxReaders,
)
```

## Validation Commands

```sh
flutter pub get
flutter analyze
dart run tool/benchmarks/run_bench.dart --profile production --targets serverpod-sqlite-tuned
dart run tool/benchmarks/render_report.dart
```

Open the generated report:

```text
tool/benchmarks/results/benchmark-report.html
```
