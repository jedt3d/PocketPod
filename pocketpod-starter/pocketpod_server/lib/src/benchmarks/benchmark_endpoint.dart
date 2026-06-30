import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class BenchmarkEndpoint extends Endpoint {
  Future<int> reset(Session session) async {
    await session.db.unsafeExecute('DELETE FROM "benchmark_record";');
    return 0;
  }

  Future<int> seed(Session session, int count) async {
    final now = DateTime.now().toUtc();
    final records = List.generate(
      count,
      (index) => BenchmarkRecord(
        value: index,
        payload: 'seed-$index',
        createdAt: now,
      ),
    );

    await BenchmarkRecord.db.insert(session, records);
    return records.length;
  }

  Future<BenchmarkRecord?> readOne(Session session, int id) {
    return BenchmarkRecord.db.findById(session, id);
  }

  Future<List<BenchmarkRecord>> readList(Session session, int limit) {
    return BenchmarkRecord.db.find(
      session,
      orderBy: (table) => table.id,
      limit: limit,
    );
  }

  Future<int> writeOne(Session session, int value, String payload) async {
    final record = await BenchmarkRecord.db.insertRow(
      session,
      BenchmarkRecord(
        value: value,
        payload: payload,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return record.id!;
  }

  Future<int> count(Session session) {
    return BenchmarkRecord.db.count(session);
  }
}
