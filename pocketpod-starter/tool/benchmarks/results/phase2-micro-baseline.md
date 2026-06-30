# Phase 2 Benchmark Results

- Started: `2026-06-30T04:39:29.648866Z`
- Finished: `2026-06-30T04:39:47.645401Z`
- Seed rows per target: `1000`
- Requests per non-smoke run: `200`
- Serverpod baseline: `3.5.0-beta.10`
- PocketPod release tag: `v0.1.0+serverpod.3.5.0-beta.10`
- PocketBase: `v0.39.5`

## Throughput And P95

| Target | Scenario | C | Requests | Errors | Throughput req/s | p95 ms | p99 ms | DB bytes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| serverpod-sqlite-tuned | smoke | 1 | 25 | 0 | 652.1 | 2.19 | 2.40 | 263496 |
| serverpod-sqlite-tuned | read-only | 1 | 200 | 0 | 1050.7 | 1.41 | 1.51 | 263496 |
| serverpod-sqlite-tuned | read-only | 5 | 200 | 0 | 2061.0 | 4.43 | 5.58 | 263496 |
| serverpod-sqlite-tuned | read-only | 10 | 200 | 0 | 2793.2 | 4.69 | 5.53 | 263496 |
| serverpod-sqlite-tuned | read-only | 25 | 200 | 0 | 2847.5 | 11.38 | 17.39 | 263496 |
| serverpod-sqlite-tuned | read-only | 50 | 200 | 0 | 2760.3 | 26.86 | 31.68 | 263496 |
| serverpod-sqlite-tuned | write-only | 1 | 200 | 0 | 1891.6 | 0.69 | 0.79 | 1136936 |
| serverpod-sqlite-tuned | write-only | 5 | 200 | 0 | 3334.6 | 2.11 | 2.29 | 2018616 |
| serverpod-sqlite-tuned | write-only | 10 | 200 | 0 | 3782.1 | 3.20 | 3.32 | 2900296 |
| serverpod-sqlite-tuned | write-only | 25 | 200 | 0 | 3849.9 | 7.35 | 9.30 | 3773736 |
| serverpod-sqlite-tuned | write-only | 50 | 200 | 0 | 3815.1 | 18.10 | 21.05 | 4369888 |
| serverpod-sqlite-tuned | mixed-80-20 | 1 | 200 | 0 | 2201.4 | 0.60 | 0.73 | 4369888 |
| serverpod-sqlite-tuned | mixed-80-20 | 5 | 200 | 0 | 4903.6 | 1.52 | 1.62 | 4369888 |
| serverpod-sqlite-tuned | mixed-80-20 | 10 | 200 | 0 | 4699.4 | 2.68 | 2.81 | 4369888 |
| serverpod-sqlite-tuned | mixed-80-20 | 25 | 200 | 0 | 5033.7 | 17.26 | 19.13 | 4369888 |
| serverpod-sqlite-tuned | mixed-80-20 | 50 | 200 | 0 | 4646.2 | 23.50 | 29.30 | 4369888 |
| serverpod-sqlite-tuned | burst-writes | 10 | 200 | 0 | 4848.5 | 2.41 | 3.06 | 4369888 |
| serverpod-sqlite-tuned | burst-writes | 25 | 200 | 0 | 5369.3 | 5.38 | 6.40 | 4369888 |
| serverpod-sqlite-tuned | burst-writes | 50 | 200 | 0 | 5142.6 | 13.01 | 14.49 | 4369888 |
| serverpod-sqlite-untuned | smoke | 1 | 25 | 0 | 699.2 | 1.97 | 7.17 | 188416 |
| serverpod-sqlite-untuned | read-only | 1 | 200 | 0 | 1156.3 | 1.28 | 1.87 | 188416 |
| serverpod-sqlite-untuned | read-only | 5 | 200 | 0 | 1838.9 | 5.40 | 7.44 | 188416 |
| serverpod-sqlite-untuned | read-only | 10 | 200 | 0 | 2284.7 | 6.16 | 6.99 | 188416 |
| serverpod-sqlite-untuned | read-only | 25 | 200 | 0 | 2916.4 | 11.05 | 13.99 | 188416 |
| serverpod-sqlite-untuned | read-only | 50 | 200 | 0 | 2667.8 | 24.77 | 28.32 | 188416 |
| serverpod-sqlite-untuned | write-only | 1 | 200 | 0 | 1431.9 | 0.93 | 1.05 | 192512 |
| serverpod-sqlite-untuned | write-only | 5 | 200 | 0 | 2517.0 | 2.27 | 2.33 | 200704 |
| serverpod-sqlite-untuned | write-only | 10 | 200 | 0 | 2547.3 | 4.46 | 4.66 | 208896 |
| serverpod-sqlite-untuned | write-only | 25 | 200 | 0 | 1923.2 | 35.45 | 36.00 | 212992 |
| serverpod-sqlite-untuned | write-only | 50 | 200 | 0 | 2587.3 | 20.32 | 23.24 | 221184 |
| serverpod-sqlite-untuned | mixed-80-20 | 1 | 200 | 0 | 2394.1 | 0.69 | 0.76 | 221184 |
| serverpod-sqlite-untuned | mixed-80-20 | 5 | 200 | 0 | 4400.3 | 1.50 | 2.20 | 221184 |
| serverpod-sqlite-untuned | mixed-80-20 | 10 | 200 | 0 | 3354.5 | 5.44 | 7.32 | 221184 |
| serverpod-sqlite-untuned | mixed-80-20 | 25 | 200 | 0 | 3348.2 | 10.44 | 12.21 | 221184 |
| serverpod-sqlite-untuned | mixed-80-20 | 50 | 200 | 0 | 3825.4 | 20.47 | 23.25 | 225280 |
| serverpod-sqlite-untuned | burst-writes | 10 | 200 | 0 | 2866.9 | 3.94 | 4.41 | 229376 |
| serverpod-sqlite-untuned | burst-writes | 25 | 200 | 0 | 2843.9 | 8.91 | 11.06 | 237568 |
| serverpod-sqlite-untuned | burst-writes | 50 | 200 | 0 | 2721.1 | 19.36 | 20.84 | 245760 |
| direct-sqlite-dart | smoke | 1 | 25 | 0 | 8680.6 | 0.18 | 0.22 | 135776 |
| direct-sqlite-dart | read-only | 1 | 200 | 0 | 11212.0 | 0.14 | 0.20 | 135776 |
| direct-sqlite-dart | read-only | 5 | 200 | 0 | 22888.5 | 0.35 | 0.57 | 135776 |
| direct-sqlite-dart | read-only | 10 | 200 | 0 | 24823.1 | 0.64 | 0.88 | 135776 |
| direct-sqlite-dart | read-only | 25 | 200 | 0 | 27812.5 | 1.13 | 1.18 | 135776 |
| direct-sqlite-dart | read-only | 50 | 200 | 0 | 27933.0 | 2.15 | 2.24 | 135776 |
| direct-sqlite-dart | write-only | 1 | 200 | 0 | 14982.4 | 0.10 | 0.16 | 1874416 |
| direct-sqlite-dart | write-only | 5 | 200 | 0 | 16700.1 | 0.38 | 0.44 | 3621296 |
| direct-sqlite-dart | write-only | 10 | 200 | 0 | 16471.8 | 0.75 | 2.34 | 4206048 |
| direct-sqlite-dart | write-only | 25 | 200 | 0 | 19878.7 | 1.47 | 1.48 | 4206048 |
| direct-sqlite-dart | write-only | 50 | 200 | 0 | 18426.4 | 3.29 | 3.53 | 4222432 |
| direct-sqlite-dart | mixed-80-20 | 1 | 200 | 0 | 25150.9 | 0.06 | 0.07 | 4222432 |
| direct-sqlite-dart | mixed-80-20 | 5 | 200 | 0 | 48030.7 | 0.16 | 0.26 | 4222432 |
| direct-sqlite-dart | mixed-80-20 | 10 | 200 | 0 | 43573.0 | 0.55 | 0.71 | 4222432 |
| direct-sqlite-dart | mixed-80-20 | 25 | 200 | 0 | 48673.6 | 1.75 | 1.97 | 4222432 |
| direct-sqlite-dart | mixed-80-20 | 50 | 200 | 0 | 42909.2 | 2.44 | 2.73 | 4222432 |
| direct-sqlite-dart | burst-writes | 10 | 200 | 0 | 23955.0 | 0.52 | 0.53 | 4222432 |
| direct-sqlite-dart | burst-writes | 25 | 200 | 0 | 22550.5 | 1.95 | 1.96 | 4238816 |
| direct-sqlite-dart | burst-writes | 50 | 200 | 0 | 25335.7 | 2.26 | 2.29 | 4238816 |
| pocketbase-local | smoke | 1 | 25 | 0 | 4515.1 | 0.37 | 0.42 | 4402656 |
| pocketbase-local | read-only | 1 | 200 | 0 | 5196.8 | 0.29 | 0.37 | 4402656 |
| pocketbase-local | read-only | 5 | 200 | 0 | 13031.9 | 0.69 | 2.04 | 4402656 |
| pocketbase-local | read-only | 10 | 200 | 0 | 18331.8 | 0.93 | 2.56 | 4402656 |
| pocketbase-local | read-only | 25 | 200 | 0 | 15345.7 | 7.53 | 10.17 | 4402656 |
| pocketbase-local | read-only | 50 | 200 | 0 | 16818.0 | 4.90 | 5.69 | 4402656 |
| pocketbase-local | write-only | 1 | 200 | 0 | 5297.3 | 0.28 | 0.41 | 4402656 |
| pocketbase-local | write-only | 5 | 200 | 0 | 14207.6 | 0.56 | 1.77 | 4443616 |
| pocketbase-local | write-only | 10 | 200 | 0 | 18011.5 | 0.91 | 1.39 | 4443616 |
| pocketbase-local | write-only | 25 | 200 | 0 | 13379.7 | 3.64 | 4.16 | 4484576 |
| pocketbase-local | write-only | 50 | 200 | 0 | 12482.1 | 10.07 | 11.11 | 4484576 |
| pocketbase-local | mixed-80-20 | 1 | 200 | 0 | 5170.8 | 0.35 | 0.42 | 4484576 |
| pocketbase-local | mixed-80-20 | 5 | 200 | 0 | 16185.2 | 0.54 | 0.71 | 4484576 |
| pocketbase-local | mixed-80-20 | 10 | 200 | 0 | 17995.3 | 0.98 | 1.30 | 4484576 |
| pocketbase-local | mixed-80-20 | 25 | 200 | 0 | 14204.5 | 5.94 | 8.47 | 4715080 |
| pocketbase-local | mixed-80-20 | 50 | 200 | 0 | 8386.8 | 18.62 | 22.51 | 4715080 |
| pocketbase-local | burst-writes | 10 | 200 | 0 | 15719.6 | 1.39 | 2.16 | 4715080 |
| pocketbase-local | burst-writes | 25 | 200 | 0 | 16501.7 | 2.96 | 3.50 | 4760136 |
| pocketbase-local | burst-writes | 50 | 200 | 0 | 19122.3 | 5.15 | 7.81 | 4760136 |
