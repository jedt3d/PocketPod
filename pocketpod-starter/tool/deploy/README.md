# PocketPod Deployment Tooling

This folder contains Phase 5 tooling for zero-Docker PocketPod deployment.

Build a local release artifact:

```sh
tool/deploy/build_release.sh
```

Smoke-test the release artifact:

```sh
tool/deploy/smoke_release.sh
```

The smoke script starts the compiled release with Serverpod `development` mode on alternate local ports:

```text
API: 18080
Insights: 18081
Web/admin: 18082
SQLite: build/pocketpod-release/.serverpod/smoke/database.sqlite
```

The generated release directory is ignored by git:

```text
build/pocketpod-release/
```

The artifact contains a compiled Dart CLI bundle, native SQLite dynamic libraries, Serverpod config, migrations, static web assets, and an empty `.serverpod/` runtime directory for SQLite files.

Before a real production deploy, copy `config/template.passwords.yaml` to `config/passwords.yaml`, replace every placeholder secret, and review `config/production.yaml` for the public host names.
