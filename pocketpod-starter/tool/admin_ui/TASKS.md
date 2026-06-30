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

- [ ] Scaffold a dedicated Flutter Web app for the admin UI.
- [ ] Add dependency wiring to `pocketpod_client`.
- [ ] Add analysis/lint configuration consistent with the starter.
- [ ] Add a minimal app shell with deterministic title, theme, and route structure.
- [ ] Add a smoke widget test.
- [ ] Verify `flutter analyze`.
- [ ] Verify `flutter test`.
- [ ] Verify `flutter build web` if the local toolchain supports it.
- [ ] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The admin UI app builds/tests independently and can be opened as a Flutter Web app.
```

## Cycle 2: Auth Shell

- [ ] Build a login screen matching the Phase 3 auth behavior.
- [ ] Call `adminAuth.login` through the generated client or a typed service wrapper.
- [ ] Persist the JWT/session state for browser refresh.
- [ ] Add logout and expired-session handling.
- [ ] Protect admin routes until login succeeds.
- [ ] Show clear login loading and error states.
- [ ] Add widget tests for login form states.
- [ ] Add service tests for success/failure mapping where practical.
- [ ] Capture screenshot evidence.
- [ ] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
An admin can sign in and reach the Flutter admin shell. Invalid or expired auth returns to login.
```

## Cycle 3: Collection Browser

- [ ] Build the sidebar collection navigation.
- [ ] Fetch collection metadata from protected admin endpoints.
- [ ] Render Admin Input Examples, Products, and Posts.
- [ ] Show collection counts.
- [ ] Render table loading, empty, error, and loaded states.
- [ ] Make the primary field clickable in every collection:
  - Admin Input Examples: `title`
  - Products: `name`
  - Posts: `title`
- [ ] Keep an explicit Edit action for editable collections.
- [ ] Add responsive layout behavior for desktop and narrow widths.
- [ ] Add widget tests for table rendering and primary-field navigation.
- [ ] Capture screenshot evidence.
- [ ] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The Flutter app can browse all current collections and open a record from the primary field.
```

## Cycle 4: Detail And Edit Forms

- [ ] Render Admin Input Examples in view-only mode.
- [ ] Render Products and Posts in editable mode.
- [ ] Generate or reuse smart controls:
  - short text input.
  - textarea for body/description.
  - checkbox for booleans.
  - datetime input for date fields.
  - numeric input for int/double.
  - dropdown placeholder for relation-like fields.
- [ ] Show required `*` markers.
- [ ] Validate required fields before save.
- [ ] Save Product/Post edits through protected admin endpoints.
- [ ] Refresh the active table after save.
- [ ] Show save success and failure states.
- [ ] Add widget tests for each control type.
- [ ] Add integration-style tests with mocked admin service responses.
- [ ] Capture screenshot evidence for Product edit and Post edit.
- [ ] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The Flutter app matches the accepted Phase 3 behavior: view-only demo records and editable persistent Product/Post records.
```

## Cycle 5: Generator Integration

- [ ] Decide which parts are generated source and which parts are reusable runtime widgets.
- [ ] Extend the Phase 3 generator to emit Flutter admin screen code usable by `admin_ui/`.
- [ ] Keep generated output deterministic.
- [ ] Add fixture coverage for generated Flutter admin routes/widgets.
- [ ] Avoid copying the temporary static HTML implementation into Flutter directly.
- [ ] Keep PocketBase as product-design inspiration only.
- [ ] Add generator tests for Phase 4 Flutter output.
- [ ] Record validation in `TEST_REPORT.md`.

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
