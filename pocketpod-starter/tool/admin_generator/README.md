# PocketPod Admin Generator

This folder is reserved for Phase 3 admin UI generator tooling.

The goal is to generate admin CRUD UI code from Serverpod `.spy.yaml` model files, starting with common e-commerce and CMS models such as products, SKUs, categories, posts, and pages.

## Design Credit

The admin experience may borrow product-design direction from [PocketBase](https://pocketbase.io): fast CRUD navigation, dense table views, clear collection/model editing, and a lightweight local-first feel.

PocketBase is not a PocketPod dependency and is not part of the PocketPod runtime. Treat PocketBase as design inspiration only. Do not copy PocketBase source code, branding, icons, or visual assets unless license and attribution are reviewed separately.

## PocketPod Advantage

PocketBase helped inspire the lightweight collection-admin direction. PocketPod's advantage is that the admin UI is generated from Serverpod `.spy.yaml` models into normal Flutter source.

![PocketPod smart admin generator preview](screenshots/admin-preview.png)

That means the admin UI can stay aligned with:

- Serverpod model definitions.
- generated Dart/Flutter client and server code.
- code review and source control.
- project-specific customization.
- focused Dart tests.

Cycle 2A adds smart field-to-control mapping so generated forms are not just generic text inputs.

## Planned Tooling

```text
yaml_to_admin.dart     reads Serverpod model YAML and generates admin code
../admin/              Serverpod Auth bootstrap tooling for the first sysadmin
fixtures/              representative model YAML fixtures
generated/             sample generated Dart and HTML preview output
screenshots/           browser screenshot evidence for generated preview
test/                  generator output tests
TEST_REPORT.md         cycle-by-cycle validation report
```

## Phase 3 Acceptance Target

```text
Given sample Serverpod model YAML files, the generator emits predictable Flutter admin source, and tests verify the output.
```

## Development Cycle

Phase 3 is built in small reviewable slices:

1. Task ledger and test report.
2. YAML model parser and deterministic admin source generator.
3. CLI wrapper with fixture-based tests.
4. Generated admin preview and screenshot evidence.
5. Smart form-control mapping for text, long text, boolean, datetime, enum, and relation-like fields.
6. Serverpod Auth/sysadmin bootstrap slice.
7. Admin endpoint guard generation and auth tests.
8. Real served admin screen with protected collection browsing.
9. Persistent Product/Post record editing, with every collection opening records from its primary field.

## Sysadmin Bootstrap Checkpoint

Cycle 3 starts with a validated command surface:

```sh
dart run tool/admin/create_sysadmin.dart \
  --email admin@example.com \
  --password 'Strong-pass-123' \
  --dry-run
```

The command also supports environment variables for deployment scripts:

```sh
POCKETPOD_ADMIN_EMAIL=admin@example.com \
POCKETPOD_ADMIN_PASSWORD='Strong-pass-123' \
dart run tool/admin/create_sysadmin.dart --dry-run
```

The first checkpoint validates inputs only. The next Cycle 3 slice will connect this command to Serverpod Auth tables so the same command can create or report the first `Scope.admin` sysadmin.

## Smart Form-Control Direction

The admin generator should not render every field as a plain text input. Before the Serverpod Auth bootstrap cycle, the generator should classify fields into practical controls:

```text
String short text     -> text input
long text/body fields -> textarea
bool                  -> checkbox/switch
DateTime              -> datetime selector
int/double            -> numeric input
enum/choice           -> dropdown/select
foreign key/relation  -> dropdown/select placeholder
```

Required fields should be visible to the admin user. Non-nullable fields should show a red `*` marker in labels, while nullable fields should show an optional affordance.

The first implementation can use deterministic schema-only heuristics, for example `body`, `description`, and `content` as textarea fields, and `categoryId` or `authorId` as relation dropdown placeholders. Later phases can replace heuristics with explicit metadata or live lookup data.

## Example Control Matrix

The `AdminInputExample` fixture shows the current Cycle 2A control coverage:

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
