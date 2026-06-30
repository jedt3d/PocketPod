import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketpod_admin_ui/admin_api.dart';
import 'package:pocketpod_admin_ui/main.dart';
import 'package:pocketpod_admin_ui/session_store.dart';
import 'package:pocketpod_client/pocketpod_client.dart';

void main() {
  testWidgets('renders login when no session is stored', (tester) async {
    await tester.pumpWidget(
      PocketPodAdminApp(
        api: FakeAdminApi(),
        sessionStore: MemoryAdminSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PocketPod Admin'), findsOneWidget);
    expect(find.byKey(const Key('login_email')), findsOneWidget);
    expect(find.byKey(const Key('login_password')), findsOneWidget);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
  });

  testWidgets('successful login opens the admin shell', (tester) async {
    final store = MemoryAdminSessionStore();
    final api = FakeAdminApi();

    await tester.pumpWidget(PocketPodAdminApp(api: api, sessionStore: store));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Admin Input Examples'), findsNWidgets(2));
    expect(find.byKey(const Key('admin_status_line')), findsOneWidget);
    expect(find.byKey(const Key('logout_button')), findsOneWidget);
    expect(find.text('Launch article'), findsOneWidget);
    expect((await store.read())?.token, 'test-token');
  });

  testWidgets('failed login displays an error', (tester) async {
    final api = FakeAdminApi(loginShouldFail: true);

    await tester.pumpWidget(
      PocketPodAdminApp(api: api, sessionStore: MemoryAdminSessionStore()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_error')), findsOneWidget);
    expect(find.textContaining('Sign in failed'), findsOneWidget);
  });

  testWidgets('stored session restores the admin shell', (tester) async {
    final store = MemoryAdminSessionStore();
    await store.save(testSession);

    await tester.pumpWidget(
      PocketPodAdminApp(api: FakeAdminApi(), sessionStore: store),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('admin_status_line')), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
  });

  testWidgets(
    'collection browser switches collection and opens primary field',
    (tester) async {
      final store = MemoryAdminSessionStore();
      await store.save(testSession);

      await tester.pumpWidget(
        PocketPodAdminApp(api: FakeAdminApi(), sessionStore: store),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav_Products')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('active_collection_title')), findsOneWidget);
      expect(find.text('PocketPod Starter License'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('primary_products_1')));
      await tester.tap(find.byKey(const Key('primary_products_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('record_detail')), findsOneWidget);
      expect(find.textContaining('Edit Products #1'), findsOneWidget);
    },
  );

  testWidgets('logout clears the session and returns to login', (tester) async {
    final store = MemoryAdminSessionStore();
    await store.save(testSession);

    await tester.pumpWidget(
      PocketPodAdminApp(api: FakeAdminApi(), sessionStore: store),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('logout_button')));
    await tester.pumpAndSettle();

    expect(await store.read(), isNull);
    expect(find.byKey(const Key('login_submit')), findsOneWidget);
  });
}

const testSession = AdminSession(
  token: 'test-token',
  userId: 'test-admin',
  scopeNames: {'serverpod.admin'},
);

class FakeAdminApi implements AdminApi {
  FakeAdminApi({this.loginShouldFail = false});

  final bool loginShouldFail;
  String? token;

  @override
  void setAuthToken(String? token) {
    this.token = token;
  }

  @override
  Future<AdminSession> login({
    required String email,
    required String password,
  }) async {
    if (loginShouldFail) {
      throw StateError('bad credentials');
    }
    token = testSession.token;
    return testSession;
  }

  @override
  Future<AdminDashboard> dashboard() async {
    if (token == null) {
      throw StateError('missing token');
    }
    return AdminDashboard(
      title: 'PocketPod Admin',
      signedInUserId: testSession.userId,
      scopeNames: testSession.scopeNames.toList(),
      generatedCollections: const ['Admin Input Examples', 'Products', 'Posts'],
      message: 'Signed in with Serverpod Auth and Scope.admin.',
      checkedAt: DateTime.utc(2026, 6, 30),
    );
  }

  @override
  Future<List<AdminCollection>> listCollections() async {
    _requireToken();
    return fakeCollections;
  }

  @override
  Future<AdminCollectionRecords> listRecords(String collectionKey) async {
    _requireToken();
    final collection = fakeCollections.firstWhere(
      (collection) => collection.key == collectionKey,
    );
    return AdminCollectionRecords(
      collection: collection,
      rows: fakeRecords[collectionKey] ?? const [],
    );
  }

  @override
  Future<AdminRecord> getRecord(String collectionKey, String id) async {
    _requireToken();
    return (fakeRecords[collectionKey] ?? const []).firstWhere(
      (record) => record.id == id,
    );
  }

  void _requireToken() {
    if (token == null) {
      throw StateError('missing token');
    }
  }
}

final fakeCollections = [
  AdminCollection(
    key: 'admin_input_examples',
    title: 'Admin Input Examples',
    description: 'Control mapping examples generated from Serverpod fields.',
    rowCount: 2,
    fields: [
      _field('title', 'Title', 'String', 'text'),
      _field('body', 'Body', 'String', 'textarea'),
      _field('published', 'Published', 'bool', 'checkbox'),
    ],
  ),
  AdminCollection(
    key: 'products',
    title: 'Products',
    description: 'SQLite-backed e-commerce product rows.',
    rowCount: 1,
    fields: [
      _field('name', 'Name', 'String', 'text'),
      _field('price', 'Price', 'double', 'number'),
      _field('published', 'Published', 'bool', 'checkbox'),
    ],
  ),
  AdminCollection(
    key: 'posts',
    title: 'Posts',
    description: 'SQLite-backed CMS post rows.',
    rowCount: 1,
    fields: [
      _field('title', 'Title', 'String', 'text'),
      _field('body', 'Body', 'String', 'textarea'),
      _field('published', 'Published', 'bool', 'checkbox'),
    ],
  ),
];

final fakeRecords = {
  'admin_input_examples': [
    _record('1', {
      'title': 'Launch article',
      'body': 'Long-form content uses a textarea control.',
      'published': 'true',
    }),
  ],
  'products': [
    _record('1', {
      'name': 'PocketPod Starter License',
      'price': '49.00',
      'published': 'true',
    }),
  ],
  'posts': [
    _record('1', {
      'title': 'Building with Serverpod and SQLite',
      'body': 'A CMS post example.',
      'published': 'true',
    }),
  ],
};

AdminField _field(String name, String label, String dartType, String control) {
  return AdminField(
    name: name,
    label: label,
    dartType: dartType,
    control: control,
    required: true,
  );
}

AdminRecord _record(String id, Map<String, String> values) {
  return AdminRecord(
    id: id,
    cells: [
      for (final entry in values.entries)
        AdminRecordCell(field: entry.key, value: entry.value),
    ],
  );
}
