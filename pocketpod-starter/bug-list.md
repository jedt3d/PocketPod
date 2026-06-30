# Bug List

No tester-reported bugs yet.

## Phase 1 Notes

- Serverpod CLI 3.4.5 generated a Postgres/Auth/Docker-oriented scaffold. Phase 1 converted it to SQLite and removed generated auth until SQLite compatibility is deliberately studied.
- Serverpod runtime 3.4.5 rejected `database.filePath` and required Postgres `host`; Phase 1 now uses local Serverpod `3.5.0-beta.10` package overrides.
- Serverpod `3.5.0-beta.10` SQLite pool used `sqlite_async` defaults for WAL/synchronous and a 30 second lock timeout. Phase 2 changes the local Serverpod pool to explicitly use WAL, `synchronous=NORMAL`, and a 5 second busy timeout.
