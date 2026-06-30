import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pocketpod_client/pocketpod_client.dart';
import 'package:sqlite_async/sqlite_async.dart';

const _serverpodPort = 18080;
const _pocketBasePort = 18090;
const _serverpodBaselineVersion = '3.5.0-beta.10';
const _pocketBaseVersion = '0.39.5';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'targets',
      defaultsTo:
          'serverpod-sqlite-tuned,serverpod-sqlite-untuned,direct-sqlite-dart,pocketbase-local',
      help: 'Comma-separated target ids.',
    )
    ..addOption(
      'profile',
      defaultsTo: 'micro',
      allowed: ['micro', 'production'],
      help: 'Benchmark scenario profile.',
    )
    ..addOption('requests', help: 'Override requests per non-smoke scenario.')
    ..addOption('seed', help: 'Override seed rows per target.')
    ..addOption(
      'sqlite-readers',
      defaultsTo: '5',
      help: 'Serverpod SQLite maxConnectionCount for tuned runs.',
    )
    ..addOption('out', defaultsTo: 'tool/benchmarks/results')
    ..addFlag('help', abbr: 'h', negatable: false);

  final options = parser.parse(args);
  if (options['help'] as bool) {
    stdout.writeln(parser.usage);
    return;
  }

  final root = Directory.current;
  final profile = BenchProfile.byName(options['profile'] as String);
  final requests = int.parse(
    options['requests'] as String? ?? '${profile.defaultRequests}',
  );
  final seed = int.parse(
    options['seed'] as String? ?? '${profile.defaultSeed}',
  );
  final config = BenchConfig(
    root: root,
    serverDir: Directory(p.join(root.path, 'pocketpod_server')),
    benchDir: Directory(
      p.join(root.path, 'pocketpod_server', '.serverpod', 'benchmark'),
    ),
    resultDir: Directory(p.join(root.path, options['out'] as String)),
    requests: requests,
    seed: seed,
    profile: profile,
    sqliteReaders: int.parse(options['sqlite-readers'] as String),
  );
  config.benchDir.createSync(recursive: true);
  config.resultDir.createSync(recursive: true);

  final targetIds = (options['targets'] as String)
      .split(',')
      .map((target) => target.trim())
      .where((target) => target.isNotEmpty)
      .toList();

  final scenarios = config.profile.scenarios(config.requests);

  final results = <ScenarioResult>[];
  final failures = <Map<String, Object?>>[];
  final startedAt = DateTime.now().toUtc();

  for (final targetId in targetIds) {
    final target = createTarget(targetId, config);
    stdout.writeln('\n== $targetId ==');
    try {
      await target.setup();
      await target.resetAndSeed(config.seed);

      for (final scenario in scenarios) {
        for (final concurrency in scenario.concurrencyLevels) {
          stdout.writeln(
            'Running ${scenario.name} c=$concurrency n=${scenario.requests}',
          );
          final result = await runScenario(
            target: target,
            scenario: scenario,
            concurrency: concurrency,
            seed: config.seed,
          );
          stdout.writeln(
            '  ${result.throughput.toStringAsFixed(1)} req/s, '
            'p95=${result.p95Ms.toStringAsFixed(2)} ms, '
            'errors=${result.errors}',
          );
          results.add(result);
        }
      }
    } catch (error, stackTrace) {
      stderr.writeln('Target $targetId failed: $error');
      failures.add({
        'target': targetId,
        'error': '$error',
        'stackTrace': '$stackTrace',
      });
    } finally {
      await target.close();
    }
  }

  final finishedAt = DateTime.now().toUtc();
  final stamp = _timestampForFile(startedAt);
  final jsonPath = p.join(config.resultDir.path, '$stamp.json');
  final mdPath = p.join(config.resultDir.path, '$stamp.md');
  final payload = {
    'startedAt': startedAt.toIso8601String(),
    'finishedAt': finishedAt.toIso8601String(),
    'profile': config.profile.name,
    'seed': config.seed,
    'requests': config.requests,
    'sqliteReaders': config.sqliteReaders,
    'serverpodBaselineVersion': _serverpodBaselineVersion,
    'pocketBaseVersion': _pocketBaseVersion,
    'targets': targetIds,
    'results': results.map((result) => result.toJson()).toList(),
    'failures': failures,
  };

  File(
    jsonPath,
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  File(mdPath).writeAsStringSync(renderMarkdown(payload, results, failures));
  stdout.writeln('\nWrote $mdPath');
  stdout.writeln('Wrote $jsonPath');

  if (failures.isNotEmpty || results.any((result) => result.errors > 0)) {
    exitCode = 1;
  }
}

BenchTarget createTarget(String id, BenchConfig config) {
  return switch (id) {
    'serverpod-sqlite-tuned' => ServerpodTarget(
      id: id,
      config: config,
      profile: 'tuned',
    ),
    'serverpod-sqlite-untuned' => ServerpodTarget(
      id: id,
      config: config,
      profile: 'untuned',
    ),
    'direct-sqlite-dart' => DirectSqliteTarget(id: id, config: config),
    'pocketbase-local' => PocketBaseTarget(id: id, config: config),
    _ => throw ArgumentError('Unknown benchmark target: $id'),
  };
}

Future<ScenarioResult> runScenario({
  required BenchTarget target,
  required Scenario scenario,
  required int concurrency,
  required int seed,
}) async {
  for (var i = 0; i < min(10, scenario.requests); i++) {
    await _runOperation(target, scenario.name, i, seed, warmup: true);
  }

  final latencies = <int>[];
  var errors = 0;
  var next = 0;
  final started = Stopwatch()..start();

  Future<void> worker(int workerId) async {
    while (true) {
      final index = next++;
      if (index >= scenario.requests) return;

      final operationWatch = Stopwatch()..start();
      try {
        await _runOperation(target, scenario.name, index + workerId, seed);
      } catch (_) {
        errors++;
      } finally {
        operationWatch.stop();
        latencies.add(operationWatch.elapsedMicroseconds);
      }
    }
  }

  await Future.wait([for (var i = 0; i < concurrency; i++) worker(i)]);
  started.stop();

  return ScenarioResult.fromLatencies(
    target: target.id,
    scenario: scenario.name,
    concurrency: concurrency,
    requests: scenario.requests,
    elapsed: started.elapsed,
    latenciesMicros: latencies,
    errors: errors,
    databaseBytes: await target.databaseBytes(),
  );
}

Future<void> _runOperation(
  BenchTarget target,
  String scenario,
  int index,
  int seed, {
  bool warmup = false,
}) async {
  final readId = (index % (seed < 1 ? 1 : seed)) + 1;
  switch (scenario) {
    case 'smoke':
      if (index % 5 == 0 && !warmup) {
        await target.writeOne(index, 'smoke-$index');
      } else if (index % 3 == 0) {
        await target.readList(10);
      } else {
        await target.readOne(readId);
      }
    case 'read-only':
      if (index % 4 == 0) {
        await target.readList(10);
      } else {
        await target.readOne(readId);
      }
    case 'write-only':
    case 'burst-writes':
      await target.writeOne(index, '$scenario-$index');
    case 'mixed-80-20':
      if (index % 5 == 0) {
        await target.writeOne(index, 'mixed-$index');
      } else if (index % 4 == 0) {
        await target.readList(10);
      } else {
        await target.readOne(readId);
      }
    case 'prod-catalog-browse':
      if (index % 10 < 7) {
        await target.readList(20);
      } else {
        await target.readOne(readId);
      }
    case 'prod-detail-heavy':
      if (index % 10 == 0) {
        await target.readList(12);
      } else {
        await target.readOne(readId);
      }
    case 'prod-content-commerce':
      if (index % 20 == 0) {
        await target.writeOne(index, 'content-update-$index');
      } else if (index % 5 == 0) {
        await target.readList(20);
      } else {
        await target.readOne(readId);
      }
    case 'prod-admin-write':
      if (index % 5 == 0) {
        await target.writeOne(index, 'admin-write-$index');
      } else if (index % 3 == 0) {
        await target.readList(20);
      } else {
        await target.readOne(readId);
      }
    case 'prod-peak-checkout':
      if (index % 10 < 3) {
        await target.writeOne(index, 'checkout-$index');
      } else if (index % 4 == 0) {
        await target.readList(10);
      } else {
        await target.readOne(readId);
      }
    default:
      throw StateError('Unknown scenario: $scenario');
  }
}

class BenchConfig {
  final Directory root;
  final Directory serverDir;
  final Directory benchDir;
  final Directory resultDir;
  final int requests;
  final int seed;
  final BenchProfile profile;
  final int sqliteReaders;

  BenchConfig({
    required this.root,
    required this.serverDir,
    required this.benchDir,
    required this.resultDir,
    required this.requests,
    required this.seed,
    required this.profile,
    required this.sqliteReaders,
  });
}

class BenchProfile {
  final String name;
  final int defaultSeed;
  final int defaultRequests;
  final List<Scenario> Function(int requests) scenarios;

  const BenchProfile({
    required this.name,
    required this.defaultSeed,
    required this.defaultRequests,
    required this.scenarios,
  });

  static BenchProfile byName(String name) {
    return switch (name) {
      'micro' => micro,
      'production' => production,
      _ => throw ArgumentError('Unknown benchmark profile: $name'),
    };
  }

  static const micro = BenchProfile(
    name: 'micro',
    defaultSeed: 1000,
    defaultRequests: 200,
    scenarios: _microScenarios,
  );

  static const production = BenchProfile(
    name: 'production',
    defaultSeed: 10000,
    defaultRequests: 1000,
    scenarios: _productionScenarios,
  );
}

List<Scenario> _microScenarios(int requests) => [
  const Scenario('smoke', [1], 25),
  Scenario('read-only', const [1, 5, 10, 25, 50], requests),
  Scenario('write-only', const [1, 5, 10, 25, 50], requests),
  Scenario('mixed-80-20', const [1, 5, 10, 25, 50], requests),
  Scenario('burst-writes', const [10, 25, 50], requests),
];

List<Scenario> _productionScenarios(int requests) => [
  const Scenario('smoke', [1], 25),
  Scenario('prod-catalog-browse', const [50, 75, 100], requests),
  Scenario('prod-detail-heavy', const [50, 75, 100], requests),
  Scenario('prod-content-commerce', const [50, 75, 100], requests),
  Scenario('prod-admin-write', const [50, 75, 100], requests),
  Scenario('prod-peak-checkout', const [50, 75, 100], requests),
];

class Scenario {
  final String name;
  final List<int> concurrencyLevels;
  final int requests;

  const Scenario(this.name, this.concurrencyLevels, this.requests);
}

abstract class BenchTarget {
  final String id;
  final BenchConfig config;

  BenchTarget({required this.id, required this.config});

  Future<void> setup();
  Future<void> resetAndSeed(int count);
  Future<void> readOne(int id);
  Future<void> readList(int limit);
  Future<void> writeOne(int value, String payload);
  Future<void> close();
  Future<int> databaseBytes();
}

class ServerpodTarget extends BenchTarget {
  final String profile;
  Process? _process;
  late Client _client;
  final _logLines = <String>[];
  String? _originalDevelopmentConfig;

  ServerpodTarget({
    required super.id,
    required super.config,
    required this.profile,
  });

  String get _dbPath => p.join(config.benchDir.path, '$id.sqlite');
  File get _developmentConfig =>
      File(p.join(config.serverDir.path, 'config', 'development.yaml'));
  int get serverpodMaxReaders =>
      profile == 'untuned' ? 1 : config.sqliteReaders;

  @override
  Future<void> setup() async {
    _deleteSqliteFiles(_dbPath);
    _writeBenchmarkDatabasePath();
    _process = await Process.start(
      'dart',
      ['run', 'bin/main.dart', '--apply-migrations', '--mode', 'development'],
      workingDirectory: config.serverDir.path,
      environment: {
        ...Platform.environment,
        'SERVERPOD_SQLITE_PROFILE': profile,
        'SERVERPOD_DATABASE_FILE_PATH': _dbPath,
        'SERVERPOD_DATABASE_MAX_CONNECTION_COUNT': '$serverpodMaxReaders',
        'SERVERPOD_API_SERVER_PORT': '$_serverpodPort',
        'SERVERPOD_API_SERVER_PUBLIC_PORT': '$_serverpodPort',
        'SERVERPOD_INSIGHTS_SERVER_PORT': '${_serverpodPort + 1}',
        'SERVERPOD_INSIGHTS_SERVER_PUBLIC_PORT': '${_serverpodPort + 1}',
        'SERVERPOD_WEB_SERVER_PORT': '${_serverpodPort + 2}',
        'SERVERPOD_WEB_SERVER_PUBLIC_PORT': '${_serverpodPort + 2}',
        'SERVERPOD_SESSION_CONSOLE_LOG_ENABLED': 'false',
      },
    );

    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_recordLog);
    _process!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_recordLog);

    _client = Client(
      'http://localhost:$_serverpodPort/',
      connectionTimeout: const Duration(seconds: 5),
    );
    await _waitForServerpod();
  }

  @override
  Future<void> resetAndSeed(int count) async {
    await _client.benchmark.reset();
    await _client.benchmark.seed(count);
  }

  @override
  Future<void> readOne(int id) async {
    await _client.benchmark.readOne(id);
  }

  @override
  Future<void> readList(int limit) async {
    await _client.benchmark.readList(limit);
  }

  @override
  Future<void> writeOne(int value, String payload) async {
    await _client.benchmark.writeOne(value, payload);
  }

  @override
  Future<void> close() async {
    final process = _process;
    if (process != null) {
      process.kill(ProcessSignal.sigterm);
      try {
        await process.exitCode.timeout(const Duration(seconds: 5));
      } on TimeoutException {
        process.kill(ProcessSignal.sigkill);
        await process.exitCode;
      }
    }
    _restoreDevelopmentConfig();
  }

  @override
  Future<int> databaseBytes() async {
    return _sqliteFamilyBytes(_dbPath);
  }

  Future<void> _waitForServerpod() async {
    Object? lastError;
    for (var attempt = 0; attempt < 120; attempt++) {
      final process = _process;
      if (process != null) {
        final exit = await _tryExit(process);
        if (exit != null) {
          throw StateError(
            '$id exited before startup with code $exit.\n${_tailLog()}',
          );
        }
      }

      try {
        await _client.benchmark.count();
        return;
      } catch (error) {
        lastError = error;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }
    throw TimeoutException('$id did not start: $lastError\n${_tailLog()}');
  }

  void _recordLog(String line) {
    _logLines.add(line);
    if (_logLines.length > 200) _logLines.removeAt(0);
  }

  String _tailLog() => _logLines.takeLast(40).join('\n');

  void _writeBenchmarkDatabasePath() {
    final configFile = _developmentConfig;
    final original = configFile.readAsStringSync();
    _originalDevelopmentConfig = original;

    final updated = original.replaceFirstMapped(
      RegExp(r'^(\s*filePath:\s*).*$', multiLine: true),
      (match) => '${match.group(1)}$_dbPath',
    );
    if (updated == original) {
      throw StateError(
        'Could not find database.filePath in ${configFile.path}',
      );
    }
    configFile.writeAsStringSync(updated);
  }

  void _restoreDevelopmentConfig() {
    final original = _originalDevelopmentConfig;
    if (original == null) return;
    _developmentConfig.writeAsStringSync(original);
    _originalDevelopmentConfig = null;
  }
}

class DirectSqliteTarget extends BenchTarget {
  SqliteDatabase? _db;

  DirectSqliteTarget({required super.id, required super.config});

  String get _dbPath => p.join(config.benchDir.path, '$id.sqlite');

  @override
  Future<void> setup() async {
    _deleteSqliteFiles(_dbPath);
    final db = SqliteDatabase(
      path: _dbPath,
      options: const SqliteOptions(
        journalMode: SqliteJournalMode.wal,
        synchronous: SqliteSynchronous.normal,
        lockTimeout: Duration(seconds: 5),
        maxReaders: 10,
      ),
    );
    _db = db;
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('''
CREATE TABLE benchmark_record (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  value INTEGER NOT NULL,
  payload TEXT NOT NULL,
  created_at INTEGER NOT NULL
)
''');
  }

  @override
  Future<void> resetAndSeed(int count) async {
    final db = _requireDb();
    await db.execute('DELETE FROM benchmark_record');
    await db.executeBatch(
      'INSERT INTO benchmark_record (value, payload, created_at) VALUES (?, ?, ?)',
      [
        for (var i = 0; i < count; i++)
          [i, 'seed-$i', DateTime.now().toUtc().millisecondsSinceEpoch],
      ],
    );
  }

  @override
  Future<void> readOne(int id) async {
    await _requireDb().getOptional(
      'SELECT id, value, payload, created_at FROM benchmark_record WHERE id = ?',
      [id],
    );
  }

  @override
  Future<void> readList(int limit) async {
    await _requireDb().getAll(
      'SELECT id, value, payload, created_at FROM benchmark_record ORDER BY id LIMIT ?',
      [limit],
    );
  }

  @override
  Future<void> writeOne(int value, String payload) async {
    await _requireDb().execute(
      'INSERT INTO benchmark_record (value, payload, created_at) VALUES (?, ?, ?)',
      [value, payload, DateTime.now().toUtc().millisecondsSinceEpoch],
    );
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<int> databaseBytes() async {
    return _sqliteFamilyBytes(_dbPath);
  }

  SqliteDatabase _requireDb() {
    final db = _db;
    if (db == null) throw StateError('$id is not started');
    return db;
  }
}

class PocketBaseTarget extends BenchTarget {
  Process? _process;
  final _client = http.Client();
  final _recordIds = <String>[];
  String? _token;
  final _logLines = <String>[];

  PocketBaseTarget({required super.id, required super.config});

  Uri get _base => Uri.parse('http://127.0.0.1:$_pocketBasePort');
  String get _pbDir => p.join(config.benchDir.path, 'pocketbase');
  String get _collection => 'benchmark_records';

  @override
  Future<void> setup() async {
    final binary = await _ensurePocketBaseBinary(config.benchDir);
    final pbData = Directory(p.join(_pbDir, 'pb_data'));
    if (pbData.existsSync()) pbData.deleteSync(recursive: true);
    pbData.createSync(recursive: true);

    _process = await Process.start(binary, [
      'serve',
      '--http',
      '127.0.0.1:$_pocketBasePort',
      '--dir',
      pbData.path,
    ], workingDirectory: _pbDir);
    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_recordLog);
    _process!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_recordLog);

    await _waitForPocketBase();
    await _createSuperuser(binary, pbData.path);
    _token = await _authenticateSuperuser();
    await _createCollection();
  }

  @override
  Future<void> resetAndSeed(int count) async {
    _recordIds.clear();
    final existing = await _getJson(
      '/api/collections/$_collection/records',
      query: {'perPage': '500'},
    );
    for (final item in existing['items'] as List<dynamic>) {
      await _delete('/api/collections/$_collection/records/${item['id']}');
    }

    for (var i = 0; i < count; i++) {
      final created = await _postJson('/api/collections/$_collection/records', {
        'value': i + 1,
        'payload': 'seed-$i',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
      _recordIds.add(created['id'] as String);
    }
  }

  @override
  Future<void> readOne(int id) async {
    final recordId = _recordIds[(id - 1) % _recordIds.length];
    await _getJson('/api/collections/$_collection/records/$recordId');
  }

  @override
  Future<void> readList(int limit) async {
    await _getJson(
      '/api/collections/$_collection/records',
      query: {'page': '1', 'perPage': '$limit'},
    );
  }

  @override
  Future<void> writeOne(int value, String payload) async {
    final created = await _postJson('/api/collections/$_collection/records', {
      'value': value + 1,
      'payload': payload,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    _recordIds.add(created['id'] as String);
  }

  @override
  Future<void> close() async {
    _client.close();
    final process = _process;
    if (process == null) return;
    process.kill(ProcessSignal.sigterm);
    try {
      await process.exitCode.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      await process.exitCode;
    }
  }

  @override
  Future<int> databaseBytes() async {
    return _sqliteFamilyBytes(p.join(_pbDir, 'pb_data', 'data.db'));
  }

  Future<void> _waitForPocketBase() async {
    for (var attempt = 0; attempt < 120; attempt++) {
      final process = _process;
      if (process != null) {
        final exit = await _tryExit(process);
        if (exit != null) {
          throw StateError(
            '$id exited before startup with code $exit.\n${_tailLog()}',
          );
        }
      }

      try {
        final response = await _client
            .get(_base.replace(path: '/api/health'))
            .timeout(const Duration(seconds: 2));
        if (response.statusCode < 500) return;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }
    throw TimeoutException('$id did not start.\n${_tailLog()}');
  }

  Future<void> _createSuperuser(String binary, String pbDataPath) async {
    final result = await Process.run(binary, [
      'superuser',
      'create',
      'benchmark@example.com',
      'benchmark-password-123456789',
      '--dir',
      pbDataPath,
    ], workingDirectory: _pbDir);
    final output = '${result.stdout}\n${result.stderr}';
    if (result.exitCode != 0 && !output.contains('already exists')) {
      throw StateError('PocketBase superuser setup failed: $output');
    }
  }

  Future<String> _authenticateSuperuser() async {
    final auth =
        await _postJson('/api/collections/_superusers/auth-with-password', {
          'identity': 'benchmark@example.com',
          'password': 'benchmark-password-123456789',
        }, authenticated: false);
    return auth['token'] as String;
  }

  Future<void> _createCollection() async {
    final response = await _client.get(
      _base.replace(path: '/api/collections/$_collection'),
      headers: _headers(),
    );
    if (response.statusCode == 200) return;

    await _postJson('/api/collections', {
      'name': _collection,
      'type': 'base',
      'listRule': null,
      'viewRule': null,
      'createRule': null,
      'updateRule': null,
      'deleteRule': null,
      'fields': [
        {
          'name': 'value',
          'type': 'number',
          'required': true,
          'options': {'min': null, 'max': null, 'noDecimal': true},
        },
        {
          'name': 'payload',
          'type': 'text',
          'required': true,
          'options': {'min': null, 'max': null, 'pattern': ''},
        },
        {
          'name': 'createdAt',
          'type': 'date',
          'required': true,
          'options': {'min': '', 'max': ''},
        },
      ],
    });
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _client.get(
      _base.replace(path: path, queryParameters: query),
      headers: _headers(),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, Object?> body, {
    bool authenticated = true,
  }) async {
    final response = await _client.post(
      _base.replace(path: path),
      headers: _headers(authenticated: authenticated),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<void> _delete(String path) async {
    final response = await _client.delete(
      _base.replace(path: path),
      headers: _headers(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('DELETE $path failed: ${response.body}');
    }
  }

  Map<String, String> _headers({bool authenticated = true}) {
    return {
      'content-type': 'application/json',
      if (authenticated && _token != null) 'authorization': 'Bearer $_token',
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        '${response.request?.method} ${response.request?.url.path} '
        'failed with ${response.statusCode}: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _recordLog(String line) {
    _logLines.add(line);
    if (_logLines.length > 200) _logLines.removeAt(0);
  }

  String _tailLog() => _logLines.takeLast(40).join('\n');
}

class ScenarioResult {
  final String target;
  final String scenario;
  final int concurrency;
  final int requests;
  final Duration elapsed;
  final int errors;
  final int databaseBytes;
  final double throughput;
  final double p50Ms;
  final double p95Ms;
  final double p99Ms;
  final double maxMs;

  ScenarioResult({
    required this.target,
    required this.scenario,
    required this.concurrency,
    required this.requests,
    required this.elapsed,
    required this.errors,
    required this.databaseBytes,
    required this.throughput,
    required this.p50Ms,
    required this.p95Ms,
    required this.p99Ms,
    required this.maxMs,
  });

  factory ScenarioResult.fromLatencies({
    required String target,
    required String scenario,
    required int concurrency,
    required int requests,
    required Duration elapsed,
    required List<int> latenciesMicros,
    required int errors,
    required int databaseBytes,
  }) {
    latenciesMicros.sort();
    final success = requests - errors;
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    double percentile(double p) {
      if (latenciesMicros.isEmpty) return 0;
      final index = (latenciesMicros.length * p).ceil() - 1;
      return latenciesMicros[index.clamp(0, latenciesMicros.length - 1)] /
          1000.0;
    }

    return ScenarioResult(
      target: target,
      scenario: scenario,
      concurrency: concurrency,
      requests: requests,
      elapsed: elapsed,
      errors: errors,
      databaseBytes: databaseBytes,
      throughput: seconds == 0 ? 0 : success / seconds,
      p50Ms: percentile(0.50),
      p95Ms: percentile(0.95),
      p99Ms: percentile(0.99),
      maxMs: latenciesMicros.isEmpty ? 0 : latenciesMicros.last / 1000.0,
    );
  }

  Map<String, Object?> toJson() => {
    'target': target,
    'scenario': scenario,
    'concurrency': concurrency,
    'requests': requests,
    'elapsedMs': elapsed.inMicroseconds / 1000.0,
    'errors': errors,
    'databaseBytes': databaseBytes,
    'throughput': throughput,
    'p50Ms': p50Ms,
    'p95Ms': p95Ms,
    'p99Ms': p99Ms,
    'maxMs': maxMs,
  };
}

extension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final list = toList(growable: false);
    if (list.length <= count) return list;
    return list.skip(list.length - count);
  }
}

Future<String> _ensurePocketBaseBinary(Directory benchDir) async {
  final binDir = Directory(p.join(benchDir.path, 'pocketbase_bin'));
  final binary = File(p.join(binDir.path, 'pocketbase'));
  if (binary.existsSync()) return binary.path;

  binDir.createSync(recursive: true);
  final arch = _pocketBaseArch();
  final asset = 'pocketbase_${_pocketBaseVersion}_darwin_$arch.zip';
  final url =
      'https://github.com/pocketbase/pocketbase/releases/download/v$_pocketBaseVersion/$asset';
  final zipPath = p.join(binDir.path, asset);
  stdout.writeln('Downloading PocketBase v$_pocketBaseVersion ($arch)');
  final curl = await Process.run('curl', ['-L', '-o', zipPath, url]);
  if (curl.exitCode != 0) {
    throw StateError('PocketBase download failed: ${curl.stderr}');
  }

  final unzip = await Process.run('unzip', ['-o', zipPath, '-d', binDir.path]);
  if (unzip.exitCode != 0) {
    throw StateError('PocketBase unzip failed: ${unzip.stderr}');
  }
  final chmod = await Process.run('chmod', ['+x', binary.path]);
  if (chmod.exitCode != 0) {
    throw StateError('PocketBase chmod failed: ${chmod.stderr}');
  }
  return binary.path;
}

String _pocketBaseArch() {
  if (!Platform.isMacOS) {
    throw UnsupportedError('PocketBase bootstrap currently supports macOS.');
  }
  final result = Process.runSync('uname', ['-m']);
  final machine = '${result.stdout}'.trim();
  if (machine == 'arm64') return 'arm64';
  if (machine == 'x86_64') return 'amd64';
  throw UnsupportedError('Unsupported macOS architecture: $machine');
}

void _deleteSqliteFiles(String dbPath) {
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final file = File('$dbPath$suffix');
    if (file.existsSync()) file.deleteSync();
  }
}

int _sqliteFamilyBytes(String dbPath) {
  var total = 0;
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final file = File('$dbPath$suffix');
    if (file.existsSync()) total += file.lengthSync();
  }
  return total;
}

Future<int?> _tryExit(Process process) {
  return process.exitCode
      .timeout(Duration.zero, onTimeout: () => -999999)
      .then((code) => code == -999999 ? null : code);
}

String _timestampForFile(DateTime value) {
  return value
      .toIso8601String()
      .replaceAll(':', '')
      .replaceAll('-', '')
      .replaceAll('.', '')
      .replaceAll('Z', 'Z');
}

String renderMarkdown(
  Map<String, Object?> payload,
  List<ScenarioResult> results,
  List<Map<String, Object?>> failures,
) {
  final buffer = StringBuffer()
    ..writeln('# Phase 2 Benchmark Results')
    ..writeln()
    ..writeln('- Started: `${payload['startedAt']}`')
    ..writeln('- Finished: `${payload['finishedAt']}`')
    ..writeln('- Profile: `${payload['profile']}`')
    ..writeln('- Seed rows per target: `${payload['seed']}`')
    ..writeln('- Requests per non-smoke run: `${payload['requests']}`')
    ..writeln('- Tuned Serverpod SQLite readers: `${payload['sqliteReaders']}`')
    ..writeln('- Serverpod baseline: `${payload['serverpodBaselineVersion']}`')
    ..writeln(
      '- PocketPod release tag policy: match Serverpod baseline, e.g. `v${payload['serverpodBaselineVersion']}`',
    )
    ..writeln('- PocketBase: `v$_pocketBaseVersion`')
    ..writeln()
    ..writeln('## Throughput And P95')
    ..writeln()
    ..writeln(
      '| Target | Scenario | C | Requests | Errors | Throughput req/s | p95 ms | p99 ms | DB bytes |',
    )
    ..writeln('| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |');

  for (final result in results) {
    buffer.writeln(
      '| ${result.target} | ${result.scenario} | ${result.concurrency} | '
      '${result.requests} | ${result.errors} | '
      '${result.throughput.toStringAsFixed(1)} | '
      '${result.p95Ms.toStringAsFixed(2)} | '
      '${result.p99Ms.toStringAsFixed(2)} | '
      '${result.databaseBytes} |',
    );
  }

  if (failures.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('## Failures')
      ..writeln();
    for (final failure in failures) {
      buffer.writeln('- `${failure['target']}`: `${failure['error']}`');
    }
  }

  return buffer.toString();
}
