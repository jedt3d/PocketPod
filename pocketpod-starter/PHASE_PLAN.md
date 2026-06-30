# PocketPod Phase Plan

## Phase 1: Serverpod SQLite Scaffold

Goal:
Create a runnable Serverpod baseline using SQLite instead of Postgres/Docker.

Features:
1. Serverpod server, generated Dart client, and companion Flutter app scaffold.
2. SQLite `database.filePath` config for development, test, staging, and production.
3. Baseline docs, milestone notes, bug list, and CI harness.

Stop condition:
The scaffold starts, applies SQLite migrations, passes the greeting integration test, and analyzes cleanly.

## Phase 2: SQLite Runtime Tuning

Goal:
Make Serverpod open SQLite with PocketBase-style concurrency settings.

Features:
1. Apply WAL, `synchronous=NORMAL`, and `busy_timeout=5000` through Serverpod's SQLite connection pool.
2. Keep read concurrency controlled by `database.maxConnectionCount`.
3. Add integration evidence that Serverpod sessions observe the required PRAGMAs.

Stop condition:
Tests verify the PRAGMAs through `session.db`, and the server starts cleanly with SQLite.

## Phase 2B: SQLite Performance Benchmark Gate

Goal:
Measure Phase 2 tuning before investing in admin generator work.

Features:
1. Build a repeatable local benchmark harness for tuned vs untuned Serverpod SQLite.
2. Measure read-only, write-only, mixed, and burst write workloads across concurrency levels.
3. Record results and a go/no-go recommendation before Phase 3.

Stop condition:
`MILESTONE.md` contains a benchmark table and a decision to continue, tune further, or compare against another baseline.

## Phase 3: Admin UI Generator Tooling

Goal:
Generate admin CRUD UI code from Serverpod `.spy.yaml` models.

Features:
1. Add a Dart CLI script, `yaml_to_admin.dart`, that reads Serverpod model YAML.
2. Map scalar fields and relations to generated Flutter table/form components.
3. Add generator tests using representative model fixtures.

Stop condition:
The generator emits deterministic Flutter source for sample models and has fixture coverage.

## Phase 4: Flutter Admin App

Goal:
Provide a standalone Flutter Web admin app that hosts generated CRUD screens.

Features:
1. Scaffold `admin_ui/` as a Flutter Web project.
2. Wire generated widgets to the Serverpod client package.
3. Add basic navigation, loading, empty, error, create, edit, and delete states.

Stop condition:
The admin app builds for web and can exercise generated CRUD screens against a local Serverpod server.

## Phase 5: Zero-Docker Packaging

Goal:
Package PocketPod for minimal VPS deployment without Docker, Postgres, or Redis.

Features:
1. Compile the Dart server executable.
2. Build the Flutter Web admin UI and serve it statically through Serverpod.
3. Document the deploy artifact layout and add a local smoke script.

Stop condition:
A clean artifact can be built locally and smoke-tested against a SQLite database file.
