# PocketPod Phase Plan

## Version And Attribution

PocketPod is built on [Serverpod](https://serverpod.dev). Serverpod remains the backend framework; PocketPod adds the SQLite starter configuration, tuning patch, and benchmark workflow.

PocketPod was also initially inspired by [PocketBase](https://pocketbase.io), especially its lightweight SQLite deployment feel. PocketBase is not part of the PocketPod runtime; it is referenced as inspiration and as an optional benchmark comparison.

PocketPod version:

```text
0.1.0
```

Compatible Serverpod baseline:

```text
3.5.0-beta.10
```

PocketPod release tags use the PocketPod version plus Serverpod compatibility metadata, for example `v0.1.0+serverpod.3.5.0-beta.10`, so each release can show PocketPod progress while still identifying its Serverpod source baseline.

## ✅ Phase 1: Serverpod SQLite Scaffold

Goal:
Create a runnable Serverpod baseline using SQLite instead of Postgres/Docker.

Features:
1. ✅ Serverpod server, generated Dart client, and companion Flutter app scaffold.
2. ✅ SQLite `database.filePath` config for development, test, staging, and production.
3. ✅ Baseline docs, milestone notes, bug list, and CI harness.

Stop condition:
✅ The scaffold starts, applies SQLite migrations, passes the greeting integration test, and analyzes cleanly.

## ✅ Phase 2: SQLite Runtime Tuning

Goal:
Make Serverpod open SQLite with PocketBase-style concurrency settings.

Features:
1. ✅ Apply WAL, `synchronous=NORMAL`, and `busy_timeout=5000` through Serverpod's SQLite connection pool.
2. ✅ Keep read concurrency controlled by `database.maxConnectionCount`.
3. ✅ Add integration evidence that Serverpod sessions observe the required PRAGMAs.

Stop condition:
✅ Tests verify the PRAGMAs through `session.db`, and the server starts cleanly with SQLite.

## ✅ Phase 2B: SQLite Performance Benchmark Gate

Goal:
Measure Phase 2 tuning before investing in admin generator work.

Features:
1. ✅ Build a repeatable local benchmark harness for tuned vs untuned Serverpod SQLite.
2. ✅ Measure read-only, write-only, mixed, and burst write workloads across concurrency levels.
3. ✅ Record results and a go/no-go recommendation before Phase 3.
4. ✅ Compare tuned Serverpod SQLite against untuned Serverpod SQLite, PocketBase local, and direct SQLite Dart.
5. ✅ Add production-shaped scenarios for 50-100 concurrent users, 5,000-10,000 content rows, and a 2-4 vCPU / 4 GB RAM target.
6. ✅ Preserve benchmark outputs and generate an HTML chart report with contrast colors and hover values.

Stop condition:
✅ `MILESTONE.md` contains benchmark tables, production-target results, and a decision to proceed toward Phase 3 with `maxConnectionCount: 5` as the starting production setting.

## Phase 3: Admin UI Generator Tooling

Goal:
Generate admin CRUD UI code from Serverpod `.spy.yaml` models, protected by Serverpod-style authentication and admin scopes.

Phase 3 should be the first PocketPod-specific product layer beyond SQLite tuning. The concrete outcome is:

```text
Serverpod model YAML -> generated admin CRUD code -> admin-only access convention
```

PocketPod should keep authentication inside the Serverpod ecosystem. It should not create a separate PocketPod user/session/token system. The PocketPod addition is a bootstrap helper and conventions around Serverpod Auth.

Authentication direction:
1. Use Serverpod Auth as the source of truth for users, sessions, profiles, and scopes.
2. Use Serverpod's `AuthUser`, `UserProfile`, identity providers, server-side sessions/JWT support, and `session.authenticated`.
3. Protect generated admin endpoints with `requireLogin` and `Scope.admin`.
4. Add a first-sysadmin bootstrap command:

```sh
dart run tool/admin/create_sysadmin.dart \
  --email admin@example.com \
  --password "change-me-now"
```

5. Also support environment-variable based bootstrap for production and scripts:

```sh
POCKETPOD_ADMIN_EMAIL=admin@example.com \
POCKETPOD_ADMIN_PASSWORD='strong-password' \
dart run tool/admin/create_sysadmin.dart
```

6. Refuse unsafe behavior by default:
   - do not overwrite an existing admin password unless `--force` is passed.
   - do not create more than one primary sysadmin unless `--allow-additional-admin` is passed.
   - do not accept weak placeholder passwords in production mode.
   - do not expose first-admin creation as a public unauthenticated API endpoint.

Recommended Serverpod-style endpoint guard:

```dart
class ProductAdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  Future<void> createProduct(Session session) async {
    // Only signed-in admin users can call this.
  }
}
```

Bootstrap implementation notes to validate against Serverpod `3.5.0-beta.10`:
1. Add Serverpod auth packages back into the PocketPod starter only after verifying SQLite migrations still run cleanly.
2. Initialize auth services in `pocketpod_server/lib/server.dart`, starting with email auth and one token strategy.
3. Use Serverpod Auth APIs for bootstrap rather than inserting rows manually.
4. Research-confirmed local API surfaces in the pinned source include:
   - `AuthServices.instance.authUsers.create(session, scopes: {Scope.admin})`
   - `AuthServices.instance.authUsers.update(session, authUserId: authUserId, scopes: {Scope.admin})`
   - `AuthServices.instance.userProfiles.createUserProfile(...)`
   - `EmailIdp.admin.createEmailAuthentication(...)`
   - `EmailIdp.admin.findAccount(...)`
   - `EmailIdp.admin.setPassword(...)`
5. Wrap bootstrap user creation, email auth creation, profile creation, and scope assignment in a database transaction.
6. Make the script idempotent:
   - if the email does not exist, create `AuthUser`, `UserProfile`, email authentication, and assign `Scope.admin`.
   - if the email exists without admin scope, promote it only with an explicit flag such as `--promote-existing`.
   - if the email exists and is already admin, report success without changing the password unless `--force-password-reset` is passed.
7. Log only safe operational messages. Never print the supplied password or generated secrets.
8. Add tests for success, duplicate email, weak password rejection, existing-admin detection, promotion behavior, and non-admin endpoint rejection.

Optional PocketPod-specific admin metadata:

```yaml
class: AdminProfile
table: pocketpod_admin_profile
fields:
  authUser: module:serverpod_auth_core:AuthUser?, relation(onDelete=Cascade)
  displayName: String
  isPrimaryOwner: bool
```

This table can store PocketPod admin UI preferences or ownership metadata, but it must not replace Serverpod Auth as the login/session/scope authority.

Features:
1. ✅ Add a Dart CLI script, `yaml_to_admin.dart`, that reads Serverpod model YAML.
2. ✅ Parse representative Serverpod `.spy.yaml` model fixtures into deterministic admin metadata.
3. ✅ Generate deterministic Flutter admin source from sample models.
4. ✅ Generate a static HTML admin preview artifact for review.
5. ✅ Capture screenshot evidence for the generated admin preview.
6. ✅ Use PocketBase as admin UX inspiration for fast CRUD navigation, dense data tables, clear model/collection editing, and lightweight local-first ergonomics.
7. ✅ Add PocketBase credit in the admin generator folder README and keep the root README credit updated.
8. ✅ Map scalar fields and relation-like fields to generated Flutter table/form components.
9. ✅ Add smart form-control mapping so generated forms no longer render every field as a plain text input.
10. ✅ Add generator tests using representative model fixtures.
11. ✅ Add `tool/admin/create_sysadmin.dart` for first-admin bootstrap using Serverpod Auth.
12. ✅ Reintroduce and validate Serverpod Auth dependencies against the SQLite PocketPod starter.
13. ✅ Generate or document admin endpoint guards using `requireLogin` and `Scope.admin`.
14. ✅ Add auth tests proving unauthenticated and non-admin users cannot call generated admin endpoints.
15. ✅ Add a served admin screen that logs in through Serverpod Auth and calls protected admin endpoints.
16. ✅ Add clickable collection browsing for Admin Input Examples, Products, and Posts.
17. ✅ Return server-provided sample rows through protected admin collection endpoints.
18. ✅ Build persistent Product and Post sample models backed by SQLite.
19. ✅ Add protected edit endpoints and admin forms for updating records.
20. ✅ Add tests proving admin edits persist and non-admin edits are rejected.
21. Capture browser screenshot/manual acceptance evidence for the new edit flow.

Cycle 2A completed generator advantage:
PocketPod now has schema-driven smart form-control mapping before the auth bootstrap work starts. The `AdminInputExample` fixture demonstrates text input, textarea, checkbox, datetime selector placeholder, integer input, decimal input, enum dropdown placeholder, relation dropdown placeholder, array/list placeholder, red required `*` markers, and optional markers. This is a PocketPod-specific advantage over the original PocketBase-inspired baseline because the controls are generated from Serverpod model definitions into typed Flutter source and a reviewable preview. The current screenshot is embedded in both the root `README.md` and `pocketpod-starter/README.md`.

Cycle 2A completed controls:
1. ✅ `String` short fields render as single-line text inputs.
2. ✅ Long text fields such as `body`, `description`, `content`, `excerpt`, `notes`, and `summary` render as textarea-style controls.
3. ✅ `bool` fields render as checkbox controls.
4. ✅ `DateTime` fields render as datetime selector placeholders in the HTML preview and generated Flutter source.
5. ✅ `int` and `double` fields render as numeric controls.
6. ✅ Enum-like fields render as dropdown/select placeholders when the generator can infer finite choices.
7. ✅ Foreign-key-like fields such as `categoryId`, `authorId`, `productId`, and relation fields render as dropdown/select placeholders until live lookup data exists.
8. ✅ Required non-nullable fields show a red `*` marker.
9. ✅ Nullable fields show an optional affordance in the preview.
10. ✅ The generated preview and screenshot demonstrate the control matrix in one reviewable place.

Cycle 2A current control matrix:

| Field | Serverpod Type | Required | Generated Control |
| --- | --- | --- | --- |
| `title` | `String` | yes | text input |
| `body` | `String` | yes | textarea |
| `summary` | `String?` | no | optional textarea |
| `published` | `bool` | yes | checkbox |
| `publishedAt` | `DateTime?` | no | optional datetime selector |
| `stock` | `int` | yes | integer number input |
| `price` | `double` | yes | decimal number input |
| `status` | `PublishStatus` | yes | enum dropdown placeholder |
| `categoryId` | `int` | yes | relation dropdown placeholder |
| `tags` | `List<String>?` | no | optional array/list placeholder |

Design credit rule:
PocketBase can guide the admin interaction model, but PocketPod should not copy PocketBase source code, branding, icons, or visual assets unless license and attribution are reviewed separately.

Stop condition:
The generator emits deterministic Flutter source for sample models, has fixture coverage, includes PocketBase inspiration credit in the admin generator folder, and has a working Serverpod Auth bootstrap path for creating the first `Scope.admin` sysadmin.

Phase 3 acceptance gate:
1. `dart run tool/admin/create_sysadmin.dart --email admin@example.com --password "change-me-now"` creates or reports a sysadmin deterministically in local development.
2. Generated admin endpoint examples require login and `Scope.admin`.
3. Tests prove unauthenticated callers are rejected.
4. Tests prove signed-in non-admin callers are rejected.
5. Tests prove signed-in admin callers can reach generated admin endpoint methods.
6. `serverpod generate`, server tests, and workspace analysis pass after auth is reintroduced.
7. Auth migrations work with SQLite in the PocketPod starter.
8. ✅ Cycle 4A accepted: a real admin screen can log in, browse collections, and view Product/Post sample rows.
9. ✅ Cycle 4B first slice: admin users can edit persistent SQLite-backed Product/Post records through smart generated controls.
10. Cycle 4B remaining gate: capture browser screenshot/manual acceptance evidence for the new edit flow.

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
