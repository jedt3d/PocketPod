# Phase 2 Benchmark Results

- Started: `2026-06-30T04:46:30.665702Z`
- Finished: `2026-06-30T04:46:39.179062Z`
- Profile: `production`
- Seed rows per target: `10000`
- Requests per non-smoke run: `1000`
- Tuned Serverpod SQLite readers: `5`
- Serverpod baseline: `3.5.0-beta.10`
- PocketPod release tag: `v0.1.0+serverpod.3.5.0-beta.10`
- PocketBase: `v0.39.5`

## Throughput And P95

| Target | Scenario | C | Requests | Errors | Throughput req/s | p95 ms | p99 ms | DB bytes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| serverpod-sqlite-tuned | smoke | 1 | 25 | 0 | 812.3 | 1.84 | 2.20 | 506576 |
| serverpod-sqlite-tuned | prod-catalog-browse | 50 | 1000 | 0 | 2800.7 | 22.42 | 49.90 | 506576 |
| serverpod-sqlite-tuned | prod-catalog-browse | 75 | 1000 | 0 | 3709.8 | 22.77 | 34.31 | 506576 |
| serverpod-sqlite-tuned | prod-catalog-browse | 100 | 1000 | 0 | 4000.3 | 31.76 | 38.71 | 506576 |
| serverpod-sqlite-tuned | prod-detail-heavy | 50 | 1000 | 0 | 5966.0 | 10.43 | 11.28 | 506576 |
| serverpod-sqlite-tuned | prod-detail-heavy | 75 | 1000 | 0 | 6309.9 | 15.04 | 18.55 | 506576 |
| serverpod-sqlite-tuned | prod-detail-heavy | 100 | 1000 | 0 | 7059.3 | 16.92 | 21.87 | 506576 |
| serverpod-sqlite-tuned | prod-content-commerce | 50 | 1000 | 0 | 7639.2 | 8.00 | 9.77 | 712576 |
| serverpod-sqlite-tuned | prod-content-commerce | 75 | 1000 | 0 | 7839.9 | 13.02 | 14.94 | 955656 |
| serverpod-sqlite-tuned | prod-content-commerce | 100 | 1000 | 0 | 7652.0 | 16.02 | 18.73 | 1235816 |
| serverpod-sqlite-tuned | prod-admin-write | 50 | 1000 | 0 | 8015.2 | 21.82 | 23.30 | 2121616 |
| serverpod-sqlite-tuned | prod-admin-write | 75 | 1000 | 0 | 7960.8 | 30.75 | 32.95 | 3011536 |
| serverpod-sqlite-tuned | prod-admin-write | 100 | 1000 | 0 | 7204.1 | 39.31 | 43.70 | 3922056 |
| serverpod-sqlite-tuned | prod-peak-checkout | 50 | 1000 | 0 | 8626.7 | 15.82 | 16.69 | 4615648 |
| serverpod-sqlite-tuned | prod-peak-checkout | 75 | 1000 | 0 | 8613.2 | 31.67 | 38.10 | 4615648 |
| serverpod-sqlite-tuned | prod-peak-checkout | 100 | 1000 | 0 | 8428.8 | 37.77 | 41.78 | 4615648 |
