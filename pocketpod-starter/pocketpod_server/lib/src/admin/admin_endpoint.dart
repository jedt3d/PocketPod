import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class AdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  Future<AdminDashboard> dashboard(Session session) async {
    final authenticated = session.authenticated!;
    final collections = _collections();

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
    return _collections();
  }

  Future<AdminCollectionRecords> listRecords(
    Session session,
    String collectionKey,
  ) async {
    final collections = _collections();
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
      rows: _recordsByCollection()[collection.key] ?? const [],
    );
  }
}

List<AdminCollection> _collections() {
  final records = _recordsByCollection();

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
      rowCount: records['admin_input_examples']?.length ?? 0,
    ),
    AdminCollection(
      key: 'products',
      title: 'Products',
      description: 'Sample e-commerce product rows for the admin shell.',
      fields: [
        _field('sku', 'SKU', 'String', 'text', required: true),
        _field('name', 'Name', 'String', 'text', required: true),
        _field('price', 'Price', 'double', 'number', required: true),
        _field('stock', 'Stock', 'int', 'number', required: true),
        _field('published', 'Published', 'bool', 'checkbox', required: true),
        _field('categoryId', 'Category', 'int', 'relation', required: true),
      ],
      rowCount: records['products']?.length ?? 0,
    ),
    AdminCollection(
      key: 'posts',
      title: 'Posts',
      description: 'Sample CMS post rows for the admin shell.',
      fields: [
        _field('title', 'Title', 'String', 'text', required: true),
        _field('body', 'Body', 'String', 'textarea', required: true),
        _field('published', 'Published', 'bool', 'checkbox', required: true),
        _field('publishedAt', 'Published At', 'DateTime?', 'datetime'),
        _field('authorId', 'Author', 'int', 'relation', required: true),
      ],
      rowCount: records['posts']?.length ?? 0,
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

Map<String, List<AdminRecord>> _recordsByCollection() {
  return {
    'admin_input_examples': [
      _record('1', {
        'title': 'Launch article',
        'body': 'Long-form content uses a textarea control.',
        'summary': 'Generated controls demo',
        'published': 'true',
        'publishedAt': '2026-06-30 09:00',
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
    ],
    'products': [
      _record('SKU-1001', {
        'sku': 'SKU-1001',
        'name': 'PocketPod Starter License',
        'price': '49.00',
        'stock': '100',
        'published': 'true',
        'categoryId': 'Software',
      }),
      _record('SKU-1002', {
        'sku': 'SKU-1002',
        'name': 'SQLite Tuning Support',
        'price': '149.00',
        'stock': '25',
        'published': 'true',
        'categoryId': 'Services',
      }),
      _record('SKU-1003', {
        'sku': 'SKU-1003',
        'name': 'Admin Generator Preview',
        'price': '0.00',
        'stock': '999',
        'published': 'false',
        'categoryId': 'Preview',
      }),
    ],
    'posts': [
      _record('post-1', {
        'title': 'Building with Serverpod and SQLite',
        'body': 'A CMS post example rendered from protected admin data.',
        'published': 'true',
        'publishedAt': '2026-06-29 16:30',
        'authorId': 'Admin',
      }),
      _record('post-2', {
        'title': 'PocketPod Admin Generator Notes',
        'body': 'A draft post used to verify boolean and datetime controls.',
        'published': 'false',
        'publishedAt': '',
        'authorId': 'Admin',
      }),
    ],
  };
}

AdminRecord _record(String id, Map<String, String> values) {
  return AdminRecord(
    id: id,
    cells: values.entries
        .map((entry) => AdminRecordCell(field: entry.key, value: entry.value))
        .toList(),
  );
}
