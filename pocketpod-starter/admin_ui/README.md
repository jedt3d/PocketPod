# PocketPod Admin UI

This Flutter Web app is the hosted PocketPod admin surface served from Serverpod at `/app/`.

It signs in through Serverpod Auth, stores the returned JWT in browser storage, and calls protected `Scope.admin` endpoints through `pocketpod_client`.

Current Phase 6 behavior:

- Admin Input Examples is a read-only generated-control showcase.
- Products and Posts are writable SQLite-backed collections.
- Writable collections support create, edit, delete, search, and pagination.
- Relation-like fields use server-provided dropdown options.
- Users without `serverpod.admin` scope see an explicit admin-access-required message.

Run local checks from `pocketpod-starter/`:

```sh
flutter analyze
flutter test admin_ui --reporter expanded
```

Build the admin app into Serverpod static web assets:

```sh
tool/admin_ui/build_serverpod_admin.sh
```
