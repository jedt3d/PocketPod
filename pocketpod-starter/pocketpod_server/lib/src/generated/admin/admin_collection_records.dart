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
import '../admin/admin_collection.dart' as _i2;
import '../admin/admin_record.dart' as _i3;
import 'package:pocketpod_server/src/generated/protocol.dart' as _i4;

abstract class AdminCollectionRecords
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminCollectionRecords._({
    required this.collection,
    required this.rows,
  });

  factory AdminCollectionRecords({
    required _i2.AdminCollection collection,
    required List<_i3.AdminRecord> rows,
  }) = _AdminCollectionRecordsImpl;

  factory AdminCollectionRecords.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AdminCollectionRecords(
      collection: _i4.Protocol().deserialize<_i2.AdminCollection>(
        jsonSerialization['collection'],
      ),
      rows: _i4.Protocol().deserialize<List<_i3.AdminRecord>>(
        jsonSerialization['rows'],
      ),
    );
  }

  _i2.AdminCollection collection;

  List<_i3.AdminRecord> rows;

  /// Returns a shallow copy of this [AdminCollectionRecords]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminCollectionRecords copyWith({
    _i2.AdminCollection? collection,
    List<_i3.AdminRecord>? rows,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminCollectionRecords',
      'collection': collection.toJson(),
      'rows': rows.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminCollectionRecords',
      'collection': collection.toJsonForProtocol(),
      'rows': rows.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminCollectionRecordsImpl extends AdminCollectionRecords {
  _AdminCollectionRecordsImpl({
    required _i2.AdminCollection collection,
    required List<_i3.AdminRecord> rows,
  }) : super._(
         collection: collection,
         rows: rows,
       );

  /// Returns a shallow copy of this [AdminCollectionRecords]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminCollectionRecords copyWith({
    _i2.AdminCollection? collection,
    List<_i3.AdminRecord>? rows,
  }) {
    return AdminCollectionRecords(
      collection: collection ?? this.collection.copyWith(),
      rows: rows ?? this.rows.map((e0) => e0.copyWith()).toList(),
    );
  }
}
