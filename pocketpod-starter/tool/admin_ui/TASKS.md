# Phase 4 Flutter Admin UI Tasks

This task list tracks Phase 4 implementation after the accepted Phase 3 admin generator checkpoint.

## Phase 4 Goal

Provide a standalone Flutter Web admin app that hosts generated CRUD screens and talks to the PocketPod Serverpod backend.

Target outcome:

```text
pocketpod-starter/admin_ui/ Flutter Web app
  -> Serverpod Auth login
  -> protected admin shell
  -> generated collection navigation
  -> SQLite-backed Product/Post edit workflows
```

## Cycle 0: Phase Handoff And Baseline

- [x] Confirm Phase 3 is accepted as the source behavior for Phase 4.
- [x] Keep the existing served HTML admin as the reference behavior.
- [x] Decide whether `admin_ui/` lives under `pocketpod-starter/admin_ui` or another folder before scaffolding.
- [x] Document the local run commands for backend plus admin UI.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The Phase 4 app location, scope, and reference behavior are documented before code scaffolding starts.
```

## Cycle 1: Flutter Web Scaffold

- [x] Scaffold a dedicated Flutter Web app for the admin UI.
- [x] Add dependency wiring to `pocketpod_client`.
- [x] Add analysis/lint configuration consistent with the starter.
- [x] Add a minimal app shell with deterministic title, theme, and route structure.
- [x] Add a smoke widget test.
- [x] Verify `flutter analyze`.
- [x] Verify `flutter test`.
- [x] Verify `flutter build web` if the local toolchain supports it.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The admin UI app builds/tests independently and can be opened as a Flutter Web app.
```

## Cycle 2: Auth Shell

- [x] Build a login screen matching the Phase 3 auth behavior.
- [x] Call `adminAuth.login` through the generated client or a typed service wrapper.
- [x] Persist the JWT/session state for browser refresh.
- [x] Add logout and expired-session handling.
- [x] Protect admin routes until login succeeds.
- [x] Show clear login loading and error states.
- [x] Add widget tests for login form states.
- [x] Add service tests for success/failure mapping where practical.
- [ ] Capture screenshot evidence.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
An admin can sign in and reach the Flutter admin shell. Invalid or expired auth returns to login.
```

## Cycle 3: Collection Browser

- [x] Build the sidebar collection navigation.
- [x] Fetch collection metadata from protected admin endpoints.
- [x] Render Admin Input Examples, Products, and Posts.
- [x] Show collection counts.
- [x] Render table loading, empty, error, and loaded states.
- [x] Make the primary field clickable in every collection:
  - Admin Input Examples: `title`
  - Products: `name`
  - Posts: `title`
- [x] Keep an explicit Edit action for editable collections.
- [x] Add responsive layout behavior for desktop and narrow widths.
- [x] Add widget tests for table rendering and primary-field navigation.
- [ ] Capture screenshot evidence.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The Flutter app can browse all current collections and open a record from the primary field.
```

## Cycle 4: Detail And Edit Forms

- [x] Render Admin Input Examples in view-only mode.
- [x] Render Products and Posts in editable mode.
- [x] Generate or reuse smart controls:
  - short text input.
  - textarea for body/description.
  - checkbox for booleans.
  - datetime input for date fields.
  - numeric input for int/double.
  - dropdown placeholder for relation-like fields.
- [x] Show required `*` markers.
- [x] Validate required fields before save.
- [x] Save Product/Post edits through protected admin endpoints.
- [x] Refresh the active table after save.
- [x] Show save success and failure states.
- [x] Add widget tests for each control type.
- [x] Add integration-style tests with mocked admin service responses.
- [ ] Capture screenshot evidence for Product edit and Post edit.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The Flutter app matches the accepted Phase 3 behavior: view-only demo records and editable persistent Product/Post records.
```

## Cycle 5: Generator Integration

- [x] Decide which parts are generated source and which parts are reusable runtime widgets.
- [x] Extend the Phase 3 generator to emit Flutter admin screen code usable by `admin_ui/`.
- [x] Keep generated output deterministic.
- [x] Add fixture coverage for generated Flutter admin routes/widgets.
- [x] Avoid copying the temporary static HTML implementation into Flutter directly.
- [x] Keep PocketBase as product-design inspiration only.
- [x] Add generator tests for Phase 4 Flutter output.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The generator can produce or refresh Flutter admin UI code from representative Serverpod model YAML.
```

## Cycle 6: UX Polish And Accessibility

- [ ] Refine the visual design toward the accepted PocketBase-inspired direction.
- [ ] Keep the interface dense, practical, and work-focused.
- [ ] Add keyboard focus states.
- [ ] Ensure forms are usable by keyboard.
- [ ] Ensure table text and buttons do not overflow on narrow screens.
- [ ] Add accessible labels for icon-only or compact controls.
- [ ] Add confirmation behavior for destructive future actions.
- [ ] Capture desktop and mobile-width screenshots.
- [ ] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The Flutter admin UI is usable, readable, and visually consistent across desktop and mobile-width browser sizes.
```

## Cycle 7: Static Build And Serverpod Hosting

- [ ] Build the Flutter Web admin app.
- [ ] Decide the static output path for Serverpod web hosting.
- [ ] Add a repeatable local script for building/copying the admin bundle.
- [ ] Serve the built admin app through the Serverpod web server.
- [ ] Preserve backend API base configuration for local and production modes.
- [ ] Add a local smoke test for the hosted build.
- [ ] Document the build and serve commands.
- [ ] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The built Flutter Web admin app is served through the local PocketPod Serverpod server.
```

## Cycle 8: Phase 4 Acceptance Gate

- [ ] Run full workspace analysis.
- [ ] Run server tests.
- [ ] Run admin UI tests.
- [ ] Run generator tests.
- [ ] Run Flutter Web build.
- [ ] Verify login, browse, view-only, edit, save, and refresh flows manually.
- [ ] Capture final screenshots.
- [ ] Update `PHASE_PLAN.md`.
- [ ] Update root and starter READMEs.
- [ ] Update `system-summary.md`.
- [ ] Record final validation in `TEST_REPORT.md`.

Acceptance:

```text
The standalone Flutter Web admin app can exercise generated CRUD screens against a local Serverpod server and is documented as the Phase 4 deliverable.
```

## Backlog Not Blocking Phase 4 Start

- [ ] Add the older Phase 3 hardening test for promoting an existing non-admin auth user.
- [ ] Add create/delete CRUD operations after edit flow is stable.
- [ ] Replace relation placeholders with live lookup endpoints.
- [ ] Add pagination and search for larger collections.
- [ ] Add role/permission UI beyond the initial `Scope.admin` gate.
