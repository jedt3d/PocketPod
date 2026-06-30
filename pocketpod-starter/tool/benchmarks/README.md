# PocketPod Benchmarks

Runs the Phase 2 local benchmark gate before moving to Phase 3.

Default run:

```sh
dart run tool/benchmarks/run_bench.dart --requests 200 --seed 1000
```

The saved Phase 2 micro baseline used `--sqlite-readers 10`.

Production target run:

```sh
dart run tool/benchmarks/run_bench.dart \
  --profile production \
  --targets serverpod-sqlite-tuned,serverpod-sqlite-untuned
```

Production tuning loop example:

```sh
dart run tool/benchmarks/run_bench.dart \
  --profile production \
  --targets serverpod-sqlite-tuned \
  --sqlite-readers 20
```

Targets:

- `serverpod-sqlite-tuned`: Serverpod SQLite with WAL, `synchronous=NORMAL`, 5s lock timeout, and 10 readers.
- `serverpod-sqlite-untuned`: Serverpod SQLite rollback journal, `synchronous=FULL`, 5s lock timeout, and 1 reader.
- `direct-sqlite-dart`: direct `sqlite_async` access without Serverpod HTTP/RPC overhead.
- `pocketbase-local`: local PocketBase v0.39.5 using its REST API.

The Serverpod targets temporarily rewrite `pocketpod_server/config/development.yaml` to isolate each benchmark database, then restore it after the process exits.

Published markdown summaries live in `tool/benchmarks/results/`. Raw JSON files are generated beside them and ignored by git.

Visual report:

```sh
dart run tool/benchmarks/render_report.dart
```

The generated standalone HTML report is `tool/benchmarks/results/benchmark-report.html`.

Profiles:

- `micro`: original Phase 2 comparison, 1,000 seed rows, 200 requests per scenario, concurrency 1-50.
- `production`: small/medium e-commerce pressure, 10,000 seed rows, 1,000 requests per scenario, concurrency 50/75/100. Scenarios model catalog browsing, product/post detail reads, 95/5 content-commerce traffic, 80/20 admin writes, and 70/30 peak checkout-style writes.
