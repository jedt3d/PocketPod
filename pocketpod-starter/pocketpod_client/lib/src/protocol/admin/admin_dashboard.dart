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
import 'package:pocketpod_client/src/protocol/protocol.dart' as _i2;

abstract class AdminDashboard implements _i1.SerializableModel {
  AdminDashboard._({
    required this.title,
    required this.signedInUserId,
    required this.scopeNames,
    required this.generatedCollections,
    required this.message,
    required this.checkedAt,
  });

  factory AdminDashboard({
    required String title,
    required String signedInUserId,
    required List<String> scopeNames,
    required List<String> generatedCollections,
    required String message,
    required DateTime checkedAt,
  }) = _AdminDashboardImpl;

  factory AdminDashboard.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminDashboard(
      title: jsonSerialization['title'] as String,
      signedInUserId: jsonSerialization['signedInUserId'] as String,
      scopeNames: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['scopeNames'],
      ),
      generatedCollections: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['generatedCollections'],
      ),
      message: jsonSerialization['message'] as String,
      checkedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['checkedAt'],
      ),
    );
  }

  String title;

  String signedInUserId;

  List<String> scopeNames;

  List<String> generatedCollections;

  String message;

  DateTime checkedAt;

  /// Returns a shallow copy of this [AdminDashboard]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminDashboard copyWith({
    String? title,
    String? signedInUserId,
    List<String>? scopeNames,
    List<String>? generatedCollections,
    String? message,
    DateTime? checkedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminDashboard',
      'title': title,
      'signedInUserId': signedInUserId,
      'scopeNames': scopeNames.toJson(),
      'generatedCollections': generatedCollections.toJson(),
      'message': message,
      'checkedAt': checkedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AdminDashboardImpl extends AdminDashboard {
  _AdminDashboardImpl({
    required String title,
    required String signedInUserId,
    required List<String> scopeNames,
    required List<String> generatedCollections,
    required String message,
    required DateTime checkedAt,
  }) : super._(
         title: title,
         signedInUserId: signedInUserId,
         scopeNames: scopeNames,
         generatedCollections: generatedCollections,
         message: message,
         checkedAt: checkedAt,
       );

  /// Returns a shallow copy of this [AdminDashboard]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminDashboard copyWith({
    String? title,
    String? signedInUserId,
    List<String>? scopeNames,
    List<String>? generatedCollections,
    String? message,
    DateTime? checkedAt,
  }) {
    return AdminDashboard(
      title: title ?? this.title,
      signedInUserId: signedInUserId ?? this.signedInUserId,
      scopeNames: scopeNames ?? this.scopeNames.map((e0) => e0).toList(),
      generatedCollections:
          generatedCollections ??
          this.generatedCollections.map((e0) => e0).toList(),
      message: message ?? this.message,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }
}
