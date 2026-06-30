# Serverpod PocketPod Fork

This directory is the in-repository Serverpod source copy used by PocketPod.

It is not a new backend framework. It is Serverpod with the local PocketPod SQLite tuning patch applied.

## Serverpod Credit

This source tree comes from [Serverpod](https://serverpod.dev). The Serverpod team built the framework, CLI, runtime, protocol generation, and package structure that PocketPod depends on.

PocketPod keeps this copy locally only so the SQLite tuning patch can be inspected, tested, and used by the starter through path dependency overrides.

## PocketBase Inspiration

PocketPod was also initially inspired by [PocketBase](https://pocketbase.io), especially its lightweight local SQLite deployment feel. PocketBase is not part of this Serverpod source copy; it is referenced only as product inspiration and optional benchmark context.

## Version

This copy is based on Serverpod:

```text
3.5.0-beta.10
```

PocketPod uses the same release tag:

```text
v3.5.0-beta.10
```

The version number is intentionally the same as Serverpod's baseline version so users can quickly match `serverpod-pocketpod` to the upstream Serverpod version it was built from.

## Why This Exists

PocketPod needs explicit SQLite runtime settings:

```text
journal_mode        : WAL
synchronous         : NORMAL
busy_timeout        : 5000 ms
maxConnectionCount  : 5 in the starter app config
```

This in-repo Serverpod copy keeps the patch close to the starter app.

## Main File To Inspect

```text
packages/serverpod_database/lib/src/adapters/sqlite/sqlite_pool_manager.dart
```

The important tuning block is:

```dart
SqliteOptions(
  journalMode: SqliteJournalMode.wal,
  synchronous: SqliteSynchronous.normal,
  lockTimeout: const Duration(seconds: 5),
  maxReaders: maxReaders,
)
```

The benchmark-only untuned profile is also in this file. It allows comparison against rollback-journal/full-sync/single-reader behavior without maintaining a second Serverpod source tree.

## Related Test

```text
packages/serverpod_database/test/sqlite_pool_manager_test.dart
```

Run:

```sh
cd serverpod-pocketpod/packages/serverpod_database
dart test test/sqlite_pool_manager_test.dart
dart analyze
```

## Upstream Serverpod README

The original upstream Serverpod README was preserved as:

```text
README.SERVERPOD_UPSTREAM.md
```

## How The Starter Uses This Directory

The `pocketpod-starter/pubspec.yaml` file points to packages in this directory using path dependency overrides:

```yaml
dependency_overrides:
  serverpod:
    path: ../serverpod-pocketpod/packages/serverpod
  serverpod_database:
    path: ../serverpod-pocketpod/packages/serverpod_database
```

This keeps everything inside one repository while preserving a clean boundary between:

```text
pocketpod-starter      app/template code
serverpod-pocketpod    framework patch code
```
