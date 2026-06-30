# pocketpod_server

This is the Serverpod backend for PocketPod.

PocketPod is built on [Serverpod](https://serverpod.dev). The current Serverpod baseline is `3.5.0-beta.10`, and PocketPod release tags match that baseline, for example `v3.5.0-beta.10`.

PocketPod was also initially inspired by [PocketBase](https://pocketbase.io), especially its lightweight SQLite deployment feel. PocketBase is not a runtime dependency of this server.

The Phase 1 scaffold is configured for Serverpod's SQLite dialect. It does not
require Docker, Postgres, or Redis.

From this directory, install dependencies and generate Serverpod code:

    dart pub get
    serverpod generate

Then start the server with migrations:

    dart bin/main.dart --apply-migrations

The local SQLite database is stored at:

    .serverpod/development/database.sqlite

Start the server through `dart run` so Dart wires native SQLite assets:

```shell
dart run bin/main.dart --apply-migrations
```
