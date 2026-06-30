# Phase 5 Tasks: Zero-Docker Packaging

Goal:
Package PocketPod for minimal VPS deployment without Docker, Postgres, or Redis.

## Cycle 0: Deployment Baseline

- [x] Confirm Phase 4 Flutter admin app is the hosted UI surface.
- [x] Confirm Serverpod server can be run from the starter server directory.
- [x] Confirm the release must use `dart build cli` because SQLite dependencies use native-assets build hooks.
- [x] Define the release artifact layout.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The packaging path is based on the actual Serverpod/SQLite runtime shape, not an assumed single executable.
```

## Cycle 1: Build Artifact Script

- [x] Add `tool/deploy/build_release.sh`.
- [x] Build the Flutter admin app into `pocketpod_server/web/app`.
- [x] Build the Serverpod executable bundle with native SQLite libraries.
- [x] Copy config, migrations, web assets, and runtime directories into `build/pocketpod-release`.
- [x] Exclude real `config/passwords.yaml` from the generated artifact.
- [x] Generate artifact README and manifest.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
A fresh release artifact can be generated locally with one command.
```

## Cycle 2: SQLite Runtime Layout

- [x] Include `.serverpod/production` in the release artifact.
- [x] Preserve `database.filePath: .serverpod/production/database.sqlite` in the production config.
- [x] Add smoke-test runtime generation for `.serverpod/smoke/database.sqlite` through Serverpod `development` mode on alternate ports.
- [x] Keep generated SQLite files out of git.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The artifact has an explicit local SQLite runtime location and can create a smoke database during validation.
```

## Cycle 3: Smoke Test Script

- [x] Add `tool/deploy/smoke_release.sh`.
- [x] Generate local development-mode smoke config and throwaway smoke secrets inside the ignored release directory.
- [x] Start the compiled release binary with `--apply-migrations`.
- [x] Verify `/app/` is served by the compiled release.
- [x] Verify `/app/assets/assets/config.json` is served by the compiled release.
- [x] Verify the smoke SQLite database file exists.
- [x] Stop the release process after validation.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
The generated release artifact can be started and smoke-tested without Docker.
```

## Cycle 4: VPS Deployment Docs

- [x] Add deployment tooling README.
- [x] Document the release artifact layout.
- [x] Document the production password/config handoff.
- [x] Update the main phase plan.
- [x] Update root and starter READMEs.
- [x] Update `system-summary.md`.
- [x] Record validation in `TEST_REPORT.md`.

Acceptance:

```text
A user can identify how to build, inspect, and smoke-test the no-Docker release artifact.
```

## Backlog Not Blocking Phase 5 Acceptance

- [ ] Add a Linux systemd service template after testing on the target VPS OS.
- [ ] Add SQLite backup/restore scripts.
- [ ] Add a production reverse-proxy example for Caddy or Nginx.
- [ ] Add a packaged admin sysadmin bootstrap command to the release artifact.
