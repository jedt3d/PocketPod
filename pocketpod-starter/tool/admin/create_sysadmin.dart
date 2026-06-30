import 'dart:io';

import 'lib/bootstrap_sysadmin.dart';
import 'lib/create_sysadmin.dart';

Future<void> main(List<String> arguments) async {
  final result = await runCreateSysadminCommand(
    arguments,
    environment: Platform.environment,
    persist: bootstrapSysadmin,
  );

  if (result.stdoutMessage.isNotEmpty) {
    stdout.writeln(result.stdoutMessage);
  }
  if (result.stderrMessage.isNotEmpty) {
    stderr.writeln(result.stderrMessage);
  }

  exit(result.exitCode);
}
