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
import '../admin/admin_field.dart' as _i2;
import 'package:pocketpod_client/src/protocol/protocol.dart' as _i3;

abstract class AdminCollection implements _i1.SerializableModel {
  AdminCollection._({
    required this.key,
    required this.title,
    required this.description,
    required this.fields,
    required this.rowCount,
  });

  factory AdminCollection({
    required String key,
    required String title,
    required String description,
    required List<_i2.AdminField> fields,
    required int rowCount,
  }) = _AdminCollectionImpl;

  factory AdminCollection.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminCollection(
      key: jsonSerialization['key'] as String,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String,
      fields: _i3.Protocol().deserialize<List<_i2.AdminField>>(
        jsonSerialization['fields'],
      ),
      rowCount: jsonSerialization['rowCount'] as int,
    );
  }

  String key;

  String title;

  String description;

  List<_i2.AdminField> fields;

  int rowCount;

  /// Returns a shallow copy of this [AdminCollection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminCollection copyWith({
    String? key,
    String? title,
    String? description,
    List<_i2.AdminField>? fields,
    int? rowCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminCollection',
      'key': key,
      'title': title,
      'description': description,
      'fields': fields.toJson(valueToJson: (v) => v.toJson()),
      'rowCount': rowCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminCollectionImpl extends AdminCollection {
  _AdminCollectionImpl({
    required String key,
    required String title,
    required String description,
    required List<_i2.AdminField> fields,
    required int rowCount,
  }) : super._(
         key: key,
         title: title,
         description: description,
         fields: fields,
         rowCount: rowCount,
       );

  /// Returns a shallow copy of this [AdminCollection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminCollection copyWith({
    String? key,
    String? title,
    String? description,
    List<_i2.AdminField>? fields,
    int? rowCount,
  }) {
    return AdminCollection(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      fields: fields ?? this.fields.map((e0) => e0.copyWith()).toList(),
      rowCount: rowCount ?? this.rowCount,
    );
  }
}
