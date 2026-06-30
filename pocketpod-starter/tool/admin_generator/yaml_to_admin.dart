import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'lib/admin_generator.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(
      'input',
      abbr: 'i',
      defaultsTo: 'pocketpod_server/lib/src',
      help: 'Directory containing Serverpod .spy.yaml model files.',
    )
    ..addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'tool/admin_generator/generated',
      help: 'Directory where generated admin files should be written.',
    )
    ..addFlag(
      'preview',
      defaultsTo: true,
      help: 'Generate an admin_preview.html file alongside Dart output.',
    )
    ..addFlag(
      'format',
      defaultsTo: true,
      help: 'Run dart format on generated Dart files.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print usage information.',
    );

  final results = parser.parse(arguments);
  if (results.flag('help')) {
    stdout.writeln('Generate PocketPod admin UI code from Serverpod YAML.');
    stdout.writeln();
    stdout.writeln(parser.usage);
    return;
  }

  final input = Directory(results.option('input')!);
  final output = Directory(results.option('output')!);
  if (!input.existsSync()) {
    stderr.writeln('Input directory does not exist: ${input.path}');
    exitCode = 64;
    return;
  }

  output.createSync(recursive: true);

  final generator = AdminGenerator();
  final models = <AdminModel>[];
  final dartTargets = <String>[];
  final files =
      input
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.spy.yaml'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  for (final file in files) {
    final model = generator.parseModel(file.readAsStringSync());
    models.add(model);

    final target = File(p.join(output.path, generator.adminFileName(model)));
    target.writeAsStringSync(generator.generateFlutterSource(model));
    dartTargets.add(target.path);
    stdout.writeln('Generated ${target.path}');
  }

  if (models.isNotEmpty) {
    final metadataTarget = File(
      p.join(output.path, generator.adminMetadataFileName),
    );
    metadataTarget.writeAsStringSync(
      generator.generateFlutterMetadataSource(models),
    );
    dartTargets.add(metadataTarget.path);
    stdout.writeln('Generated ${metadataTarget.path}');
  }

  if (results.flag('format') && dartTargets.isNotEmpty) {
    final formatResult = Process.runSync('dart', ['format', ...dartTargets]);
    stdout.write(formatResult.stdout);
    stderr.write(formatResult.stderr);
    if (formatResult.exitCode != 0) {
      exitCode = formatResult.exitCode;
      return;
    }
  }

  if (results.flag('preview')) {
    final preview = File(p.join(output.path, 'admin_preview.html'));
    preview.writeAsStringSync(generator.generatePreviewHtml(models));
    stdout.writeln('Generated ${preview.path}');
  }

  if (models.isEmpty) {
    stdout.writeln('No .spy.yaml model files found in ${input.path}.');
  }
}
