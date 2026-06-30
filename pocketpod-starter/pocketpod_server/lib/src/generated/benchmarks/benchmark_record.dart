/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class BenchmarkRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  BenchmarkRecord._({
    this.id,
    required this.value,
    required this.payload,
    required this.createdAt,
  });

  factory BenchmarkRecord({
    int? id,
    required int value,
    required String payload,
    required DateTime createdAt,
  }) = _BenchmarkRecordImpl;

  factory BenchmarkRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return BenchmarkRecord(
      id: jsonSerialization['id'] as int?,
      value: jsonSerialization['value'] as int,
      payload: jsonSerialization['payload'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = BenchmarkRecordTable();

  static const db = BenchmarkRecordRepository._();

  @override
  int? id;

  int value;

  String payload;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [BenchmarkRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BenchmarkRecord copyWith({
    int? id,
    int? value,
    String? payload,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BenchmarkRecord',
      if (id != null) 'id': id,
      'value': value,
      'payload': payload,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BenchmarkRecord',
      if (id != null) 'id': id,
      'value': value,
      'payload': payload,
      'createdAt': createdAt.toJson(),
    };
  }

  static BenchmarkRecordInclude include() {
    return BenchmarkRecordInclude._();
  }

  static BenchmarkRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<BenchmarkRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BenchmarkRecordTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<BenchmarkRecordTable>? orderByList,
    BenchmarkRecordInclude? include,
  }) {
    return BenchmarkRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BenchmarkRecord.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(BenchmarkRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BenchmarkRecordImpl extends BenchmarkRecord {
  _BenchmarkRecordImpl({
    int? id,
    required int value,
    required String payload,
    required DateTime createdAt,
  }) : super._(
         id: id,
         value: value,
         payload: payload,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [BenchmarkRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BenchmarkRecord copyWith({
    Object? id = _Undefined,
    int? value,
    String? payload,
    DateTime? createdAt,
  }) {
    return BenchmarkRecord(
      id: id is int? ? id : this.id,
      value: value ?? this.value,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BenchmarkRecordUpdateTable extends _i1.UpdateTable<BenchmarkRecordTable> {
  BenchmarkRecordUpdateTable(super.table);

  _i1.ColumnValue<int, int> value(int value) => _i1.ColumnValue(
    table.value,
    value,
  );

  _i1.ColumnValue<String, String> payload(String value) => _i1.ColumnValue(
    table.payload,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class BenchmarkRecordTable extends _i1.Table<int?> {
  BenchmarkRecordTable({super.tableRelation})
    : super(tableName: 'benchmark_record') {
    updateTable = BenchmarkRecordUpdateTable(this);
    value = _i1.ColumnInt(
      'value',
      this,
    );
    payload = _i1.ColumnString(
      'payload',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final BenchmarkRecordUpdateTable updateTable;

  late final _i1.ColumnInt value;

  late final _i1.ColumnString payload;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    value,
    payload,
    createdAt,
  ];
}

class BenchmarkRecordInclude extends _i1.IncludeObject {
  BenchmarkRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => BenchmarkRecord.t;
}

class BenchmarkRecordIncludeList extends _i1.IncludeList {
  BenchmarkRecordIncludeList._({
    _i1.WhereExpressionBuilder<BenchmarkRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BenchmarkRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => BenchmarkRecord.t;
}

class BenchmarkRecordRepository {
  const BenchmarkRecordRepository._();

  /// Returns a list of [BenchmarkRecord]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<BenchmarkRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BenchmarkRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BenchmarkRecordTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<BenchmarkRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BenchmarkRecord>(
      where: where?.call(BenchmarkRecord.t),
      orderBy: orderBy?.call(BenchmarkRecord.t),
      orderByList: orderByList?.call(BenchmarkRecord.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [BenchmarkRecord] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<BenchmarkRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BenchmarkRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<BenchmarkRecordTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<BenchmarkRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BenchmarkRecord>(
      where: where?.call(BenchmarkRecord.t),
      orderBy: orderBy?.call(BenchmarkRecord.t),
      orderByList: orderByList?.call(BenchmarkRecord.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BenchmarkRecord] by its [id] or null if no such row exists.
  Future<BenchmarkRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BenchmarkRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BenchmarkRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [BenchmarkRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BenchmarkRecord>> insert(
    _i1.DatabaseSession session,
    List<BenchmarkRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<BenchmarkRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [BenchmarkRecord] and returns the inserted row.
  ///
  /// The returned [BenchmarkRecord] will have its `id` field set.
  Future<BenchmarkRecord> insertRow(
    _i1.DatabaseSession session,
    BenchmarkRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<BenchmarkRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [BenchmarkRecord]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [BenchmarkRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BenchmarkRecord>> upsert(
    _i1.DatabaseSession session,
    List<BenchmarkRecord> rows, {
    required _i1.ColumnSelections<BenchmarkRecordTable> conflictColumns,
    _i1.ColumnSelections<BenchmarkRecordTable>? updateColumns,
    _i1.WhereExpressionBuilder<BenchmarkRecordTable>? updateWhere,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<BenchmarkRecord>(
      rows,
      conflictColumns: conflictColumns(BenchmarkRecord.t),
      updateColumns: updateColumns?.call(BenchmarkRecord.t),
      updateWhere: updateWhere?.call(BenchmarkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [BenchmarkRecord] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [BenchmarkRecord] will have its `id` field set.
  Future<BenchmarkRecord?> upsertRow(
    _i1.DatabaseSession session,
    BenchmarkRecord row, {
    required _i1.ColumnSelections<BenchmarkRecordTable> conflictColumns,
    _i1.ColumnSelections<BenchmarkRecordTable>? updateColumns,
    _i1.WhereExpressionBuilder<BenchmarkRecordTable>? updateWhere,
    _i1.Transaction? transaction,
  }) async {
    return session.db.upsertRow<BenchmarkRecord>(
      row,
      conflictColumns: conflictColumns(BenchmarkRecord.t),
      updateColumns: updateColumns?.call(BenchmarkRecord.t),
      updateWhere: updateWhere?.call(BenchmarkRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [BenchmarkRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BenchmarkRecord>> update(
    _i1.DatabaseSession session,
    List<BenchmarkRecord> rows, {
    _i1.ColumnSelections<BenchmarkRecordTable>? columns,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<BenchmarkRecord>(
      rows,
      columns: columns?.call(BenchmarkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [BenchmarkRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BenchmarkRecord> updateRow(
    _i1.DatabaseSession session,
    BenchmarkRecord row, {
    _i1.ColumnSelections<BenchmarkRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<BenchmarkRecord>(
      row,
      columns: columns?.call(BenchmarkRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BenchmarkRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BenchmarkRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<BenchmarkRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<BenchmarkRecord>(
      id,
      columnValues: columnValues(BenchmarkRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BenchmarkRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BenchmarkRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<BenchmarkRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<BenchmarkRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BenchmarkRecordTable>? orderBy,
    _i1.OrderByListBuilder<BenchmarkRecordTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<BenchmarkRecord>(
      columnValues: columnValues(BenchmarkRecord.t.updateTable),
      where: where(BenchmarkRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BenchmarkRecord.t),
      orderByList: orderByList?.call(BenchmarkRecord.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [BenchmarkRecord]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BenchmarkRecord>> delete(
    _i1.DatabaseSession session,
    List<BenchmarkRecord> rows, {
    _i1.OrderByBuilder<BenchmarkRecordTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<BenchmarkRecordTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<BenchmarkRecord>(
      rows,
      orderBy: orderBy?.call(BenchmarkRecord.t),
      orderByList: orderByList?.call(BenchmarkRecord.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [BenchmarkRecord].
  Future<BenchmarkRecord> deleteRow(
    _i1.DatabaseSession session,
    BenchmarkRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BenchmarkRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BenchmarkRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BenchmarkRecordTable> where,
    _i1.OrderByBuilder<BenchmarkRecordTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<BenchmarkRecordTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<BenchmarkRecord>(
      where: where(BenchmarkRecord.t),
      orderBy: orderBy?.call(BenchmarkRecord.t),
      orderByList: orderByList?.call(BenchmarkRecord.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BenchmarkRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<BenchmarkRecord>(
      where: where?.call(BenchmarkRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BenchmarkRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BenchmarkRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BenchmarkRecord>(
      where: where(BenchmarkRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
