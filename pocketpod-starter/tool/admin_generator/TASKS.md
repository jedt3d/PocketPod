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
- [x] Record validation in `TEST_REPORT.md`.

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
