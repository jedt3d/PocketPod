import 'package:args/args.dart';

const createSysadminUsage = '''
Create the first PocketPod sysadmin.

Usage:
  dart run tool/admin/create_sysadmin.dart --email admin@example.com --password "change-me-now"

Environment fallback:
  POCKETPOD_ADMIN_EMAIL=admin@example.com \\
  POCKETPOD_ADMIN_PASSWORD='strong-password' \\
  dart run tool/admin/create_sysadmin.dart
''';

class CreateSysadminCommandResult {
  const CreateSysadminCommandResult({
    required this.exitCode,
    this.stdoutMessage = '',
    this.stderrMessage = '',
  });

  final int exitCode;
  final String stdoutMessage;
  final String stderrMessage;
}

class CreateSysadminOptions {
  const CreateSysadminOptions({
    required this.email,
    required this.password,
    required this.runMode,
    required this.dryRun,
    required this.force,
    required this.allowAdditionalAdmin,
    required this.promoteExisting,
  });

  final String email;
  final String password;
  final String runMode;
  final bool dryRun;
  final bool force;
  final bool allowAdditionalAdmin;
  final bool promoteExisting;

  bool get isProduction => runMode == 'production';
}

CreateSysadminCommandResult runCreateSysadminCommand(
  List<String> arguments, {
  required Map<String, String> environment,
}) {
  final parser = _buildParser();
  late ArgResults parsed;

  try {
    parsed = parser.parse(arguments);
  } on FormatException catch (error) {
    return CreateSysadminCommandResult(
      exitCode: 64,
      stderrMessage: '${error.message}\n\n${parser.usage}',
    );
  }

  if (parsed['help'] as bool) {
    return CreateSysadminCommandResult(
      exitCode: 0,
      stdoutMessage: '$createSysadminUsage\n${parser.usage}',
    );
  }

  final options = CreateSysadminOptions(
    email:
        _stringOption(parsed, 'email') ??
        environment['POCKETPOD_ADMIN_EMAIL'] ??
        '',
    password:
        _stringOption(parsed, 'password') ??
        environment['POCKETPOD_ADMIN_PASSWORD'] ??
        '',
    runMode:
        _stringOption(parsed, 'mode') ??
        environment['SERVERPOD_RUN_MODE'] ??
        'development',
    dryRun: parsed['dry-run'] as bool,
    force: parsed['force'] as bool,
    allowAdditionalAdmin: parsed['allow-additional-admin'] as bool,
    promoteExisting: parsed['promote-existing'] as bool,
  );

  final issues = validateCreateSysadminOptions(options);
  if (issues.isNotEmpty) {
    return CreateSysadminCommandResult(
      exitCode: 64,
      stderrMessage: issues.map((issue) => '- $issue').join('\n'),
    );
  }

  if (!options.dryRun) {
    return const CreateSysadminCommandResult(
      exitCode: 78,
      stderrMessage:
          'Serverpod Auth persistence is not wired yet. '
          'Re-run with --dry-run to validate the bootstrap inputs for now.',
    );
  }

  return CreateSysadminCommandResult(
    exitCode: 0,
    stdoutMessage:
        'Sysadmin bootstrap request is valid (dry run).\n'
        'Email: ${options.email}\n'
        'Run mode: ${options.runMode}\n'
        'Force password update: ${options.force}\n'
        'Allow additional admin: ${options.allowAdditionalAdmin}\n'
        'Promote existing user: ${options.promoteExisting}',
  );
}

List<String> validateCreateSysadminOptions(CreateSysadminOptions options) {
  final issues = <String>[];
  final email = options.email.trim();
  final password = options.password;

  if (email.isEmpty) {
    issues.add('Provide --email or POCKETPOD_ADMIN_EMAIL.');
  } else if (!_looksLikeEmail(email)) {
    issues.add('Email must look like a valid email address.');
  }

  if (password.isEmpty) {
    issues.add('Provide --password or POCKETPOD_ADMIN_PASSWORD.');
  } else {
    issues.addAll(_passwordIssues(password, production: options.isProduction));
  }

  if (options.runMode.trim().isEmpty) {
    issues.add('Run mode cannot be empty.');
  }

  return issues;
}

ArgParser _buildParser() {
  return ArgParser()
    ..addOption(
      'email',
      help: 'Sysadmin email. Falls back to POCKETPOD_ADMIN_EMAIL.',
    )
    ..addOption(
      'password',
      help: 'Initial password. Falls back to POCKETPOD_ADMIN_PASSWORD.',
    )
    ..addOption(
      'mode',
      help: 'Serverpod run mode used for safety checks.',
      defaultsTo: null,
      allowed: ['development', 'test', 'staging', 'production', 'benchmark'],
    )
    ..addFlag(
      'dry-run',
      help: 'Validate the request without writing to Serverpod Auth tables.',
      negatable: false,
    )
    ..addFlag(
      'force',
      help: 'Allow replacing the password for an existing sysadmin.',
      negatable: false,
    )
    ..addFlag(
      'allow-additional-admin',
      help: 'Allow creating another sysadmin when one already exists.',
      negatable: false,
    )
    ..addFlag(
      'promote-existing',
      help: 'Promote an existing user to sysadmin instead of creating one.',
      negatable: false,
    )
    ..addFlag('help', abbr: 'h', help: 'Show this help.', negatable: false);
}

String? _stringOption(ArgResults results, String name) {
  final value = results[name] as String?;
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return value.trim();
}

bool _looksLikeEmail(String value) {
  final at = value.indexOf('@');
  if (at <= 0 || at != value.lastIndexOf('@')) {
    return false;
  }

  final domain = value.substring(at + 1);
  return domain.contains('.') &&
      !domain.startsWith('.') &&
      !domain.endsWith('.') &&
      !value.contains(' ');
}

List<String> _passwordIssues(String password, {required bool production}) {
  final issues = <String>[];
  final lower = password.toLowerCase();

  if (password.length < 8) {
    issues.add('Password must be at least 8 characters.');
  }

  if (!production) {
    return issues;
  }

  if (password.length < 12) {
    issues.add('Production password must be at least 12 characters.');
  }
  if (!RegExp('[A-Z]').hasMatch(password)) {
    issues.add(
      'Production password must include at least one uppercase letter.',
    );
  }
  if (!RegExp('[a-z]').hasMatch(password)) {
    issues.add(
      'Production password must include at least one lowercase letter.',
    );
  }
  if (!RegExp('[0-9]').hasMatch(password)) {
    issues.add('Production password must include at least one number.');
  }
  if (!RegExp(r'''[^A-Za-z0-9]''').hasMatch(password)) {
    issues.add('Production password must include at least one symbol.');
  }

  final placeholders = [
    'change-me',
    'changeme',
    'password',
    'admin123',
    'pocketpod',
  ];
  if (placeholders.any(lower.contains)) {
    issues.add('Production passwords cannot contain placeholder words.');
  }

  return issues;
}
