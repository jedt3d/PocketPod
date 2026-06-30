# PocketPod Flutter Admin UI

Phase 4 turns the validated served admin prototype into a standalone Flutter Web admin app.

The goal is not to replace the Phase 3 generator work. The goal is to host generated CRUD screens inside a real Flutter Web shell that can use the generated Serverpod client package, keep the admin workflow typed, and eventually be built as static files for deployment.

## Phase 4 Outcome

```text
generated admin metadata + pocketpod_client -> Flutter Web admin app -> protected CRUD workflows
```

Expected result:

- a dedicated `pocketpod-starter/admin_ui/` Flutter Web app.
- Serverpod Auth login and logout.
- protected routes for admin users.
- collection navigation for Admin Input Examples, Products, and Posts.
- table, detail, edit, loading, empty, error, and save states.
- generated smart controls matching Phase 3 behavior.
- browser screenshots and validation notes for every cycle.

The current Phase 3 served HTML page remains useful as a fast reference implementation while the Flutter app is built.

## Build And Serve Through Serverpod

Build the Flutter Web admin app into Serverpod's static web app path:

```sh
cd pocketpod-starter
tool/admin_ui/build_serverpod_admin.sh
```

The script writes the bundle to:

```text
pocketpod_server/web/app/
```

When the Serverpod server is running, open:

```text
http://localhost:8082/app/
```

The local default backend API URL is:

```text
http://localhost:8080/
```

For another environment, set `POCKETPOD_API_URL` before building:

```sh
POCKETPOD_API_URL=https://api.example.com/ tool/admin_ui/build_serverpod_admin.sh
```

The planning files for this phase live in `tool/admin_ui/`. The actual Flutter application should live at:

```text
pocketpod-starter/admin_ui/
```
