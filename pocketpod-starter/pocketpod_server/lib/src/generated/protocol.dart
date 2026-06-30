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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'admin/admin_collection.dart' as _i5;
import 'admin/admin_collection_records.dart' as _i6;
import 'admin/admin_dashboard.dart' as _i7;
import 'admin/admin_field.dart' as _i8;
import 'admin/admin_record.dart' as _i9;
import 'admin/admin_record_cell.dart' as _i10;
import 'benchmarks/benchmark_record.dart' as _i11;
import 'content/post.dart' as _i12;
import 'content/product.dart' as _i13;
import 'greetings/greeting.dart' as _i14;
import 'package:pocketpod_server/src/generated/admin/admin_collection.dart'
    as _i15;
import 'package:pocketpod_server/src/generated/admin/admin_record_cell.dart'
    as _i16;
import 'package:pocketpod_server/src/generated/benchmarks/benchmark_record.dart'
    as _i17;
export 'admin/admin_collection.dart';
export 'admin/admin_collection_records.dart';
export 'admin/admin_dashboard.dart';
export 'admin/admin_field.dart';
export 'admin/admin_record.dart';
export 'admin/admin_record_cell.dart';
export 'benchmarks/benchmark_record.dart';
export 'content/post.dart';
export 'content/product.dart';
export 'greetings/greeting.dart';

class Protocol extends _i1.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'benchmark_record',
      dartName: 'BenchmarkRecord',
      schema: 'public',
      module: 'pocketpod',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _i2.ColumnDefinition(
          name: 'value',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'payload',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'post',
      dartName: 'Post',
      schema: 'public',
      module: 'pocketpod',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'body',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'published',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'publishedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'authorId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'product',
      dartName: 'Product',
      schema: 'public',
      module: 'pocketpod',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _i2.ColumnDefinition(
          name: 'sku',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'price',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'stock',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'published',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'categoryId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.AdminCollection) {
      return _i5.AdminCollection.fromJson(data) as T;
    }
    if (t == _i6.AdminCollectionRecords) {
      return _i6.AdminCollectionRecords.fromJson(data) as T;
    }
    if (t == _i7.AdminDashboard) {
      return _i7.AdminDashboard.fromJson(data) as T;
    }
    if (t == _i8.AdminField) {
      return _i8.AdminField.fromJson(data) as T;
    }
    if (t == _i9.AdminRecord) {
      return _i9.AdminRecord.fromJson(data) as T;
    }
    if (t == _i10.AdminRecordCell) {
      return _i10.AdminRecordCell.fromJson(data) as T;
    }
    if (t == _i11.BenchmarkRecord) {
      return _i11.BenchmarkRecord.fromJson(data) as T;
    }
    if (t == _i12.Post) {
      return _i12.Post.fromJson(data) as T;
    }
    if (t == _i13.Product) {
      return _i13.Product.fromJson(data) as T;
    }
    if (t == _i14.Greeting) {
      return _i14.Greeting.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AdminCollection?>()) {
      return (data != null ? _i5.AdminCollection.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AdminCollectionRecords?>()) {
      return (data != null ? _i6.AdminCollectionRecords.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.AdminDashboard?>()) {
      return (data != null ? _i7.AdminDashboard.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AdminField?>()) {
      return (data != null ? _i8.AdminField.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.AdminRecord?>()) {
      return (data != null ? _i9.AdminRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.AdminRecordCell?>()) {
      return (data != null ? _i10.AdminRecordCell.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.BenchmarkRecord?>()) {
      return (data != null ? _i11.BenchmarkRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Post?>()) {
      return (data != null ? _i12.Post.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Product?>()) {
      return (data != null ? _i13.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Greeting?>()) {
      return (data != null ? _i14.Greeting.fromJson(data) : null) as T;
    }
    if (t == List<_i8.AdminField>) {
      return (data as List).map((e) => deserialize<_i8.AdminField>(e)).toList()
          as T;
    }
    if (t == List<_i9.AdminRecord>) {
      return (data as List).map((e) => deserialize<_i9.AdminRecord>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i10.AdminRecordCell>) {
      return (data as List)
              .map((e) => deserialize<_i10.AdminRecordCell>(e))
              .toList()
          as T;
    }
    if (t == List<_i15.AdminCollection>) {
      return (data as List)
              .map((e) => deserialize<_i15.AdminCollection>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.AdminRecordCell>) {
      return (data as List)
              .map((e) => deserialize<_i16.AdminRecordCell>(e))
              .toList()
          as T;
    }
    if (t == List<_i17.BenchmarkRecord>) {
      return (data as List)
              .map((e) => deserialize<_i17.BenchmarkRecord>(e))
              .toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AdminCollection => 'AdminCollection',
      _i6.AdminCollectionRecords => 'AdminCollectionRecords',
      _i7.AdminDashboard => 'AdminDashboard',
      _i8.AdminField => 'AdminField',
      _i9.AdminRecord => 'AdminRecord',
      _i10.AdminRecordCell => 'AdminRecordCell',
      _i11.BenchmarkRecord => 'BenchmarkRecord',
      _i12.Post => 'Post',
      _i13.Product => 'Product',
      _i14.Greeting => 'Greeting',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('pocketpod.', '');
    }

    switch (data) {
      case _i5.AdminCollection():
        return 'AdminCollection';
      case _i6.AdminCollectionRecords():
        return 'AdminCollectionRecords';
      case _i7.AdminDashboard():
        return 'AdminDashboard';
      case _i8.AdminField():
        return 'AdminField';
      case _i9.AdminRecord():
        return 'AdminRecord';
      case _i10.AdminRecordCell():
        return 'AdminRecordCell';
      case _i11.BenchmarkRecord():
        return 'BenchmarkRecord';
      case _i12.Post():
        return 'Post';
      case _i13.Product():
        return 'Product';
      case _i14.Greeting():
        return 'Greeting';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AdminCollection') {
      return deserialize<_i5.AdminCollection>(data['data']);
    }
    if (dataClassName == 'AdminCollectionRecords') {
      return deserialize<_i6.AdminCollectionRecords>(data['data']);
    }
    if (dataClassName == 'AdminDashboard') {
      return deserialize<_i7.AdminDashboard>(data['data']);
    }
    if (dataClassName == 'AdminField') {
      return deserialize<_i8.AdminField>(data['data']);
    }
    if (dataClassName == 'AdminRecord') {
      return deserialize<_i9.AdminRecord>(data['data']);
    }
    if (dataClassName == 'AdminRecordCell') {
      return deserialize<_i10.AdminRecordCell>(data['data']);
    }
    if (dataClassName == 'BenchmarkRecord') {
      return deserialize<_i11.BenchmarkRecord>(data['data']);
    }
    if (dataClassName == 'Post') {
      return deserialize<_i12.Post>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i13.Product>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i14.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i3.Protocol().registerHostProtocol('pocketpod', this);
    _i4.Protocol().registerHostProtocol('pocketpod', this);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i11.BenchmarkRecord:
        return _i11.BenchmarkRecord.t;
      case _i12.Post:
        return _i12.Post.t;
      case _i13.Product:
        return _i13.Product.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'pocketpod';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
