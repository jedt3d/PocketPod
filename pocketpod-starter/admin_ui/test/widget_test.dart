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
}
