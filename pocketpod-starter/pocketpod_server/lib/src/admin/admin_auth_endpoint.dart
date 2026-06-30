import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

class AdminAuthEndpoint extends Endpoint {
  Future<AuthSuccess> login(
    Session session, {
    required String email,
    required String password,
  }) async {
    final authSuccess = await AuthServices.instance.emailIdp.login(
      session,
      email: email,
      password: password,
    );

    if (!authSuccess.scopeNames.contains(Scope.admin.name)) {
      throw Exception('Admin scope required.');
    }

    return authSuccess;
  }
}
