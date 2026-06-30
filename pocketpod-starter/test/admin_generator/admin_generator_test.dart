import 'dart:io';

import 'package:test/test.dart';

import '../../tool/admin_generator/lib/admin_generator.dart';

void main() {
  group('AdminGenerator', () {
    const generator = AdminGenerator();

    test('parses a Serverpod model YAML file', () {
      final source = File(
        'tool/admin_generator/fixtures/product.spy.yaml',
      ).readAsStringSync();

      final model = generator.parseModel(source);

      expect(model.className, 'Product');
      expect(model.tableName, 'product');
      expect(model.title, 'Products');
      expect(model.routeName, '/admin/products');
      expect(model.fields.map((field) => field.name), [
        'name',
        'slug',
        'description',
        'price',
        'stock',
        'active',
        'createdAt',
      ]);
      expect(model.fields.last.kind, AdminFieldKind.dateTime);
    });

    test('generates deterministic Flutter source', () {
      final source = File(
        'tool/admin_generator/fixtures/post.spy.yaml',
      ).readAsStringSync();

      final model = generator.parseModel(source);
      final generated = generator.generateFlutterSource(model);
      final regenerated = generator.generateFlutterSource(model);

      expect(
        generated,
        contains('class PostAdminScreen extends StatelessWidget'),
      );
      expect(generated, contains("static const title = 'Posts';"));
      expect(generated, contains("static const routeName = '/admin/posts';"));
      expect(generated, contains("DataColumn(label: Text('Published'))"));
      expect(generated, contains('SwitchListTile('));
      expect(generated, contains("Text('Save Post')"));
      expect(regenerated, generated);
    });

    test('generates a static admin preview', () {
      final product = generator.parseModel(
        File(
          'tool/admin_generator/fixtures/product.spy.yaml',
        ).readAsStringSync(),
      );
      final post = generator.parseModel(
        File('tool/admin_generator/fixtures/post.spy.yaml').readAsStringSync(),
      );

      final html = generator.generatePreviewHtml([product, post]);

      expect(html, contains('<title>PocketPod Admin Preview</title>'));
      expect(html, contains('PocketPod Admin'));
      expect(html, contains('Products'));
      expect(html, contains('Posts'));
      expect(html, contains('admin scope required'));
    });

    test('CLI writes generated Dart and preview files', () async {
      final tempDir = Directory.systemTemp.createTempSync(
        'pocketpod_admin_generator_test_',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final result = await Process.run('dart', [
        'tool/admin_generator/yaml_to_admin.dart',
        '--input',
        'tool/admin_generator/fixtures',
        '--output',
        tempDir.path,
      ]);

      expect(result.exitCode, 0, reason: result.stderr as String?);
      expect(File('${tempDir.path}/product_admin.dart').existsSync(), isTrue);
      expect(File('${tempDir.path}/post_admin.dart').existsSync(), isTrue);
      expect(File('${tempDir.path}/admin_preview.html').existsSync(), isTrue);
    });

    test('rejects YAML without fields', () {
      expect(
        () => generator.parseModel('class: Empty\n'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
