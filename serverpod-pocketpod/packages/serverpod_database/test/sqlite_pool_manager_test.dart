import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod_database/serverpod_database.dart';
import 'package:serverpod_database/src/adapters/sqlite/sqlite_pool_manager.dart';
import 'package:serverpod_shared/serverpod_shared.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late SqlitePoolManager poolManager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sqlite_pool_test_');

    poolManager = SqlitePoolManager(
      _TestSerializationManager(),
      SqliteDatabaseConfig(filePath: p.join(tempDir.path, 'test.db')),
    )..start();
    await poolManager.started;
  });

  tearDown(() async {
    await poolManager.stop();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Given a SQLite pool manager, '
      'when it opens the database, '
      'then concurrency PRAGMAs are configured.', () async {
    final database = await poolManager.database;

    expect(
      await database.execute('PRAGMA journal_mode'),
      equals([
        {'journal_mode': 'wal'},
      ]),
    );
    expect(
      await database.execute('PRAGMA synchronous'),
      equals([
        {'synchronous': 1},
      ]),
    );
    expect(
      await database.execute('PRAGMA busy_timeout'),
      equals([
        {'timeout': 5000},
      ]),
    );
  });
}

class _TestSerializationManager extends DatabaseSerializationManager {
  @override
  String getModuleName() => 'test';

  @override
  Table? getTableForType(Type t) => null;

  @override
  List<TableDefinition> getTargetTableDefinitions() => [];
}
