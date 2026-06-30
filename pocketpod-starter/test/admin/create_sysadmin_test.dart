import 'package:test/test.dart';

import '../../tool/admin/lib/create_sysadmin.dart';

void main() {
  group('create_sysadmin command', () {
    test('validates explicit dry-run credentials', () async {
      final result = await runCreateSysadminCommand([
        '--email',
        'admin@example.com',
        '--password',
        'change-me-now',
        '--dry-run',
      ], environment: {});

      expect(result.exitCode, 0);
      expect(result.stdoutMessage, contains('valid (dry run)'));
      expect(result.stdoutMessage, contains('admin@example.com'));
      expect(result.stderrMessage, isEmpty);
    });

    test('uses environment fallback values', () async {
      final result = await runCreateSysadminCommand(
        ['--dry-run'],
        environment: {
          'POCKETPOD_ADMIN_EMAIL': 'env-admin@example.com',
          'POCKETPOD_ADMIN_PASSWORD': r'Strong-env-123',
          'SERVERPOD_RUN_MODE': 'staging',
        },
      );

      expect(result.exitCode, 0);
      expect(result.stdoutMessage, contains('env-admin@example.com'));
      expect(result.stdoutMessage, contains('Run mode: staging'));
    });

    test('rejects invalid email and weak password', () async {
      final result = await runCreateSysadminCommand([
        '--email',
        'not-an-email',
        '--password',
        'weak',
        '--dry-run',
      ], environment: {});

      expect(result.exitCode, 64);
      expect(result.stderrMessage, contains('valid email'));
      expect(result.stderrMessage, contains('at least 8 characters'));
    });

    test('rejects placeholder passwords in production mode', () async {
      final result = await runCreateSysadminCommand([
        '--email',
        'admin@example.com',
        '--password',
        r'Change-me-now-123!',
        '--mode',
        'production',
        '--dry-run',
      ], environment: {});

      expect(result.exitCode, 64);
      expect(result.stderrMessage, contains('placeholder words'));
    });

    test('requires stronger passwords in production mode', () async {
      final result = await runCreateSysadminCommand([
        '--email',
        'admin@example.com',
        '--password',
        'lowercase-only',
        '--mode',
        'production',
        '--dry-run',
      ], environment: {});

      expect(result.exitCode, 64);
      expect(result.stderrMessage, contains('uppercase'));
      expect(result.stderrMessage, contains('number'));
    });

    test('delegates to persistence when dry-run is disabled', () async {
      CreateSysadminOptions? capturedOptions;

      final result = await runCreateSysadminCommand(
        ['--email', 'admin@example.com', '--password', r'Strong-pass-123'],
        environment: {},
        persist: (options) async {
          capturedOptions = options;
          return const CreateSysadminCommandResult(
            exitCode: 0,
            stdoutMessage: 'created',
          );
        },
      );

      expect(result.exitCode, 0);
      expect(result.stdoutMessage, 'created');
      expect(capturedOptions?.email, 'admin@example.com');
      expect(capturedOptions?.dryRun, isFalse);
    });

    test('keeps persistence disabled without a persistence callback', () async {
      final result = await runCreateSysadminCommand([
        '--email',
        'admin@example.com',
        '--password',
        r'Strong-pass-123',
      ], environment: {});

      expect(result.exitCode, 78);
      expect(result.stderrMessage, contains('persistence is not wired yet'));
    });
  });
}
