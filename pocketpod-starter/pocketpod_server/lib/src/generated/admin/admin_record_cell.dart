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

abstract class AdminRecordCell
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminRecordCell._({
    required this.field,
    required this.value,
  });

  factory AdminRecordCell({
    required String field,
    required String value,
  }) = _AdminRecordCellImpl;

  factory AdminRecordCell.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminRecordCell(
      field: jsonSerialization['field'] as String,
      value: jsonSerialization['value'] as String,
    );
  }

  String field;

  String value;

  /// Returns a shallow copy of this [AdminRecordCell]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminRecordCell copyWith({
    String? field,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminRecordCell',
      'field': field,
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminRecordCell',
      'field': field,
      'value': value,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminRecordCellImpl extends AdminRecordCell {
  _AdminRecordCellImpl({
    required String field,
    required String value,
  }) : super._(
         field: field,
         value: value,
       );

  /// Returns a shallow copy of this [AdminRecordCell]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminRecordCell copyWith({
    String? field,
    String? value,
  }) {
    return AdminRecordCell(
      field: field ?? this.field,
      value: value ?? this.value,
    );
  }
}
