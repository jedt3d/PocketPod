import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class AdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  Future<AdminDashboard> dashboard(Session session) async {
    final authenticated = session.authenticated!;
    final collections = await _collections(session);

    return AdminDashboard(
      title: 'PocketPod Admin',
      signedInUserId: authenticated.userIdentifier,
      scopeNames:
          authenticated.scopes.map((scope) => scope.name).nonNulls.toList()
            ..sort(),
      generatedCollections: collections
          .map((collection) => collection.title)
          .toList(),
      message: 'Signed in with Serverpod Auth and Scope.admin.',
      checkedAt: DateTime.now().toUtc(),
    );
  }

  Future<List<AdminCollection>> listCollections(Session session) async {
    return _collections(session);
  }

  Future<AdminCollectionRecords> listRecords(
    Session session,
    String collectionKey,
  ) async {
    await _ensureSeedData(session);
    final collections = await _collections(session);
    final collection = collections.firstWhere(
      (collection) => collection.key == collectionKey,
      orElse: () => throw ArgumentError.value(
        collectionKey,
        'collectionKey',
        'Unknown admin collection.',
      ),
    );

    return AdminCollectionRecords(
      collection: collection,
      rows: await _records(session, collection.key),
    );
  }

  Future<AdminRecord> getRecord(
    Session session,
    String collectionKey,
    String id,
  ) async {
    await _ensureSeedData(session);

    return switch (collectionKey) {
      'admin_input_examples' => _requireAdminInputExample(id),
      'products' => _productRecord(
        await _requireProduct(session, int.parse(id)),
      ),
      'posts' => _postRecord(
        await _requirePost(session, int.parse(id)),
      ),
      _ => throw UnsupportedError(
        'Collection "$collectionKey" does not support editing.',
      ),
    };
  }

  Future<AdminRecord> updateRecord(
    Session session,
    String collectionKey,
    String id,
    List<AdminRecordCell> cells,
  ) async {
    await _ensureSeedData(session);
    final values = {for (final cell in cells) cell.field: cell.value};
    final now = DateTime.now().toUtc();

    return switch (collectionKey) {
      'products' => _productRecord(
        await Product.db.updateRow(
          session,
          (await _requireProduct(session, int.parse(id))).copyWith(
            sku: _requiredString(values, 'sku'),
            name: _requiredString(values, 'name'),
            description: _requiredString(values, 'description'),
            price: _requiredDouble(values, 'price'),
            stock: _requiredInt(values, 'stock'),
            published: _requiredBool(values, 'published'),
            categoryId: _requiredInt(values, 'categoryId'),
            updatedAt: now,
          ),
        ),
      ),
      'posts' => _postRecord(
        await Post.db.updateRow(
          session,
          (await _requirePost(session, int.parse(id))).copyWith(
            title: _requiredString(values, 'title'),
            body: _requiredString(values, 'body'),
            published: _requiredBool(values, 'published'),
            publishedAt: _optionalDateTime(values, 'publishedAt'),
            authorId: _requiredInt(values, 'authorId'),
            updatedAt: now,
          ),
        ),
      ),
      _ => throw UnsupportedError(
        'Collection "$collectionKey" does not support editing.',
      ),
    };
  }

  Future<AdminRecord> createRecord(
    Session session,
    String collectionKey,
    List<AdminRecordCell> cells,
  ) async {
    await _ensureSeedData(session);
    final values = {for (final cell in cells) cell.field: cell.value};
    final now = DateTime.now().toUtc();

    return switch (collectionKey) {
      'products' => _productRecord(
        await Product.db.insertRow(
          session,
          Product(
            sku: _requiredString(values, 'sku'),
            name: _requiredString(values, 'name'),
            description: _requiredString(values, 'description'),
            price: _requiredDouble(values, 'price'),
            stock: _requiredInt(values, 'stock'),
            published: _requiredBool(values, 'published'),
            categoryId: _requiredInt(values, 'categoryId'),
            updatedAt: now,
          ),
        ),
      ),
      'posts' => _postRecord(
        await Post.db.insertRow(
          session,
          Post(
            title: _requiredString(values, 'title'),
            body: _requiredString(values, 'body'),
            published: _requiredBool(values, 'published'),
            publishedAt: _optionalDateTime(values, 'publishedAt'),
            authorId: _requiredInt(values, 'authorId'),
            updatedAt: now,
          ),
        ),
      ),
      _ => throw UnsupportedError(
        'Collection "$collectionKey" does not support creating records.',
      ),
    };
  }

  Future<bool> deleteRecord(
    Session session,
    String collectionKey,
    String id,
  ) async {
    await _ensureSeedData(session);

    return switch (collectionKey) {
      'products' => await _deleteProduct(session, int.parse(id)),
      'posts' => await _deletePost(session, int.parse(id)),
      _ => throw UnsupportedError(
        'Collection "$collectionKey" does not support deleting records.',
      ),
    };
  }
}

Future<List<AdminCollection>> _collections(Session session) async {
  await _ensureSeedData(session);
  final adminExampleRecords = _adminInputExampleRecords();
  final productCount = await Product.db.count(session);
  final postCount = await Post.db.count(session);

  return [
    AdminCollection(
      key: 'admin_input_examples',
      title: 'Admin Input Examples',
      description: 'Control mapping examples generated from Serverpod fields.',
      fields: [
        _field('title', 'Title', 'String', 'text', required: true),
        _field('body', 'Body', 'String', 'textarea', required: true),
        _field('summary', 'Summary', 'String?', 'textarea'),
        _field('published', 'Published', 'bool', 'checkbox', required: true),
        _field('publishedAt', 'Published At', 'DateTime?', 'datetime'),
        _field('status', 'Status', 'PublishStatus', 'select', required: true),
        _field('categoryId', 'Category', 'int', 'relation', required: true),
        _field('tags', 'Tags', 'List<String>?', 'list'),
      ],
      rowCount: adminExampleRecords.length,
    ),
    AdminCollection(
      key: 'products',
      title: 'Products',
      description: 'SQLite-backed e-commerce product rows.',
      fields: [
        _field('sku', 'SKU', 'String', 'text', required: true),
        _field('name', 'Name', 'String', 'text', required: true),
        _field(
          'description',
          'Description',
          'String',
          'textarea',
          required: true,
        ),
        _field('price', 'Price', 'double', 'number', required: true),
        _field('stock', 'Stock', 'int', 'number', required: true),
        _field('published', 'Published', 'bool', 'checkbox', required: true),
        _field('categoryId', 'Category', 'int', 'relation', required: true),
        _field(
          'updatedAt',
          'Updated At',
          'DateTime',
          'datetime',
          required: true,
        ),
      ],
      rowCount: productCount,
    ),
    AdminCollection(
      key: 'posts',
      title: 'Posts',
      description: 'SQLite-backed CMS post rows.',
      fields: [
        _field('title', 'Title', 'String', 'text', required: true),
        _field('body', 'Body', 'String', 'textarea', required: true),
        _field('published', 'Published', 'bool', 'checkbox', required: true),
        _field('publishedAt', 'Published At', 'DateTime?', 'datetime'),
        _field('authorId', 'Author', 'int', 'relation', required: true),
        _field(
          'updatedAt',
          'Updated At',
          'DateTime',
          'datetime',
          required: true,
        ),
      ],
      rowCount: postCount,
    ),
  ];
}

AdminField _field(
  String name,
  String label,
  String dartType,
  String control, {
  bool required = false,
}) {
  return AdminField(
    name: name,
    label: label,
    dartType: dartType,
    control: control,
    required: required,
  );
}

Future<List<AdminRecord>> _records(
  Session session,
  String collectionKey,
) async {
  return switch (collectionKey) {
    'admin_input_examples' => _adminInputExampleRecords(),
    'products' => (await Product.db.find(
      session,
      orderBy: (table) => table.id,
    )).map(_productRecord).toList(),
    'posts' => (await Post.db.find(
      session,
      orderBy: (table) => table.id,
    )).map(_postRecord).toList(),
    _ => const [],
  };
}

AdminRecord _requireAdminInputExample(String id) {
  try {
    return _adminInputExampleRecords().firstWhere((record) => record.id == id);
  } on StateError {
    throw ArgumentError.value(id, 'id', 'Admin input example not found.');
  }
}

List<AdminRecord> _adminInputExampleRecords() {
  return [
    _record('1', {
      'title': 'Launch article',
      'body': 'Long-form content uses a textarea control.',
      'summary': 'Generated controls demo',
      'published': 'true',
      'publishedAt': '2026-06-30T09:00:00.000Z',
      'status': 'published',
      'categoryId': 'News',
      'tags': 'pocketpod, admin',
    }),
    _record('2', {
      'title': 'Draft product guide',
      'body': 'Draft content can stay unpublished.',
      'summary': '',
      'published': 'false',
      'publishedAt': '',
      'status': 'draft',
      'categoryId': 'Guides',
      'tags': 'draft',
    }),
  ];
}

AdminRecord _record(String id, Map<String, String> values) {
  return AdminRecord(
    id: id,
    cells: values.entries
        .map((entry) => AdminRecordCell(field: entry.key, value: entry.value))
        .toList(),
  );
}

AdminRecord _productRecord(Product product) {
  return _record(product.id.toString(), {
    'sku': product.sku,
    'name': product.name,
    'description': product.description,
    'price': product.price.toStringAsFixed(2),
    'stock': product.stock.toString(),
    'published': product.published.toString(),
    'categoryId': product.categoryId.toString(),
    'updatedAt': _dateTimeValue(product.updatedAt),
  });
}

AdminRecord _postRecord(Post post) {
  return _record(post.id.toString(), {
    'title': post.title,
    'body': post.body,
    'published': post.published.toString(),
    'publishedAt': _dateTimeValue(post.publishedAt),
    'authorId': post.authorId.toString(),
    'updatedAt': _dateTimeValue(post.updatedAt),
  });
}

Future<Product> _requireProduct(Session session, int id) async {
  final product = await Product.db.findById(session, id);
  if (product == null) {
    throw ArgumentError.value(id, 'id', 'Product record not found.');
  }
  return product;
}

Future<Post> _requirePost(Session session, int id) async {
  final post = await Post.db.findById(session, id);
  if (post == null) {
    throw ArgumentError.value(id, 'id', 'Post record not found.');
  }
  return post;
}

Future<bool> _deleteProduct(Session session, int id) async {
  final product = await _requireProduct(session, id);
  await Product.db.deleteRow(session, product);
  return true;
}

Future<bool> _deletePost(Session session, int id) async {
  final post = await _requirePost(session, id);
  await Post.db.deleteRow(session, post);
  return true;
}

Future<void> _ensureSeedData(Session session) async {
  final now = DateTime.utc(2026, 6, 30, 9);

  if (await Product.db.count(session) == 0) {
    await Product.db.insert(session, [
      Product(
        sku: 'SKU-1001',
        name: 'PocketPod Starter License',
        description: 'Starter package for a Serverpod SQLite application.',
        price: 49,
        stock: 100,
        published: true,
        categoryId: 1,
        updatedAt: now,
      ),
      Product(
        sku: 'SKU-1002',
        name: 'SQLite Tuning Support',
        description: 'Implementation support for PocketPod SQLite settings.',
        price: 149,
        stock: 25,
        published: true,
        categoryId: 2,
        updatedAt: now,
      ),
      Product(
        sku: 'SKU-1003',
        name: 'Admin Generator Preview',
        description: 'Preview item used while validating generated admin UI.',
        price: 0,
        stock: 999,
        published: false,
        categoryId: 3,
        updatedAt: now,
      ),
    ]);
  }

  if (await Post.db.count(session) == 0) {
    await Post.db.insert(session, [
      Post(
        title: 'Building with Serverpod and SQLite',
        body: 'A CMS post example rendered from protected admin data.',
        published: true,
        publishedAt: DateTime.utc(2026, 6, 29, 16, 30),
        authorId: 1,
        updatedAt: now,
      ),
      Post(
        title: 'PocketPod Admin Generator Notes',
        body: 'A draft post used to verify boolean and datetime controls.',
        published: false,
        authorId: 1,
        updatedAt: now,
      ),
    ]);
  }
}

String _requiredString(Map<String, String> values, String field) {
  final value = values[field]?.trim() ?? '';
  if (value.isEmpty) {
    throw ArgumentError.value(value, field, 'Field is required.');
  }
  return value;
}

int _requiredInt(Map<String, String> values, String field) {
  return int.parse(_requiredString(values, field));
}

double _requiredDouble(Map<String, String> values, String field) {
  return double.parse(_requiredString(values, field));
}

bool _requiredBool(Map<String, String> values, String field) {
  return switch (_requiredString(values, field).toLowerCase()) {
    'true' || '1' || 'yes' || 'on' => true,
    'false' || '0' || 'no' || 'off' => false,
    final value => throw ArgumentError.value(value, field, 'Expected boolean.'),
  };
}

DateTime? _optionalDateTime(Map<String, String> values, String field) {
  final value = values[field]?.trim() ?? '';
  if (value.isEmpty) {
    return null;
  }
  return DateTime.parse(value).toUtc();
}

String _dateTimeValue(DateTime? value) {
  return value?.toUtc().toIso8601String() ?? '';
}
