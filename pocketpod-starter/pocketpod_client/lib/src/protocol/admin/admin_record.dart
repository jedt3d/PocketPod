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
import '../admin/admin_record_cell.dart' as _i2;
import 'package:pocketpod_client/src/protocol/protocol.dart' as _i3;

abstract class AdminRecord implements _i1.SerializableModel {
  AdminRecord._({
    required this.id,
    required this.cells,
  });

  factory AdminRecord({
    required String id,
    required List<_i2.AdminRecordCell> cells,
  }) = _AdminRecordImpl;

  factory AdminRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminRecord(
      id: jsonSerialization['id'] as String,
      cells: _i3.Protocol().deserialize<List<_i2.AdminRecordCell>>(
        jsonSerialization['cells'],
      ),
    );
  }

  String id;

  List<_i2.AdminRecordCell> cells;

  /// Returns a shallow copy of this [AdminRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminRecord copyWith({
    String? id,
    List<_i2.AdminRecordCell>? cells,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminRecord',
      'id': id,
      'cells': cells.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminRecordImpl extends AdminRecord {
  _AdminRecordImpl({
    required String id,
    required List<_i2.AdminRecordCell> cells,
  }) : super._(
         id: id,
         cells: cells,
       );

  /// Returns a shallow copy of this [AdminRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminRecord copyWith({
    String? id,
    List<_i2.AdminRecordCell>? cells,
  }) {
    return AdminRecord(
      id: id ?? this.id,
      cells: cells ?? this.cells.map((e0) => e0.copyWith()).toList(),
    );
  }
}
