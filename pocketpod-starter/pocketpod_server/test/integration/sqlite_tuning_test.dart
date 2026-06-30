import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given SQLite database tuning', (sessionBuilder, endpoints) {
    test('when Serverpod starts then required PRAGMAs are active', () async {
      final session = sessionBuilder.build();

      final journalMode = await session.db.unsafeQuery('PRAGMA journal_mode;');
      final synchronous = await session.db.unsafeQuery('PRAGMA synchronous;');
      final busyTimeout = await session.db.unsafeQuery('PRAGMA busy_timeout;');

      expect(journalMode.first.toColumnMap()['journal_mode'], 'wal');
      expect(synchronous.first.toColumnMap()['synchronous'], 1);
      expect(busyTimeout.first.toColumnMap()['timeout'], 5000);
    });
  });
}
