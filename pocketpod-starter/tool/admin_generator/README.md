# PocketPod Admin Generator

This folder is reserved for Phase 3 admin UI generator tooling.

The goal is to generate admin CRUD UI code from Serverpod `.spy.yaml` model files, starting with common e-commerce and CMS models such as products, SKUs, categories, posts, and pages.

## Design Credit

The admin experience may borrow product-design direction from [PocketBase](https://pocketbase.io): fast CRUD navigation, dense table views, clear collection/model editing, and a lightweight local-first feel.

PocketBase is not a PocketPod dependency and is not part of the PocketPod runtime. Treat PocketBase as design inspiration only. Do not copy PocketBase source code, branding, icons, or visual assets unless license and attribution are reviewed separately.

## Planned Tooling

```text
yaml_to_admin.dart     reads Serverpod model YAML and generates admin code
fixtures/              representative model YAML fixtures
test/                  generator output tests
```

## Phase 3 Acceptance Target

```text
Given sample Serverpod model YAML files, the generator emits predictable Flutter admin source, and tests verify the output.
```
