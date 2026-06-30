import 'dart:io';

import 'package:pocketpod_server/src/auth/pocketpod_auth.dart';
import 'package:pocketpod_server/src/generated/endpoints.dart';
import 'package:pocketpod_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'create_sysadmin.dart';

Future<CreateSysadminCommandResult> bootstrapSysadmin(
  CreateSysadminOptions options,
) async {
  if (options.runMode == 'benchmark') {
    return const CreateSysadminCommandResult(
      exitCode: 64,
      stderrMessage:
          'Sysadmin bootstrap supports development, test, staging, '
          'and production run modes. Benchmark mode is not a Serverpod run mode.',
    );
  }

  final pod = Serverpod(
    ['--mode', options.runMode, '--apply-migrations'],
    Protocol(),
    Endpoints(),
    serverDirectory: Directory('pocketpod_server'),
    configOverride: _useEphemeralPorts,
  );
  initializePocketPodAuth(pod);

  try {
    await pod.start(runInGuardedZone: false);

    final message = await pod.withSession(
      (session) => _bootstrapSysadminWithSession(session, options),
      enableLogging: false,
    );

    return CreateSysadminCommandResult(exitCode: 0, stdoutMessage: message);
  } on SysadminBootstrapException catch (error) {
    return CreateSysadminCommandResult(
      exitCode: error.exitCode,
      stderrMessage: error.message,
    );
  } catch (error) {
    return CreateSysadminCommandResult(
      exitCode: 70,
      stderrMessage: 'Failed to bootstrap sysadmin: $error',
    );
  } finally {
    try {
      await pod.shutdown(exitProcess: false);
    } catch (_) {
      // Startup can fail before all shutdown hooks are registered.
    }
  }
}

Future<String> _bootstrapSysadminWithSession(
  Session session,
  CreateSysadminOptions options,
) async {
  final email = options.email.trim().toLowerCase();
  final adminScopeName = Scope.admin.name!;

  return session.db.transaction((transaction) async {
    final authServices = AuthServices.instance;
    final emailIdp = authServices.emailIdp;
    final existingAdmins = await _findExistingAdmins(
      session,
      transaction: transaction,
    );
    final existingAccount = await emailIdp.admin.findAccount(
      session,
      email: email,
      transaction: transaction,
    );

    if (existingAccount == null) {
      if (existingAdmins.isNotEmpty && !options.allowAdditionalAdmin) {
        throw const SysadminBootstrapException(
          'A sysadmin already exists. Pass --allow-additional-admin to create '
          'another admin account.',
        );
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
          fullName: 'PocketPod Sysadmin',
          email: email,
        ),
        transaction: transaction,
      );
      await emailIdp.admin.createEmailAuthentication(
        session,
        authUserId: authUser.id,
        email: email,
        password: options.password,
        transaction: transaction,
      );

      return 'Created sysadmin: $email';
    }

    final authUser = await authServices.authUsers.get(
      session,
      authUserId: existingAccount.authUserId,
      transaction: transaction,
    );
    final isAdmin = authUser.scopeNames.contains(adminScopeName);

    if (!isAdmin) {
      if (!options.promoteExisting) {
        throw const SysadminBootstrapException(
          'The email already exists but is not a sysadmin. Pass '
          '--promote-existing to grant Scope.admin.',
        );
      }

      await authServices.authUsers.update(
        session,
        authUserId: authUser.id,
        scopes: {...authUser.scopeNames.map(Scope.new), Scope.admin},
        transaction: transaction,
      );

      if (options.force) {
        await emailIdp.admin.setPassword(
          session,
          email: email,
          password: options.password,
          transaction: transaction,
        );
      }

      return options.force
          ? 'Promoted existing user and updated password: $email'
          : 'Promoted existing user to sysadmin: $email';
    }

    if (options.force) {
      await emailIdp.admin.setPassword(
        session,
        email: email,
        password: options.password,
        transaction: transaction,
      );

      return 'Updated existing sysadmin password: $email';
    }

    return 'Sysadmin already exists: $email';
  });
}

class SysadminBootstrapException implements Exception {
  const SysadminBootstrapException(this.message, {this.exitCode = 73});

  final String message;
  final int exitCode;

  @override
  String toString() => message;
}

Future<List<AuthUserModel>> _findExistingAdmins(
  Session session, {
  required Transaction transaction,
}) async {
  final adminScopeName = Scope.admin.name!;
  final users = await AuthServices.instance.authUsers.list(
    session,
    transaction: transaction,
  );

  return users
      .where((user) => user.scopeNames.contains(adminScopeName))
      .toList();
}

ServerpodConfig _useEphemeralPorts(ServerpodConfig config) {
  ServerConfig ephemeral(ServerConfig server) {
    return ServerConfig(
      port: 0,
      publicHost: server.publicHost,
      publicPort: 0,
      publicScheme: server.publicScheme,
    );
  }

  return config.copyWith(
    apiServer: ephemeral(config.apiServer),
    insightsServer: config.insightsServer == null
        ? null
        : ephemeral(config.insightsServer!),
    webServer: config.webServer == null ? null : ephemeral(config.webServer!),
  );
}
