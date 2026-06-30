# Phase 6 Tasks: Admin CRUD Hardening

Goal:
Harden the PocketPod admin app beyond edit-only CRUD so it can manage starter e-commerce and CMS records more realistically.

## Cycle 0: Phase Handoff And Scope

- [x] Confirm Phase 4 delivered the hosted Flutter admin app.
- [x] Confirm Phase 5 delivered the zero-Docker release artifact.
- [x] Keep Admin Input Examples as a read-only control showcase.
- [x] Keep Product and Post as the first writable SQLite-backed collections.
- [x] Record validation in `PHASE6_TEST_REPORT.md`.

Acceptance:

```text
Phase 6 starts from the working Flutter admin app and focuses on hardening admin CRUD behavior.
```

## Cycle 1: Create And Delete Records

- [x] Add protected `admin.createRecord` endpoint for Products and Posts.
- [x] Add protected `admin.deleteRecord` endpoint for Products and Posts.
- [x] Preserve `Scope.admin` protection for create/delete.
- [x] Update Serverpod generated dispatch and client stubs for the new methods.
- [x] Add a New action for editable collections.
- [x] Open a create form with safe default values instead of inserting a row immediately.
- [x] Save a new record through the protected create endpoint.
- [x] Add a Delete action for existing editable records.
- [x] Require confirmation before deleting.
- [x] Keep Admin Input Examples read-only.
- [x] Add admin UI widget tests for create/delete.
- [x] Add server integration tests for protected create/delete.
- [x] Record validation in `PHASE6_TEST_REPORT.md`.

Acceptance:

```text
Admins can create and delete Product/Post records through the Flutter admin UI, and the server endpoints are protected by Serverpod Auth with Scope.admin.
```

## Cycle 2: Relation Lookup Endpoints

- [ ] Add metadata for relation option sources.
- [ ] Add protected lookup endpoints for category-like and author-like relation options.
- [ ] Replace hard-coded relation dropdown options in the Flutter admin app.
- [ ] Add tests for loaded relation option states.
- [ ] Record validation in `PHASE6_TEST_REPORT.md`.

Acceptance:

```text
Relation dropdowns are backed by server-provided options instead of local placeholders.
```

## Cycle 3: Pagination And Search

- [ ] Add pagination parameters to record listing.
- [ ] Add search query support for primary text fields.
- [ ] Add table controls for search, page size, previous, and next.
- [ ] Add tests for paging and search state.
- [ ] Record validation in `PHASE6_TEST_REPORT.md`.

Acceptance:

```text
Collections remain usable with larger Product/Post datasets.
```

## Cycle 4: Role And Permission Hardening

- [ ] Add explicit UI states for insufficient permissions.
- [ ] Add role/permission documentation beyond the initial `Scope.admin` gate.
- [ ] Add the older hardening test for promoting an existing non-admin auth user.
- [ ] Record validation in `PHASE6_TEST_REPORT.md`.

Acceptance:

```text
Admin authorization behavior is clearer to users and covered by regression tests.
```

## Backlog Not Blocking Cycle 1

- [ ] Add bulk delete after single-record delete is stable.
- [ ] Add create/delete screenshot evidence from a real browser session.
- [ ] Add audit metadata for create/update/delete operations.
