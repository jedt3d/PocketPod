# Phase 6 Test Report: Admin CRUD Hardening

Status:
Cycles 0-4 complete for the current Phase 6 milestone.

## Cycle 0: Phase Handoff And Scope

Decision:

```text
Phase 6 continues from the hosted Flutter admin app and focuses on practical admin CRUD hardening.
Admin Input Examples remains read-only.
Products and Posts are the first writable SQLite-backed collections.
```

Validation:

```sh
rg -n "## ✅ Phase 4|## ✅ Phase 5" PHASE_PLAN.md
```

Result:

```text
PASS
Phase 4 and Phase 5 are documented as complete before Phase 6 starts.
```

## Cycle 1: Create And Delete Records

Implementation:

```text
Protected server endpoints:
admin.createRecord
admin.deleteRecord

Flutter admin controls:
New button on editable collections
Create form with safe defaults
Delete button on existing editable records
Confirmation dialog before delete
```

Validation:

```sh
dart format --set-exit-if-changed admin_ui/lib admin_ui/test pocketpod_server/lib/src/admin pocketpod_server/lib/src/generated pocketpod_server/test/integration pocketpod_client/lib/src/protocol
flutter analyze admin_ui
flutter test admin_ui --reporter expanded
cd pocketpod_server && flutter test test/integration/admin_endpoint_test.dart --reporter expanded
flutter test test/admin_generator --reporter expanded
tool/deploy/build_release.sh
tool/deploy/smoke_release.sh
```

Result:

```text
PASS
flutter analyze admin_ui: No issues found.
flutter test admin_ui: 10 tests passed.
admin_endpoint_test.dart: 1 integration test passed, including protected create/delete coverage.
flutter test test/admin_generator: 7 tests passed.
tool/deploy/build_release.sh: release artifact built.
tool/deploy/smoke_release.sh: /app/, config.json, and SQLite smoke database verified.
```

Notes:

```text
The globally installed Serverpod CLI is 3.4.5 while this workspace is pinned to Serverpod 3.5.0-beta.10.
For this cycle, generated dispatch/client/test stubs were updated consistently by hand instead of running the mismatched global generator.
```

## Cycle 2: Relation Lookup Endpoints

Implementation:

```text
Protected server endpoint:
admin.relationOptions

Supported relation option sources:
products.categoryId -> category labels
posts.authorId -> author labels
admin_input_examples.categoryId -> category labels for control-preview consistency

Flutter admin behavior:
Relation dropdowns request options from the server after a collection is selected.
The dropdown display text is now label-based while the saved value remains the underlying id/code.
If a record contains a legacy or currently unknown value, the current value is preserved as a selectable option.
```

Validation:

```sh
flutter test admin_ui --reporter expanded
cd pocketpod_server && flutter test test/integration/admin_endpoint_test.dart --reporter expanded
```

Result:

```text
PASS
Widget tests verify relation labels are loaded into the Product edit form.
Integration tests verify products.categoryId returns server-provided options.
```

## Cycle 3: Pagination And Search

Implementation:

```text
admin.listRecords now accepts:
offset
limit
query

The server returns:
filtered rows for the current page
collection.rowCount for the filtered result set

Flutter admin controls:
Search field with keyboard submit and Search button
Page size selector for 10, 25, and 50 rows
Previous and next page buttons
Visible row range indicator
```

Validation:

```sh
flutter test admin_ui --reporter expanded
cd pocketpod_server && flutter test test/integration/admin_endpoint_test.dart --reporter expanded
```

Result:

```text
PASS
Widget tests verify next-page state and search query dispatch.
Integration tests verify filtered Product listing and paged Product listing.
```

## Cycle 4: Role And Permission Hardening

Implementation:

```text
Login now rejects a successfully authenticated user when the returned scope list does not include serverpod.admin.
The UI shows an explicit admin-access-required message instead of a generic login failure.
Server integration tests cover promoting an existing non-admin auth user to Scope.admin before login.
```

Validation:

```sh
flutter analyze
flutter test admin_ui --reporter expanded
cd pocketpod_server && flutter test test/integration/admin_endpoint_test.dart --reporter expanded
```

Result:

```text
PASS
flutter analyze: No issues found.
flutter test admin_ui: 10 tests passed, including insufficient-scope login messaging.
admin_endpoint_test.dart: 1 integration test passed, including non-admin rejection and explicit admin promotion coverage.
```
