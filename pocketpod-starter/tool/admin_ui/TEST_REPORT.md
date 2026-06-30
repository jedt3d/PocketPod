# Phase 4 Flutter Admin UI Test Report

This report will track Phase 4 validation cycle by cycle.

## Current Status

Status: Cycle 0 complete; implementation not scaffolded yet.

Phase 3 is accepted as the reference behavior:

```text
served admin HTML
  -> Serverpod Auth login
  -> protected collection browsing
  -> primary-field record opening in every collection
  -> view-only Admin Input Examples
  -> editable SQLite-backed Products and Posts
```

Phase 4 will move that accepted behavior into a standalone Flutter Web admin app.

## Validation Template

Each cycle should record:

- commands run.
- test result.
- manual browser URL.
- screenshot path when UI changed.
- known limitations.
- commit hash.

## Cycle 0: Phase Handoff And Baseline

Status: complete.

Decisions:

- Phase 3 is accepted as the source behavior for Phase 4.
- The served HTML admin remains the reference implementation until Flutter reaches parity.
- The Flutter Web app will live at `pocketpod-starter/admin_ui/`.
- The planning ledger and validation report remain in `pocketpod-starter/tool/admin_ui/`.

Initial local commands:

```sh
cd pocketpod-starter/pocketpod_server
dart run bin/main.dart --apply-migrations

cd pocketpod-starter/admin_ui
flutter run -d chrome --web-port 8090
```

Result:

```text
PASS
Cycle 0 planning and app location are documented.
```

## Cycle 1: Flutter Web Scaffold

Status: complete.

Changes:

- Scaffolded `pocketpod-starter/admin_ui/` as a Flutter Web app.
- Added `admin_ui` to the root Dart workspace.
- Wired `admin_ui` to `pocketpod_client`.
- Replaced the counter sample with a deterministic PocketPod admin shell.
- Added a smoke widget test for the Cycle 1 shell.

Validation:

```sh
flutter pub get
dart format admin_ui/lib admin_ui/test
flutter analyze admin_ui
flutter test admin_ui --reporter expanded
cd admin_ui && flutter build web
```

Result:

```text
PASS
flutter pub get: resolved workspace dependencies.
flutter analyze admin_ui: No issues found.
flutter test admin_ui: 1 test passed.
flutter build web: built build/web.
```

Note:

```text
flutter build web emitted a non-fatal scaffold font warning mentioning CupertinoIcons, but the app does not use Cupertino icons and the build completed successfully.
```

## Cycle 2: Auth Shell

Status: complete except screenshot evidence.

Changes:

- Added a typed `AdminApi` boundary.
- Added `ServerpodAdminApi` backed by the generated `pocketpod_client`.
- Added a Serverpod `AuthenticationKeyManager` compatibility wrapper for the pinned generated client.
- Added `SharedPreferencesAdminSessionStore` for browser/session persistence.
- Added `MemoryAdminSessionStore` for tests.
- Added login, loading, error, restore-session, protected-shell, and logout UI states.
- Added widget tests for login, login failure, stored session restore, and logout.

Validation:

```sh
dart format admin_ui/lib admin_ui/test
flutter analyze admin_ui
flutter test admin_ui --reporter expanded
cd admin_ui && flutter build web
```

Result:

```text
PASS
flutter analyze admin_ui: No issues found.
flutter test admin_ui: 5 tests passed.
flutter build web: built build/web.
```

Notes:

```text
The pinned generated Serverpod client exposes `authenticationKeyManager` rather than the newer `authKeyProvider`, so the Flutter admin app uses a small local compatibility wrapper and scopes the deprecated API ignore to `admin_api.dart`.
Screenshot evidence is still pending for Cycle 2 and can be captured once the app is run in Chrome.
```

## Cycle 3: Collection Browser

Status: complete except screenshot evidence.

Changes:

- Added protected client calls for `listCollections`, `listRecords`, and `getRecord`.
- Added dynamic collection navigation for Admin Input Examples, Products, and Posts.
- Added collection counts and active collection selection.
- Added loaded, loading, empty, and error-safe collection panel states.
- Added scroll-safe table rendering for shorter browser heights and wider schemas.
- Made the primary field clickable in every collection:
  - Admin Input Examples: `title`.
  - Products: `name`.
  - Posts: `title`.
- Kept an explicit Edit action for editable Product/Post rows.
- Added a read-only detail preview for collection rows.
- Added widget coverage for switching collections and opening a record from the primary field.

Validation:

```sh
dart format admin_ui/lib admin_ui/test
flutter analyze admin_ui
flutter test admin_ui --reporter expanded
cd admin_ui && flutter build web
```

Result:

```text
PASS
flutter analyze admin_ui: No issues found.
flutter test admin_ui: 6 tests passed.
flutter build web: built build/web.
```

Notes:

```text
The collection panel uses a bounded scroll area so field chips, tables, and detail previews remain usable on shorter screens.
Screenshot evidence is still pending and should be captured from the running web app before the Phase 4 acceptance gate.
```

## Cycle 4: Detail And Edit Forms

Status: complete except screenshot evidence.

Changes:

- Wired the Flutter admin API to the existing protected `admin.updateRecord` Serverpod endpoint.
- Replaced the record preview with a metadata-driven detail form.
- Kept Admin Input Examples read-only as the control showcase.
- Enabled Product/Post edit mode with save through protected admin endpoints.
- Added smart controls from `AdminField.control`:
  - `text` -> single-line text field.
  - `textarea` -> multi-line field.
  - `checkbox` -> checkbox list tile.
  - `datetime` -> read-only datetime field with date/time picker trigger.
  - `number` -> numeric text field with numeric validation.
  - `select` and `relation` -> dropdown fields.
- Added red required asterisks next to required labels.
- Added required and numeric validation before save.
- Updated the active table row after a successful save.
- Added save success and failure UI states.
- Added mocked API widget coverage for form validation and update flow.

Validation:

```sh
dart format admin_ui/lib admin_ui/test
flutter analyze admin_ui
flutter test admin_ui --reporter expanded
cd admin_ui && flutter build web
```

Result:

```text
PASS
flutter analyze admin_ui: No issues found.
flutter test admin_ui: 7 tests passed.
flutter build web: built build/web.
```

Notes:

```text
The dropdown relation control is currently a local placeholder list because the admin metadata contract does not yet expose relation option endpoints.
Screenshot evidence for Product and Post edit remains pending for the Phase 4 acceptance gate.
```
