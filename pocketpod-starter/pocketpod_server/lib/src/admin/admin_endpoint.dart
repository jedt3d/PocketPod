import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class AdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope.admin};

  Future<AdminDashboard> dashboard(Session session) async {
    final authenticated = session.authenticated!;

    return AdminDashboard(
      title: 'PocketPod Admin',
      signedInUserId: authenticated.userIdentifier,
      scopeNames:
          authenticated.scopes.map((scope) => scope.name).nonNulls.toList()
            ..sort(),
      generatedCollections: [
        'Admin Input Examples',
        'Products',
        'Posts',
      ],
      message: 'Signed in with Serverpod Auth and Scope.admin.',
      checkedAt: DateTime.now().toUtc(),
    );
  }
}
