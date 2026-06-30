# PocketPod System Summary

## What Is PocketPod?

PocketPod is a lightweight Serverpod-based backend starter direction for small e-commerce and CMS websites.

The simplest description is:

> PocketPod is a tuned Serverpod + SQLite starter backend for small e-commerce/CMS websites.

It is not a replacement for Serverpod. It is also not a new backend framework. PocketPod starts from normal Serverpod, keeps the Serverpod programming model, and changes the deployment/database profile so a small project can use a single SQLite database file instead of requiring the usual Postgres/Docker-style setup from the beginning.

The project is trying to bring some of the lightweight deployment feel people like from tools such as PocketBase, but without leaving the Serverpod ecosystem. The intent is:

- keep Serverpod endpoints, generated protocol code, migrations, and Dart/Flutter workflow.
- use SQLite for a simpler early production deployment.
- tune SQLite explicitly instead of relying on accidental defaults.
- benchmark the result against a realistic small e-commerce/CMS traffic profile.
- keep a clear path to move upward later if the project outgrows SQLite.

At the current stage, PocketPod is best described as:

```text
Serverpod + SQLite tuning patch + app configuration + benchmark harness
```

It is not yet:

- a standalone server.
- a separate database.
- a Serverpod replacement.
- a Serverpod plugin package.
- a one-command project template.
- PocketBase.

## What We Actually Changed

The current implementation is a focused local extension, not a new package.

In the local Serverpod source tree, we patched the existing SQLite pool manager so SQLite opens with explicit tuning:

```dart
SqliteOptions(
  journalMode: SqliteJournalMode.wal,
  synchronous: SqliteSynchronous.normal,
  lockTimeout: const Duration(seconds: 5),
  maxReaders: maxReaders,
)
```

In the PocketPod application, we configured the generated Serverpod app for SQLite:

```yaml
database:
  filePath: .serverpod/development/database.sqlite
  maxConnectionCount: 5
```

We also added benchmark tooling:

```text
tool/benchmarks/run_bench.dart
tool/benchmarks/render_report.dart
tool/benchmarks/results/benchmark-report.html
```

So if someone asks whether this is a new package, the accurate answer is:

> Not yet. Today PocketPod is a Serverpod project profile and tuning approach: a small Serverpod SQLite adapter patch, app-level SQLite configuration, and benchmark tooling. It could become a reusable package or project template later.

## How To Explain PocketPod To Other People

Short version:

> PocketPod is a tuned Serverpod + SQLite starter backend for small e-commerce/CMS websites.

More complete version:

> PocketPod is not a new server framework. It is a Serverpod-based backend starter profile that uses a tuned SQLite runtime and benchmark tooling to make Serverpod practical for lightweight single-server e-commerce and CMS deployments.

Product-positioning version:

> PocketPod brings a PocketBase-like lightweight local deployment style to Serverpod by pairing Serverpod with tuned SQLite and production-oriented benchmarks.

Technical version:

> PocketPod is Serverpod running with an explicitly tuned SQLite pool: WAL mode, `synchronous=NORMAL`, a 5-second busy timeout, and a conservative reader pool sized for 2-4 vCPU hosts. It includes benchmark scenarios for catalog browsing, content reads, admin writes, and checkout-style write pressure.

## Production Goal

Support a small/medium e-commerce and CMS website:

- 50-100 concurrent users.
- 2-4 vCPU server.
- 4 GB RAM.
- 5,000-10,000 combined products, posts, and SKUs.
- Read-heavy website traffic with some admin/content/product writes and checkout/order-style writes.

## Current Architecture

```text
                         Internet / Users
                               |
                               v
                    +----------------------+
                    |  Browser / Website   |
                    |  E-commerce + CMS    |
                    +----------+-----------+
                               |
                               | HTTPS / HTTP
                               v
                    +----------------------+
                    | Reverse Proxy        |
                    | Nginx / Caddy / etc. |
                    | 80 / 443             |
                    +----------+-----------+
                               |
                               | forwards API traffic
                               v
+------------------------------------------------------------------+
|                         PocketPod VPS                            |
|                                                                  |
|  +-------------------------+                                     |
|  | Serverpod API Server    |                                     |
|  | Port: 8080              | <--- main app/API requests          |
|  |                         |                                     |
|  | Endpoints:              |                                     |
|  | - products / SKUs       |                                     |
|  | - posts / CMS           |                                     |
|  | - admin writes          |                                     |
|  | - checkout/order flow   |                                     |
|  +-----------+-------------+                                     |
|              |                                                   |
|              | SQLite queries                                    |
|              v                                                   |
|  +-------------------------+                                     |
|  | SQLite Database File    |                                     |
|  | WAL mode                |                                     |
|  | synchronous=NORMAL      |                                     |
|  | busy_timeout=5000       |                                     |
|  | maxConnectionCount=5    |                                     |
|  +-------------------------+                                     |
|                                                                  |
|  +-------------------------+                                     |
|  | Serverpod Web Server    |                                     |
|  | Port: 8082              | <--- optional static/web assets     |
|  +-------------------------+                                     |
|                                                                  |
|  +-------------------------+                                     |
|  | Serverpod Insights      |                                     |
|  | Port: 8081              | <--- logs / metrics / diagnostics   |
|  +-------------------------+                                     |
|                                                                  |
+------------------------------------------------------------------+
```

## Ports

Production-facing ports:

```text
Reverse proxy       : 80 / 443
Serverpod API       : 8080
Serverpod Insights  : 8081
Serverpod Web       : 8082
```

Local benchmark ports:

```text
Serverpod API       : 18080
Serverpod Insights  : 18081
Serverpod Web       : 18082
PocketBase compare  : 18090
```

## SQLite Tuning Target

Current production starting point:

```text
journal_mode        : WAL
synchronous         : NORMAL
busy_timeout        : 5000 ms
maxConnectionCount  : 5
```

Rationale:

- WAL allows readers and one writer to cooperate better than rollback journal mode.
- `synchronous=NORMAL` is a common WAL-mode performance/durability tradeoff.
- `busy_timeout=5000` makes concurrent writes wait instead of failing immediately on locks.
- `maxConnectionCount=5` performed best for the intended 2-4 vCPU production target in the local production benchmark.

## Benchmark Summary

Saved benchmark reports:

- `tool/benchmarks/results/phase2-micro-baseline.md`
- `tool/benchmarks/results/phase2-micro-baseline.json`
- `tool/benchmarks/results/production-target-serverpod.md`
- `tool/benchmarks/results/production-target-serverpod.json`
- `tool/benchmarks/results/benchmark-report.html`

The HTML report has tabs, charts, hover labels, and tables for each benchmark scenario.

## P95 Interpretation

P95 means 95th percentile latency.

If p95 is `40 ms`, then 95% of requests completed in 40 ms or less. The slowest 5% took longer.

For this project:

- Lower p95 is better.
- Watch the production C100 results first, because 100 concurrent request slots are the top of the stated target.
- Also confirm error count stays at `0`.

## Production Benchmark Result

The production benchmark used:

- 10,000 seeded rows.
- 1,000 requests per scenario.
- concurrency levels 50, 75, and 100.
- tuned Serverpod SQLite with 5 readers.

Final C100 results:

| Scenario | C | Errors | Throughput req/s | p95 ms |
| --- | ---: | ---: | ---: | ---: |
| prod-catalog-browse | 100 | 0 | 4000.3 | 31.76 |
| prod-detail-heavy | 100 | 0 | 7059.3 | 16.92 |
| prod-content-commerce | 100 | 0 | 7652.0 | 16.02 |
| prod-admin-write | 100 | 0 | 7204.1 | 39.31 |
| prod-peak-checkout | 100 | 0 | 8428.8 | 37.77 |

Interpretation:

- The local benchmark supports the request scenario with zero errors.
- The worst production C100 p95 was about `39 ms`.
- This is healthy for backend response time.

Important caveat:

The benchmark was run on a local Apple M4 Pro, not on the intended 2-4 vCPU / 4 GB VPS. The architecture looks viable, but the same production benchmark should be rerun on the actual server size before treating it as production capacity.

## Current Decision

Proceed with Serverpod SQLite for the next phase.

Keep:

- WAL.
- `synchronous=NORMAL`.
- `busy_timeout=5000`.
- `maxConnectionCount=5`.

Acceptance target for a real 2-4 vCPU / 4 GB VPS:

- zero lock/server errors at 100 concurrent request slots.
- p95 under 75 ms for read-heavy traffic.
- p95 under 150 ms for write-bearing traffic.
- stable memory usage under 4 GB.

## How PocketPod Works With ServerPod

One of the questions we clarified was whether PocketPod is a new server. The answer is no: PocketPod is still Serverpod. The server process, HTTP endpoints, generated protocol, and runtime model come from Serverpod.

PocketPod changes the deployment profile around Serverpod:

```text
Normal Serverpod app
        +
SQLite database file
        +
SQLite runtime tuning
        +
simple single-server deployment shape
        +
benchmark harness
        =
PocketPod direction
```

When someone asks how the ports work, explain it like this:

> The public website talks to a reverse proxy on ports 80 and 443. The reverse proxy forwards app/API requests to the Serverpod API server, usually on port 8080. Serverpod then runs endpoint code and reads/writes data from the local SQLite database file. Optional Serverpod services, such as the web server and insights server, use separate internal ports.

The important distinction is that SQLite does not listen on a network port. SQLite is not a separate database server. It is a local database file that Serverpod opens directly inside the backend process.

So the port map is:

```text
80 / 443    public HTTP/HTTPS handled by reverse proxy
8080        Serverpod API server
8081        Serverpod Insights server
8082        Serverpod Web server
no port     SQLite database file
```

The request flow looks like this:

```text
Browser
  |
  | HTTPS request
  v
Reverse Proxy
  | 80 / 443 public
  |
  | forwards to internal app port
  v
Serverpod API Server
  | 8080
  |
  | executes endpoint method
  v
SQLite Database File
  | no network port
  | WAL + NORMAL + busy_timeout + 5 readers
  v
Response returns through Serverpod and reverse proxy
```

For an e-commerce/CMS app, this means:

```text
Product page request
  -> reverse proxy
  -> Serverpod API endpoint
  -> SQLite product/post/SKU query
  -> JSON response
  -> frontend renders page
```

Admin/content writes use the same path:

```text
Admin updates product
  -> reverse proxy
  -> Serverpod admin endpoint
  -> SQLite write transaction
  -> Serverpod response
```

Checkout/order-style writes also use the same path:

```text
Customer submits order
  -> reverse proxy
  -> Serverpod checkout/order endpoint
  -> SQLite write transaction
  -> Serverpod response
```

The reason the SQLite tuning matters is that all write traffic eventually meets SQLite's single-writer rule. WAL mode improves read/write cooperation, `busy_timeout=5000` makes writes wait instead of failing immediately, and `maxConnectionCount=5` keeps concurrency conservative for the intended 2-4 vCPU host.

In short:

> PocketPod is not a new server port or a separate daemon. It is Serverpod running with a lightweight SQLite deployment profile. The public server behavior still comes from Serverpod and the reverse proxy; PocketPod defines how Serverpod should be configured, tuned, and validated for a small single-server e-commerce/CMS deployment.

## Starting A New Project With PocketPod

Inside this repository, a new PocketPod-style project starts from the `pocketpod-starter` directory and uses the local `serverpod-pocketpod` source copy through path dependency overrides.

The process is:

```text
Create normal Serverpod project
        |
        v
Configure SQLite database paths
        |
        v
Apply Serverpod SQLite tuning patch
        |
        v
Set maxConnectionCount to 5
        |
        v
Generate migrations and run
        |
        v
Run production benchmark profile
        |
        v
Accept, tune, or change architecture
```

### 1. Create A Normal Serverpod Project

Start with a regular Serverpod project.

```sh
serverpod create my_app
cd my_app
```

PocketPod does not change how developers write Serverpod endpoints. You still create models, endpoints, migrations, and generated clients using the normal Serverpod workflow.

### 2. Use A Serverpod Version That Supports SQLite Config

In our current work, the installed global Serverpod CLI was `3.4.5`, and that version did not fully accept the SQLite `database.filePath` configuration we needed.

We therefore used a local Serverpod `3.5.0-beta.10` checkout with path overrides.

The workspace pattern looks like this:

```yaml
dependency_overrides:
  serverpod:
    path: ../serverpod-pocketpod/packages/serverpod
  serverpod_client:
    path: ../serverpod-pocketpod/packages/serverpod_client
  serverpod_database:
    path: ../serverpod-pocketpod/packages/serverpod_database
  serverpod_flutter:
    path: ../serverpod-pocketpod/packages/serverpod_flutter
  serverpod_lints:
    path: ../serverpod-pocketpod/packages/serverpod_lints
  serverpod_serialization:
    path: ../serverpod-pocketpod/packages/serverpod_serialization
  serverpod_shared:
    path: ../serverpod-pocketpod/packages/serverpod_shared
  serverpod_test:
    path: ../serverpod-pocketpod/packages/serverpod_test
```

This is a development-stage workaround. In the current monorepo direction, the patched Serverpod source is kept in `serverpod-pocketpod/` inside this repository.

### 3. Configure SQLite In Serverpod Config Files

Each run mode should have its own SQLite file path.

Development example:

```yaml
database:
  filePath: .serverpod/development/database.sqlite
  maxConnectionCount: 5
```

Test example:

```yaml
database:
  filePath: .serverpod/test/database.sqlite
  maxConnectionCount: 5
```

Production example:

```yaml
database:
  filePath: .serverpod/production/database.sqlite
  maxConnectionCount: 5
```

The important value is `maxConnectionCount: 5`. In Serverpod's SQLite path, this becomes the reader pool target. Our production-style benchmark showed that 5 readers is a better starting point for the intended 2-4 vCPU server than larger values such as 10, 15, or 20.

### 4. Apply The SQLite Runtime Tuning Patch

The Serverpod SQLite adapter should explicitly open SQLite with:

```dart
SqliteOptions(
  journalMode: SqliteJournalMode.wal,
  synchronous: SqliteSynchronous.normal,
  lockTimeout: const Duration(seconds: 5),
  maxReaders: maxReaders,
)
```

Conceptually, this means:

```text
WAL mode              -> better read/write concurrency
synchronous=NORMAL   -> good WAL-mode performance/durability balance
busy timeout 5000 ms -> wait for write locks instead of failing immediately
maxReaders 5         -> conservative pool for 2-4 vCPU target servers
```

The current local patch lives in the Serverpod source tree:

```text
../serverpod-pocketpod/packages/serverpod_database/lib/src/adapters/sqlite/sqlite_pool_manager.dart
```

### 5. Generate Code And Migrations

After models and endpoints are in place, use the normal Serverpod generation flow.

```sh
serverpod generate
serverpod create-migration
```

Then run the app and apply migrations.

```sh
dart run bin/main.dart --apply-migrations --mode development
```

For production, the command will use the production mode and should normally sit behind a reverse proxy:

```sh
dart run bin/main.dart --apply-migrations --mode production
```

### 6. Add Or Copy The Benchmark Harness

PocketPod's benchmark harness is what lets us avoid guessing.

The relevant files are:

```text
tool/benchmarks/run_bench.dart
tool/benchmarks/render_report.dart
tool/benchmarks/README.md
```

Run the production benchmark profile:

```sh
dart run tool/benchmarks/run_bench.dart \
  --profile production \
  --targets serverpod-sqlite-tuned
```

Generate the HTML report:

```sh
dart run tool/benchmarks/render_report.dart
```

Open:

```text
tool/benchmarks/results/benchmark-report.html
```

### 7. Read The Benchmark Result Correctly

For this project, do not only look at average speed. Focus on:

```text
errors
p95 latency
C100 rows
write-bearing scenarios
```

The most important questions are:

- Did any request fail?
- Did any SQLite lock error happen?
- At C100, is p95 still acceptable?
- Are write-heavy scenarios still stable?
- Does memory stay under 4 GB on the real server?

The target for the real server is:

```text
read-heavy p95       < 75 ms
write-bearing p95    < 150 ms
errors               0
memory               stable under 4 GB
```

### 8. Deploy Behind A Reverse Proxy

A simple production deployment should put Serverpod behind a reverse proxy.

Example shape:

```text
Internet
   |
   v
Nginx / Caddy on 80 and 443
   |
   v
Serverpod API on 8080
   |
   v
SQLite database file
```

The reverse proxy handles TLS and public HTTP/HTTPS traffic. Serverpod can listen internally on its app ports.

### 9. Decide Whether SQLite Is Still Enough

PocketPod is intended for the early and small/medium phase. SQLite is a strong fit when:

- the app is mostly read-heavy.
- writes are moderate.
- the deployment target is a single VPS.
- operational simplicity matters.
- the dataset is small to medium.

Consider moving to Postgres later if:

- multiple app servers need to write to the same database.
- write volume grows heavily.
- reporting/query needs become complex.
- the team needs managed database operations.
- data size and concurrency grow beyond the tested envelope.

## Automation Script For Monorepo Split

The current repository keeps the reusable PocketPod pieces in two generated directories:

```text
pocketpod-starter      reusable app starter/template
serverpod-pocketpod    Serverpod source fork/branch with SQLite tuning
```

The automation script that creates or refreshes those directories is:

```text
tool/automation/create_pocketpod_repos.sh
```

Default usage:

```sh
tool/automation/create_pocketpod_repos.sh
```

By default, it creates in-repository directories:

```text
./pocketpod-starter
./serverpod-pocketpod
```

It copies the current PocketPod prototype into `pocketpod-starter`, copies the local Serverpod source into `serverpod-pocketpod`, removes build/runtime folders, and rewrites the starter dependency overrides to point at the local `serverpod-pocketpod` path.

Each generated directory has its own `README.md`:

```text
pocketpod-starter/README.md      explains the starter app, config files, benchmark tools, and validation commands
serverpod-pocketpod/README.md    explains the Serverpod fork/copy, SQLite tuning patch, and related test
```

The default local path override result looks like:

```yaml
dependency_overrides:
  serverpod:
    path: ../serverpod-pocketpod/packages/serverpod
  serverpod_client:
    path: ../serverpod-pocketpod/packages/serverpod_client
  serverpod_database:
    path: ../serverpod-pocketpod/packages/serverpod_database
```

Useful options:

```text
--starter-target PATH        choose starter output path
--serverpod-source PATH      choose Serverpod source checkout
--serverpod-target PATH      choose Serverpod fork output path
--force                      replace existing generated targets
```

Recommended first run:

```sh
tool/automation/create_pocketpod_repos.sh
```

Then validate:

```sh
cd pocketpod-starter
flutter pub get
flutter analyze
dart run tool/benchmarks/run_bench.dart --profile production --targets serverpod-sqlite-tuned
dart run tool/benchmarks/render_report.dart
```

The script prepares local directories inside this repository so the starter app and Serverpod patch can be maintained together.
