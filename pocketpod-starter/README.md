# PocketPod Starter

This directory is the reusable PocketPod starter app/template.

It is built on [Serverpod](https://serverpod.dev). PocketPod does not replace Serverpod; it uses Serverpod as the backend framework and adds a SQLite-focused starter configuration, benchmark harness, and local tuning patch.

PocketPod was also initially inspired by [PocketBase](https://pocketbase.io), especially its lightweight local SQLite deployment feel. PocketBase is not a dependency of this starter; it is used only as inspiration and as one optional benchmark comparison target.

The admin generator also takes product-design inspiration from PocketBase's fast collection/admin experience, but PocketPod's approach is different: it generates typed Flutter admin source from Serverpod `.spy.yaml` models and keeps the result inspectable and customizable in the Dart/Flutter workflow.

PocketPod version:

```text
0.1.0
```

Compatible Serverpod baseline:

```text
3.5.0-beta.10
```

Release tag:

```text
v0.1.0+serverpod.3.5.0-beta.10
```

This makes it easy to know both PocketPod's own version and the Serverpod version that the starter and `serverpod-pocketpod` source copy are aligned with.

From the repository root, refresh the local path overrides and README files with:

```sh
tool/automation/create_pocketpod_repos.sh
```

## What Is Inside

```text
pocketpod_client/      generated Dart client package
pocketpod_server/      Serverpod backend configured for SQLite
pocketpod_flutter/     Flutter companion app
tool/admin_generator/  Serverpod model YAML to admin UI generator
tool/benchmarks/       benchmark runner and HTML report generator
system-summary.md      architecture, benchmark, and setup notes
```

## Admin Generator Preview

Run the current Phase 3 generator from this starter directory:

![PocketPod smart admin generator preview](tool/admin_generator/screenshots/admin-preview.png)

```sh
dart run tool/admin_generator/yaml_to_admin.dart \
  --input tool/admin_generator/fixtures \
  --output tool/admin_generator/generated
```

The generated preview demonstrates PocketPod's smart form controls:

```text
String short text     -> text input
long text/body fields -> textarea
bool                  -> checkbox
DateTime              -> datetime selector
int/double            -> numeric input
enum/choice           -> dropdown placeholder
foreign key/relation  -> dropdown placeholder
List<T>               -> array/list placeholder
required fields       -> red * marker
nullable fields       -> optional marker
```

Review the latest screenshot:

```text
tool/admin_generator/screenshots/admin-preview.png
```

Phase 4 is complete for the current milestone. The standalone Flutter Web admin app lives in:

```text
admin_ui/
```

Its task ledger and test report live in:

```text
tool/admin_ui/TASKS.md
tool/admin_ui/TEST_REPORT.md
```

## Admin Screen

Build the Flutter admin app into Serverpod's static web directory:

```sh
tool/admin_ui/build_serverpod_admin.sh
```

When the starter server is running, open the Flutter admin app at:

```text
http://localhost:8082/app/
```

The older served HTML admin prototype remains available for reference at:

```text
http://localhost:8082/admin/index.html
```

The Flutter admin app signs in through Serverpod Auth via `adminAuth.login`, stores the returned JWT in browser local storage, and calls protected `Scope.admin` endpoints. It includes clickable collection navigation for Admin Input Examples, Products, and Posts. Every collection opens records from its primary field: Admin Input Examples uses `title` in a view-only form, Products uses `name`, and Posts uses `title`. Products and Posts are SQLite-backed starter records with edit/save support through protected admin endpoints.

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
