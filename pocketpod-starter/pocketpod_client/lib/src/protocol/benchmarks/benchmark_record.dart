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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class BenchmarkRecord implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int value;

  String payload;

  DateTime createdAt;

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
