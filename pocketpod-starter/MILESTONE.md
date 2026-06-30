# Milestone Notes

## Version And Attribution

PocketPod is built on [Serverpod](https://serverpod.dev), and the Serverpod team deserves credit for the framework, runtime, code generation, and project structure this work extends.

Current Serverpod baseline:

```text
3.5.0-beta.10
```

PocketPod release tags match the Serverpod baseline version, such as `v3.5.0-beta.10`, so the `serverpod-pocketpod` source copy can be matched directly to the upstream Serverpod version used for this milestone history.

## Phase 1: Serverpod SQLite Scaffold

Goal:
Initialize a Serverpod project configured for SQLite and no Docker dependency.

Scope:
- Serverpod server, generated Dart client, and companion Flutter app scaffold.
- SQLite `database.filePath` configuration for development, test, staging, and production modes.
- Docker/Postgres/Redis defaults removed from project workflow.
- Local dependency overrides point to the checked-out Serverpod `3.5.0-beta.10` packages because installed Serverpod `3.4.5` does not accept SQLite `database.filePath` runtime config.

Out of scope:
- SQLite PRAGMA tuning. This belongs to Phase 2.
- PocketBase/Admin UI generator. This belongs to later phases.
- Production auth design. The generated Serverpod Auth IDP scaffold was removed because the local Serverpod template gates auth to Postgres.
- Live deployment.

Validation:
- `flutter pub get` completed after auth dependencies were removed.
- `serverpod generate` completed with the installed CLI for endpoint/client code.
- SQLite migration generated with the local Serverpod `3.5.0-beta.10` CLI.
- Direct server probe passed: `dart run bin/main.dart --apply-migrations --mode test --logging verbose` started with `database dialect: sqlite`.
- Server integration test passed: `flutter test` from `pocketpod_server`.
- Workspace analysis passed: `flutter analyze` from the project root.
- Whitespace check passed: `git diff --check`.

## Phase 2: SQLite Runtime Tuning

Goal:
Apply PocketBase-style SQLite runtime tuning through Serverpod's SQLite pool.

Scope:
- Explicit WAL journal mode.
- Explicit `synchronous=NORMAL`.
- Explicit `busy_timeout=5000`.
- Integration evidence through Serverpod's own `session.db`.

Validation:
- Local Serverpod pool test passed: `dart test test/sqlite_pool_manager_test.dart` in `ServerPod/packages/serverpod_database`.
- PocketPod greeting integration test passed: `flutter test test/integration/greeting_endpoint_test.dart`.
- PocketPod SQLite tuning integration test passed: `flutter test test/integration/sqlite_tuning_test.dart`.
- Workspace analysis passed: `flutter analyze` from the PocketPod project root.
- Serverpod database package analysis passed: `dart analyze` from `ServerPod/packages/serverpod_database`.

## Phase 2 Benchmark Gate

Goal:
Compare Phase 2 Serverpod SQLite tuning before starting Phase 3.

Harness:
- Runner: `tool/benchmarks/run_bench.dart`.
- Published result: `tool/benchmarks/results/20260630T043929648866Z.md`.
- Raw result: `tool/benchmarks/results/20260630T043929648866Z.json`.
- Workload: seed 1,000 rows per target; 200 requests per non-smoke scenario.
- Machine: Apple M4 Pro, 14 CPU cores, 24 GB RAM, macOS Darwin 25.5.0 arm64.
- Runtime: Dart 3.12.2 for `dart run`; Flutter 3.41.7 workspace tooling.
- Serverpod source: local `ServerPod` git `fcebaf45c` plus SQLite tuning patch.
- PocketPod source: tracked repository release matching the Serverpod baseline version, `v3.5.0-beta.10`.
- PocketBase: v0.39.5 local binary.

Comparison targets:
- `serverpod-sqlite-tuned`: WAL, `synchronous=NORMAL`, lock timeout 5s, `maxReaders=10`.
- `serverpod-sqlite-untuned`: rollback journal, `synchronous=FULL`, lock timeout 5s, `maxReaders=1`.
- `direct-sqlite-dart`: direct `sqlite_async` baseline, WAL/NORMAL, no Serverpod HTTP/RPC layer.
- `pocketbase-local`: local PocketBase REST API baseline.

Key p95 latency and throughput:

| Target | Scenario | C | Errors | Throughput req/s | p95 ms |
| --- | --- | ---: | ---: | ---: | ---: |
| serverpod-sqlite-tuned | read-only | 10 | 0 | 2793.2 | 4.69 |
| serverpod-sqlite-untuned | read-only | 10 | 0 | 2284.7 | 6.16 |
| direct-sqlite-dart | read-only | 10 | 0 | 24823.1 | 0.64 |
| pocketbase-local | read-only | 10 | 0 | 18331.8 | 0.93 |
| serverpod-sqlite-tuned | write-only | 10 | 0 | 3782.1 | 3.20 |
| serverpod-sqlite-untuned | write-only | 10 | 0 | 2547.3 | 4.46 |
| direct-sqlite-dart | write-only | 10 | 0 | 16471.8 | 0.75 |
| pocketbase-local | write-only | 10 | 0 | 18011.5 | 0.91 |
| serverpod-sqlite-tuned | mixed-80-20 | 10 | 0 | 4699.4 | 2.68 |
| serverpod-sqlite-untuned | mixed-80-20 | 10 | 0 | 3354.5 | 5.44 |
| direct-sqlite-dart | mixed-80-20 | 10 | 0 | 43573.0 | 0.55 |
| pocketbase-local | mixed-80-20 | 10 | 0 | 17995.3 | 0.98 |
| serverpod-sqlite-tuned | burst-writes | 50 | 0 | 5142.6 | 13.01 |
| serverpod-sqlite-untuned | burst-writes | 50 | 0 | 2721.1 | 19.36 |
| direct-sqlite-dart | burst-writes | 50 | 0 | 25335.7 | 2.26 |
| pocketbase-local | burst-writes | 50 | 0 | 19122.3 | 5.15 |

Interpretation:
- The benchmark completed with zero failures across all selected targets and all five scenarios.
- Tuned Serverpod improved over untuned Serverpod in the key write-heavy and mixed gates: write-only C10 p95 3.20 ms vs 4.46 ms, mixed C10 p95 2.68 ms vs 5.44 ms, burst C50 p95 13.01 ms vs 19.36 ms.
- Direct SQLite and PocketBase are much faster than Serverpod in this microbenchmark, which is expected because Serverpod includes HTTP/RPC, generated serialization, session handling, and endpoint dispatch overhead.
- No unexpected lock failures appeared at mixed concurrency 10 or burst-write concurrency 50.

Decision:
Proceed to Phase 3. Keep the Serverpod SQLite tuning and benchmark harness. Treat direct SQLite and PocketBase numbers as overhead baselines, not product-equivalent replacements yet.

## Production Target Benchmark

Goal:
Reframe the benchmark around the intended production shape: a small/medium e-commerce and content site with about 5,000-10,000 combined products/posts/SKUs, supporting roughly 50-100 concurrent users on a 2-4 vCPU, 4 GB RAM host.

Important limitation:
This was still run locally on an Apple M4 Pro with 14 CPU cores and 24 GB RAM. It validates app behavior and SQLite contention under 50-100 concurrent request slots, but it is not a substitute for a real 2-4 vCPU VPS benchmark.

Harness:
- Runner profile: `production`.
- Stable production result: `tool/benchmarks/results/production-target-serverpod.md`.
- Stable production raw result: `tool/benchmarks/results/production-target-serverpod.json`.
- First micro benchmark preserved as: `tool/benchmarks/results/phase2-micro-baseline.md`.
- Production seed: 10,000 rows.
- Production requests: 1,000 per non-smoke scenario.
- Production concurrency levels: 50, 75, 100.

Production scenarios:
- `prod-catalog-browse`: 70% catalog/page list reads, 30% detail reads.
- `prod-detail-heavy`: 90% detail reads, 10% list reads.
- `prod-content-commerce`: 95% reads, 5% content/product writes.
- `prod-admin-write`: 80% reads, 20% admin/content/product writes.
- `prod-peak-checkout`: 70% reads, 30% checkout/order-style writes.

Tuning loop:
- Initial production comparison used tuned Serverpod with 10 readers vs untuned Serverpod with 1 reader.
- Tuned/10 had zero errors, but `prod-admin-write` at C100 reached p95 60.33 ms.
- Tuned/20 improved `prod-peak-checkout` C100 p95 from 42.51 ms to 37.22 ms, but worsened catalog C100 p95 from 30.64 ms to 38.18 ms and left admin C100 at 55.99 ms.
- Tuned/15 was worse than both 10 and 20 for admin C100.
- Tuned/5 was best aligned to the 2-4 vCPU target: zero errors, high throughput, and C100 p95 under 40 ms on every production scenario.

Final production target, tuned Serverpod with 5 SQLite readers:

| Scenario | C | Errors | Throughput req/s | p95 ms | p99 ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| prod-catalog-browse | 50 | 0 | 2800.7 | 22.42 | 49.90 |
| prod-catalog-browse | 100 | 0 | 4000.3 | 31.76 | 38.71 |
| prod-detail-heavy | 50 | 0 | 5966.0 | 10.43 | 11.28 |
| prod-detail-heavy | 100 | 0 | 7059.3 | 16.92 | 21.87 |
| prod-content-commerce | 50 | 0 | 7639.2 | 8.00 | 9.77 |
| prod-content-commerce | 100 | 0 | 7652.0 | 16.02 | 18.73 |
| prod-admin-write | 50 | 0 | 8015.2 | 21.82 | 23.30 |
| prod-admin-write | 100 | 0 | 7204.1 | 39.31 | 43.70 |
| prod-peak-checkout | 50 | 0 | 8626.7 | 15.82 | 16.69 |
| prod-peak-checkout | 100 | 0 | 8428.8 | 37.77 | 41.78 |

Current tuning target:
- Use WAL.
- Use `synchronous=NORMAL`.
- Keep `busy_timeout=5000`.
- Use `maxConnectionCount: 5` as the production starting point for 2-4 vCPU hosts. This is now set in the project SQLite configs.
- Target acceptance on the real VPS: zero lock/server errors at 100 concurrent request slots, p95 under 75 ms for read-heavy traffic, p95 under 150 ms for write-bearing traffic, and stable memory under 4 GB.

Decision:
Proceed toward Phase 3 with Serverpod SQLite, but keep the production target at 5 SQLite readers until a real 2-4 vCPU VPS benchmark proves a higher reader pool is beneficial.
