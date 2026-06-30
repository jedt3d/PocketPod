import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given PocketPod admin endpoints', (sessionBuilder, endpoints) {
    test('when sysadmin signs in then dashboard is available', () async {
      _ensureTestAuthServices();

      const email = 'admin-endpoint-test@example.com';
      const password = 'change-me-now';
      final setupSession = sessionBuilder.build();

      await _createAdminUser(setupSession, email: email, password: password);

      final authSuccess = await endpoints.adminAuth.login(
        sessionBuilder,
        email: email,
        password: password,
      );

      expect(authSuccess.token, isNotEmpty);
      expect(authSuccess.scopeNames, contains(Scope.admin.name));

      await expectLater(
        endpoints.admin.dashboard(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );

      final nonAdminSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'non-admin-user',
          {},
        ),
      );
      await expectLater(
        endpoints.admin.dashboard(nonAdminSession),
        throwsA(isA<ServerpodInsufficientAccessException>()),
      );

      final adminSession = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          authSuccess.authUserId.toString(),
          {Scope.admin},
        ),
      );
      final dashboard = await endpoints.admin.dashboard(adminSession);

      expect(dashboard.title, 'PocketPod Admin');
      expect(dashboard.scopeNames, contains(Scope.admin.name));
      expect(dashboard.generatedCollections, contains('Products'));
      expect(dashboard.message, contains('Serverpod Auth'));

      final collections = await endpoints.admin.listCollections(adminSession);
      expect(
        collections.map((collection) => collection.key),
        contains('products'),
      );
      expect(
        collections.map((collection) => collection.key),
        contains('posts'),
      );
      expect(
        collections
            .firstWhere((collection) => collection.key == 'products')
            .rowCount,
        greaterThan(0),
      );

      final products = await endpoints.admin.listRecords(
        adminSession,
        'products',
      );
      expect(products.collection.title, 'Products');
      expect(products.rows, isNotEmpty);
      expect(
        products.rows.first.cells.map((cell) => cell.field),
        contains('sku'),
      );

      final posts = await endpoints.admin.listRecords(
        adminSession,
        'posts',
      );
      expect(posts.collection.title, 'Posts');
      expect(posts.rows, isNotEmpty);
      expect(
        posts.collection.fields.map((field) => field.control),
        contains('textarea'),
      );
    });
  });
}

void _ensureTestAuthServices() {
  try {
    AuthServices.instance;
    return;
  } on StateError {
    AuthServices.set(
      tokenManagerBuilders: [
        JwtConfig(
          refreshTokenHashPepper: 'test_refresh_token_pepper',
          algorithm: JwtAlgorithm.hmacSha512(
            SecretKey('test_private_key'),
          ),
        ),
      ],
      identityProviderBuilders: [
        const EmailIdpConfig(
          secretHashPepper: 'test_email_password_hash_pepper',
        ),
      ],
    );
  }
}

Future<void> _createAdminUser(
  Session session, {
  required String email,
  required String password,
}) async {
  await session.db.transaction((transaction) async {
    final authServices = AuthServices.instance;
    final existingAccount = await authServices.emailIdp.admin.findAccount(
      session,
      email: email,
      transaction: transaction,
    );

    if (existingAccount != null) {
      return;
    }

    final authUser = await authServices.authUsers.create(
      session,
      scopes: {Scope.admin},
      transaction: transaction,
    );

    await authServices.userProfiles.createUserProfile(
      session,
      authUser.id,
      UserProfileData(
        userName: email,
        fullName: 'Admin Endpoint Test',
        email: email,
      ),
      transaction: transaction,
    );

    await authServices.emailIdp.admin.createEmailAuthentication(
      session,
      authUserId: authUser.id,
      email: email,
      password: password,
      transaction: transaction,
    );
  });
}
