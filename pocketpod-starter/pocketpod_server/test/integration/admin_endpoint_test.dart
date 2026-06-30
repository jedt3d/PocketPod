import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import 'package:pocketpod_server/src/generated/protocol.dart';

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

      final adminExample = await endpoints.admin.getRecord(
        adminSession,
        'admin_input_examples',
        '1',
      );
      expect(_cellValue(adminExample, 'title'), 'Launch article');

      final productId = products.rows.first.id;
      await expectLater(
        endpoints.admin.updateRecord(
          sessionBuilder,
          'products',
          productId,
          _cells({
            'sku': 'SKU-1001',
            'name': 'Blocked Update',
            'description': 'Should not save.',
            'price': '1.00',
            'stock': '1',
            'published': 'false',
            'categoryId': '1',
          }),
        ),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
      await expectLater(
        endpoints.admin.updateRecord(
          nonAdminSession,
          'products',
          productId,
          _cells({
            'sku': 'SKU-1001',
            'name': 'Blocked Update',
            'description': 'Should not save.',
            'price': '1.00',
            'stock': '1',
            'published': 'false',
            'categoryId': '1',
          }),
        ),
        throwsA(isA<ServerpodInsufficientAccessException>()),
      );

      final updatedProduct = await endpoints.admin.updateRecord(
        adminSession,
        'products',
        productId,
        _cells({
          'sku': 'SKU-1001',
          'name': 'Updated Starter License',
          'description': 'Edited through the guarded admin endpoint.',
          'price': '59.00',
          'stock': '88',
          'published': 'true',
          'categoryId': '2',
        }),
      );
      expect(_cellValue(updatedProduct, 'name'), 'Updated Starter License');
      expect(_cellValue(updatedProduct, 'stock'), '88');

      final reloadedProduct = await endpoints.admin.getRecord(
        adminSession,
        'products',
        productId,
      );
      expect(_cellValue(reloadedProduct, 'name'), 'Updated Starter License');
      expect(_cellValue(reloadedProduct, 'categoryId'), '2');

      final postId = posts.rows.first.id;
      final updatedPost = await endpoints.admin.updateRecord(
        adminSession,
        'posts',
        postId,
        _cells({
          'title': 'Edited Serverpod SQLite Post',
          'body': 'Saved from the Cycle 4B admin edit endpoint.',
          'published': 'false',
          'publishedAt': '',
          'authorId': '1',
        }),
      );
      expect(_cellValue(updatedPost, 'title'), 'Edited Serverpod SQLite Post');
      expect(_cellValue(updatedPost, 'published'), 'false');

      final reloadedPost = await endpoints.admin.getRecord(
        adminSession,
        'posts',
        postId,
      );
      expect(_cellValue(reloadedPost, 'body'), contains('Cycle 4B'));
      expect(_cellValue(reloadedPost, 'publishedAt'), isEmpty);

      await expectLater(
        endpoints.admin.createRecord(
          nonAdminSession,
          'products',
          _cells({
            'sku': 'SKU-BLOCKED',
            'name': 'Blocked Create',
            'description': 'Should not save.',
            'price': '1.00',
            'stock': '1',
            'published': 'false',
            'categoryId': '1',
          }),
        ),
        throwsA(isA<ServerpodInsufficientAccessException>()),
      );

      final createdProduct = await endpoints.admin.createRecord(
        adminSession,
        'products',
        _cells({
          'sku': 'SKU-2001',
          'name': 'Created Phase 6 Product',
          'description': 'Created through the guarded admin endpoint.',
          'price': '99.00',
          'stock': '12',
          'published': 'true',
          'categoryId': '2',
        }),
      );
      expect(_cellValue(createdProduct, 'name'), 'Created Phase 6 Product');

      final createdProductId = createdProduct.id;
      final deleteResult = await endpoints.admin.deleteRecord(
        adminSession,
        'products',
        createdProductId,
      );
      expect(deleteResult, isTrue);

      await expectLater(
        endpoints.admin.getRecord(adminSession, 'products', createdProductId),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

List<AdminRecordCell> _cells(Map<String, String> values) {
  return values.entries
      .map((entry) => AdminRecordCell(field: entry.key, value: entry.value))
      .toList();
}

String _cellValue(AdminRecord record, String field) {
  return record.cells.firstWhere((cell) => cell.field == field).value;
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
