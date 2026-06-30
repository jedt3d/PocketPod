# Phase 3 Admin Generator Tasks

This task list tracks the Phase 3 implementation lifecycle on the `feature/phase3-admin-generator` branch.

## Cycle 0: Planning Baseline

- [x] Create a feature branch.
- [x] Commit the detailed Phase 3 plan.
- [x] Add PocketBase admin UX inspiration credit.

## Cycle 1: Generator Foundation

- [x] Add representative Serverpod model fixtures.
- [x] Add a reusable YAML model parser.
- [x] Generate deterministic Flutter admin source from fixtures.
- [x] Add unit tests for parsing and generated output.
- [x] Record validation in `TEST_REPORT.md`.

## Cycle 2: CLI And Preview

- [x] Add `yaml_to_admin.dart` CLI.
- [x] Generate files from an input directory to an output directory.
- [x] Generate a static admin preview artifact for visual review.
- [x] Capture screenshot evidence.
- [x] Refine preview styling toward a cleaner PocketBase-inspired collection admin theme.
- [x] Record validation in `TEST_REPORT.md`.

## Cycle 2A: Smart Form Controls

Goal:
Improve generated admin forms so fields use appropriate controls instead of rendering every field as a plain text input.

Planned control mapping:

- [x] `String` short fields use a single-line text input.
- [x] Long text fields such as `body`, `description`, `content`, `excerpt`, `notes`, and `summary` use a textarea-style multi-line control.
- [x] `bool` fields use a checkbox or switch control.
- [x] `DateTime` fields use a datetime selector style in the HTML preview and an appropriate generated Flutter control placeholder.
- [x] `int` and `double` fields keep numeric input behavior.
- [x] Enum-like fields use a dropdown/select control when the generator can infer finite choices.
- [x] Foreign-key-like fields such as `categoryId`, `authorId`, `productId`, and relation fields use a dropdown/select placeholder until live lookup data exists.
- [x] Required non-nullable fields show a red asterisk marker in labels.
- [x] Nullable fields show optional affordance text in the preview.
- [x] Update fixtures to include at least one dropdown-style field.
- [x] Update generated preview screenshot.
- [x] Add tests for field-to-control mapping.
- [x] Record validation in `TEST_REPORT.md`.

Implementation notes:

- [x] Add a form-control classification layer separate from raw Dart type parsing.
- [x] Keep the first pass deterministic and schema-only; do not require a live database.
- [x] Prefer explicit future metadata over fragile name guesses when Serverpod YAML provides enough information.
- [x] Use field-name heuristics only as a practical fallback for Cycle 2A.
- [x] Keep PocketBase as UI inspiration only; do not copy PocketBase code, assets, icons, or branding.

## Cycle 3: Serverpod Auth Bootstrap

- [x] Reintroduce Serverpod Auth dependencies for the SQLite starter.
- [x] Add `tool/admin/create_sysadmin.dart` CLI entrypoint.
- [x] Add argument and environment validation for first-admin bootstrap.
- [x] Add dry-run mode while Serverpod Auth persistence is being wired.
- [x] Connect `tool/admin/create_sysadmin.dart` to Serverpod Auth persistence.
- [x] Add Serverpod Auth SQLite migration.
- [x] Validate first-admin bootstrap behavior against SQLite.
- [x] Validate duplicate sysadmin guard against SQLite.
- [x] Add tests for safe password behavior and persistence delegation.
- [ ] Add a real promotion test for an existing non-admin auth user.
- [x] Record validation in `TEST_REPORT.md`.

## Cycle 4: Admin Endpoint Guard Convention

- [x] Add `adminAuth.login` backed by Serverpod Auth email login.
- [x] Add a real `/admin/index.html` browser screen served by Serverpod.
- [x] Add protected `admin.dashboard` endpoint using `requireLogin` and `Scope.admin`.
- [x] Prove unauthenticated callers are rejected.
- [x] Prove signed-in non-admin callers are rejected.
- [x] Prove signed-in admin callers can reach the admin dashboard method.
- [x] Verify the browser page can log in and call the protected dashboard endpoint over HTTP.
- [x] Record validation in `TEST_REPORT.md`.

## Cycle 4A: Clickable Collections And Record Browsing

- [x] User accepted Cycle 4A as valid for the current checkpoint.
- [x] Add protected admin collection metadata models.
- [x] Add protected `admin.listCollections` endpoint.
- [x] Add protected `admin.listRecords` endpoint.
- [x] Render generated collections as clickable sidebar items.
- [x] Render Products and Posts record tables in the served admin screen.
- [x] Show generated field/control metadata above each collection table.
- [x] Verify Product and Post collection data over HTTP.
- [x] Add integration coverage for collection and record listing.

## Cycle 4B: Persistent Record Editing

Goal:
Move from read-only sample rows to editable SQLite-backed records for the starter admin screen.

- [x] Add persistent `Product` and `Post` Serverpod models for the starter.
- [x] Add SQLite migration coverage for the new starter tables.
- [x] Seed a small deterministic development dataset for manual review.
- [x] Replace server-only sample Product/Post rows with database-backed list queries.
- [x] Add protected get/update endpoints for editable Product and Post records.
- [x] Render an edit form from the existing generated field/control metadata.
- [x] Use textarea for long body fields, checkbox for booleans, datetime control for date fields, and select-style controls for enum/relation placeholders.
- [x] Make the primary record field clickable in every collection (`name` for Products, `title` for Posts and Admin Input Examples).
- [x] Open read-only collection records in a view-only form while keeping persistent collections editable.
- [x] Save edits through protected admin endpoints and refresh the active collection table.
- [x] Show validation errors and save success/failure states in the admin screen.
- [x] Add tests proving unauthenticated and non-admin callers cannot edit records.
- [x] Add tests proving admin edits persist in SQLite.
- [x] Verify Product and Post edits over real HTTP.
- [x] Record user manual browser acceptance for primary-field navigation and Product/Post editing.
- [x] Record validation in `TEST_REPORT.md`.
