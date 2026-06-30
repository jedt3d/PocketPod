# PocketPod Agent Notes

PocketPod is built on [Serverpod](https://serverpod.dev). Preserve that attribution in user-facing documentation.

PocketPod was also initially inspired by [PocketBase](https://pocketbase.io), especially its lightweight SQLite deployment feel. Mention PocketBase as inspiration or benchmark context only; do not describe it as a dependency or part of the PocketPod runtime.

Current Serverpod baseline:

```text
3.5.0-beta.10
```

PocketPod release tags should match the Serverpod baseline version, for example:

```text
v3.5.0-beta.10
```

Use this versioning rule so `serverpod-pocketpod` can be matched directly to the upstream Serverpod version it was copied from. PocketPod-specific changes belong in commits, README notes, and benchmark documentation; the release number identifies the Serverpod baseline.

Repository layout:

```text
pocketpod-starter/       canonical starter app/template
serverpod-pocketpod/     local Serverpod source copy with SQLite tuning
tool/automation/         repository maintenance scripts
```

Do not commit generated local secrets such as:

```text
pocketpod-starter/pocketpod_server/config/passwords.yaml
```

Before changing release tags, check the Serverpod baseline in:

```text
serverpod-pocketpod/SERVERPOD_VERSION
serverpod-pocketpod/packages/serverpod/pubspec.yaml
serverpod-pocketpod/packages/serverpod_database/pubspec.yaml
```
