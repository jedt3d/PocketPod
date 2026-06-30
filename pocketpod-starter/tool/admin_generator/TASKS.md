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

- [ ] `String` short fields use a single-line text input.
- [ ] Long text fields such as `body`, `description`, `content`, `excerpt`, `notes`, and `summary` use a textarea-style multi-line control.
- [ ] `bool` fields use a checkbox or switch control.
- [ ] `DateTime` fields use a datetime selector style in the HTML preview and an appropriate generated Flutter control placeholder.
- [ ] `int` and `double` fields keep numeric input behavior.
- [ ] Enum-like fields use a dropdown/select control when the generator can infer finite choices.
- [ ] Foreign-key-like fields such as `categoryId`, `authorId`, `productId`, and relation fields use a dropdown/select placeholder until live lookup data exists.
- [ ] Required non-nullable fields show a red asterisk marker in labels.
- [ ] Nullable fields show optional affordance text in the preview.
- [ ] Update fixtures to include at least one dropdown-style field.
- [ ] Update generated preview screenshot.
- [ ] Add tests for field-to-control mapping.
- [ ] Record validation in `TEST_REPORT.md`.

Implementation notes:

- [ ] Add a form-control classification layer separate from raw Dart type parsing.
- [ ] Keep the first pass deterministic and schema-only; do not require a live database.
- [ ] Prefer explicit future metadata over fragile name guesses when Serverpod YAML provides enough information.
- [ ] Use field-name heuristics only as a practical fallback for Cycle 2A.
- [ ] Keep PocketBase as UI inspiration only; do not copy PocketBase code, assets, icons, or branding.

## Cycle 3: Serverpod Auth Bootstrap

- [ ] Reintroduce Serverpod Auth dependencies for the SQLite starter.
- [ ] Add `tool/admin/create_sysadmin.dart`.
- [ ] Validate first-admin bootstrap behavior.
- [ ] Add tests for duplicate, promotion, and safe password behavior.
- [ ] Record validation in `TEST_REPORT.md`.

## Cycle 4: Admin Endpoint Guard Convention

- [ ] Generate or document admin endpoint guard code.
- [ ] Prove unauthenticated callers are rejected.
- [ ] Prove signed-in non-admin callers are rejected.
- [ ] Prove signed-in admin callers can reach generated admin methods.
- [ ] Record validation in `TEST_REPORT.md`.
