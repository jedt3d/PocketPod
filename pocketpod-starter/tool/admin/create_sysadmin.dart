import 'dart:io';

import 'lib/create_sysadmin.dart';

void main(List<String> arguments) {
  final result = runCreateSysadminCommand(
    arguments,
    environment: Platform.environment,
  );

  if (result.stdoutMessage.isNotEmpty) {
    stdout.writeln(result.stdoutMessage);
  }
  if (result.stderrMessage.isNotEmpty) {
    stderr.writeln(result.stderrMessage);
  }

  exitCode = result.exitCode;
}
