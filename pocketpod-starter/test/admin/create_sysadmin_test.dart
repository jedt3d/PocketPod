import 'package:test/test.dart';

import '../../tool/admin/lib/create_sysadmin.dart';

void main() {
  group('create_sysadmin command', () {
    test('validates explicit dry-run credentials', () {
      final result = runCreateSysadminCommand([
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

    test('uses environment fallback values', () {
      final result = runCreateSysadminCommand(
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

    test('rejects invalid email and weak password', () {
      final result = runCreateSysadminCommand([
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

    test('rejects placeholder passwords in production mode', () {
      final result = runCreateSysadminCommand([
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

    test('requires stronger passwords in production mode', () {
      final result = runCreateSysadminCommand([
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

    test('keeps persistence disabled until Serverpod Auth is wired', () {
      final result = runCreateSysadminCommand([
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
