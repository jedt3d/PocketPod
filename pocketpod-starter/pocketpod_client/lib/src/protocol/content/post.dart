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

abstract class Post implements _i1.SerializableModel {
  Post._({
    this.id,
    required this.title,
    required this.body,
    required this.published,
    this.publishedAt,
    required this.authorId,
    required this.updatedAt,
  });

  factory Post({
    int? id,
    required String title,
    required String body,
    required bool published,
    DateTime? publishedAt,
    required int authorId,
    required DateTime updatedAt,
  }) = _PostImpl;

  factory Post.fromJson(Map<String, dynamic> jsonSerialization) {
    return Post(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      published: _i1.BoolJsonExtension.fromJson(jsonSerialization['published']),
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      authorId: jsonSerialization['authorId'] as int,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String title;

  String body;

  bool published;

  DateTime? publishedAt;

  int authorId;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Post]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Post copyWith({
    int? id,
    String? title,
    String? body,
    bool? published,
    DateTime? publishedAt,
    int? authorId,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Post',
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'published': published,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      'authorId': authorId,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PostImpl extends Post {
  _PostImpl({
    int? id,
    required String title,
    required String body,
    required bool published,
    DateTime? publishedAt,
    required int authorId,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         title: title,
         body: body,
         published: published,
         publishedAt: publishedAt,
         authorId: authorId,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Post]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Post copyWith({
    Object? id = _Undefined,
    String? title,
    String? body,
    bool? published,
    Object? publishedAt = _Undefined,
    int? authorId,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      published: published ?? this.published,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      authorId: authorId ?? this.authorId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
