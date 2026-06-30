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

Status: complete.

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
Final Phase 4 screenshot evidence is recorded in Cycle 8 after the authenticated shell, collection browser, and edit form work were integrated.
```

## Cycle 3: Collection Browser

Status: complete.

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
Final Phase 4 screenshot evidence is recorded in Cycle 8 after the collection browser was integrated with the hosted app.
```

## Cycle 4: Detail And Edit Forms

Status: complete.

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
Final Phase 4 screenshot evidence is recorded in Cycle 8 after the edit form was integrated with the hosted app.
```

## Cycle 5: Generator Integration

Status: complete.

Implementation decision:

```text
Reusable runtime widgets stay in `pocketpod-starter/admin_ui/lib/`.
Generated output stays deterministic and schema-driven under `tool/admin_generator/generated/`.
The generator now emits a compact Flutter metadata artifact that can be consumed by the runtime without copying the earlier static HTML preview into the app.
PocketBase remains credited product-design inspiration only.
```

Changes:

- Added `AdminGenerator.generateFlutterMetadataSource`.
- Added deterministic `generated_admin_collections.dart` output.
- Added `GeneratedAdminCollection` and `GeneratedAdminField` metadata classes in the generated artifact.
- Mapped generator form controls to Phase 4 runtime control names:
  - text, textarea, number, checkbox, datetime, select, relation, list, unsupported.
- Updated the generator CLI to emit the metadata artifact alongside generated screens and HTML preview.
- Added generator tests for deterministic metadata output and CLI file creation.
- Regenerated sample artifacts under `tool/admin_generator/generated/`.

Validation:

```sh
dart run tool/admin_generator/yaml_to_admin.dart --input tool/admin_generator/fixtures --output tool/admin_generator/generated
flutter test test/admin_generator --reporter expanded
dart format --set-exit-if-changed tool/admin_generator test/admin_generator
```

Result:

```text
PASS
yaml_to_admin.dart: generated admin_input_example_admin.dart, post_admin.dart, product_admin.dart, generated_admin_collections.dart, and admin_preview.html.
flutter test test/admin_generator: 7 tests passed.
dart format --set-exit-if-changed tool/admin_generator test/admin_generator: pass.
```

## Cycle 6: UX Polish And Accessibility

Status: complete.

Changes:

- Added a responsive shell breakpoint below `820px`.
- Switched narrow layouts from desktop row layout to stacked sidebar/workspace layout.
- Made the sidebar scroll-safe and full-width on compact screens.
- Made the workspace header stack on compact screens.
- Shortened the compact auth status to avoid clipping long auth user ids.
- Wrapped metric cards on narrow screens.
- Kept table content horizontally scrollable.
- Added a `FocusTraversalGroup` around the authenticated shell.
- Added an explicit semantic label to the sign-out action.
- Kept destructive-action confirmation as non-applicable for this cycle because Phase 4 still has no destructive CRUD actions.
- Captured desktop and mobile-width screenshot evidence.

Screenshots:

```text
tool/admin_ui/screenshots/cycle6-desktop.png
tool/admin_ui/screenshots/cycle6-mobile.png
```

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

## Cycle 7: Static Build And Serverpod Hosting

Status: complete.

Decisions:

```text
The Flutter Web admin bundle is hosted at `pocketpod_server/web/app/` and served as `/app/` by the Serverpod web server.
The older `/admin/index.html` served HTML prototype remains available as historical/reference output until documentation moves users fully to the Flutter app.
```

Changes:

- Added `tool/admin_ui/build_serverpod_admin.sh`.
- The script builds `admin_ui/` with `--base-href /app/`.
- The script writes static output to `pocketpod_server/web/app/`.
- Added build-time API URL configuration through `POCKETPOD_API_URL`.
- Updated `ServerpodAdminApi` to read `POCKETPOD_API_URL` from Dart environment defines, defaulting to `http://localhost:8080/`.
- Documented build and serve commands in `tool/admin_ui/README.md`.

Validation:

```sh
tool/admin_ui/build_serverpod_admin.sh
curl -s -o /tmp/pocketpod-app-index.html -w '%{http_code}\n' http://127.0.0.1:8082/app/
```

Result:

```text
PASS
build_serverpod_admin.sh: built pocketpod_server/web/app.
curl http://127.0.0.1:8082/app/: 200.
```

## Cycle 8: Phase 4 Acceptance Gate

Status: complete.

Final deliverable:

```text
Standalone Flutter Web admin app:
admin_ui/

Serverpod-served build path:
pocketpod_server/web/app/

Local served URL:
http://localhost:8082/app/
```

Final validation:

```sh
flutter analyze admin_ui
flutter test admin_ui --reporter expanded
flutter test test/admin_generator --reporter expanded
dart format --set-exit-if-changed tool/admin_generator test/admin_generator
cd pocketpod_server && flutter test --reporter expanded
tool/admin_ui/build_serverpod_admin.sh
curl -s -o /tmp/pocketpod-app-index.html -w '%{http_code}\n' http://127.0.0.1:8082/app/
```

Result:

```text
PASS
flutter analyze admin_ui: No issues found.
flutter test admin_ui: 7 tests passed.
flutter test test/admin_generator: 7 tests passed.
dart format --set-exit-if-changed tool/admin_generator test/admin_generator: pass.
cd pocketpod_server && flutter test: 3 tests passed.
tool/admin_ui/build_serverpod_admin.sh: built pocketpod_server/web/app.
curl http://127.0.0.1:8082/app/: 200.
```

Screenshots:

```text
tool/admin_ui/screenshots/cycle6-desktop.png
tool/admin_ui/screenshots/cycle6-mobile.png
```

Notes:

```text
`dart test` from pocketpod_server is not the correct command in this workspace because the workspace includes Flutter SDK packages; `flutter test` is the working server test command.
The generated static bundle under pocketpod_server/web/app is reproducible and ignored by git; use tool/admin_ui/build_serverpod_admin.sh to refresh it.
```
