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

abstract class Product implements _i1.SerializableModel {
  Product._({
    this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.published,
    required this.categoryId,
    required this.updatedAt,
  });

  factory Product({
    int? id,
    required String sku,
    required String name,
    required String description,
    required double price,
    required int stock,
    required bool published,
    required int categoryId,
    required DateTime updatedAt,
  }) = _ProductImpl;

  factory Product.fromJson(Map<String, dynamic> jsonSerialization) {
    return Product(
      id: jsonSerialization['id'] as int?,
      sku: jsonSerialization['sku'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String,
      price: (jsonSerialization['price'] as num).toDouble(),
      stock: jsonSerialization['stock'] as int,
      published: _i1.BoolJsonExtension.fromJson(jsonSerialization['published']),
      categoryId: jsonSerialization['categoryId'] as int,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String sku;

  String name;

  String description;

  double price;

  int stock;

  bool published;

  int categoryId;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Product copyWith({
    int? id,
    String? sku,
    String? name,
    String? description,
    double? price,
    int? stock,
    bool? published,
    int? categoryId,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Product',
      if (id != null) 'id': id,
      'sku': sku,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'published': published,
      'categoryId': categoryId,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductImpl extends Product {
  _ProductImpl({
    int? id,
    required String sku,
    required String name,
    required String description,
    required double price,
    required int stock,
    required bool published,
    required int categoryId,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         sku: sku,
         name: name,
         description: description,
         price: price,
         stock: stock,
         published: published,
         categoryId: categoryId,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Product copyWith({
    Object? id = _Undefined,
    String? sku,
    String? name,
    String? description,
    double? price,
    int? stock,
    bool? published,
    int? categoryId,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id is int? ? id : this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      published: published ?? this.published,
      categoryId: categoryId ?? this.categoryId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
