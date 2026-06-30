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
      expect(generated, contains('CheckboxListTile('));
      expect(generated, contains('maxLines: 8'));
      expect(generated, contains("Text('Save Post')"));
      expect(regenerated, generated);
    });

    test('classifies smart form controls', () {
      final source = File(
        'tool/admin_generator/fixtures/all_input_types.spy.yaml',
      ).readAsStringSync();

      final model = generator.parseModel(source);
      final controls = {
        for (final field in model.fields) field.name: field.formControl,
      };

      expect(controls['title'], AdminFormControl.text);
      expect(controls['body'], AdminFormControl.textarea);
      expect(controls['summary'], AdminFormControl.textarea);
      expect(controls['published'], AdminFormControl.checkbox);
      expect(controls['publishedAt'], AdminFormControl.dateTime);
      expect(controls['stock'], AdminFormControl.integer);
      expect(controls['price'], AdminFormControl.decimal);
      expect(controls['status'], AdminFormControl.enumSelect);
      expect(controls['categoryId'], AdminFormControl.relationSelect);
      expect(controls['tags'], AdminFormControl.arrayList);
      expect(model.fields.first.isRequired, isTrue);
      expect(model.fields[2].isNullable, isTrue);
    });

    test('generates a static admin preview', () {
      final allInputTypes = generator.parseModel(
        File(
          'tool/admin_generator/fixtures/all_input_types.spy.yaml',
        ).readAsStringSync(),
      );
      final product = generator.parseModel(
        File(
          'tool/admin_generator/fixtures/product.spy.yaml',
        ).readAsStringSync(),
      );
      final post = generator.parseModel(
        File('tool/admin_generator/fixtures/post.spy.yaml').readAsStringSync(),
      );

      final html = generator.generatePreviewHtml([
        allInputTypes,
        product,
        post,
      ]);

      expect(html, contains('<title>PocketPod Admin Preview</title>'));
      expect(html, contains('PocketPod Admin'));
      expect(html, contains('Collections / Admin Input Examples'));
      expect(html, contains('API preview'));
      expect(html, contains('Search Admin Input Examples...'));
      expect(html, contains('Records'));
      expect(html, contains('<textarea'));
      expect(html, contains('type="checkbox"'));
      expect(html, contains('type="datetime-local"'));
      expect(html, contains('<select'));
      expect(html, contains('<span class="required">*</span>'));
      expect(html, contains('<span class="optional">optional</span>'));
      expect(html, contains('Admin Input Examples'));
      expect(html, contains('Products'));
      expect(html, contains('Posts'));
      expect(html, contains('admin scope required'));
    });

    test('generates deterministic Flutter metadata for admin_ui runtime', () {
      final allInputTypes = generator.parseModel(
        File(
          'tool/admin_generator/fixtures/all_input_types.spy.yaml',
        ).readAsStringSync(),
      );
      final post = generator.parseModel(
        File('tool/admin_generator/fixtures/post.spy.yaml').readAsStringSync(),
      );

      final generated = generator.generateFlutterMetadataSource([
        post,
        allInputTypes,
      ]);
      final regenerated = generator.generateFlutterMetadataSource([
        allInputTypes,
        post,
      ]);

      expect(generated, contains('class GeneratedAdminCollection'));
      expect(generated, contains('const generatedAdminCollections'));
      expect(generated, contains("routeName: '/admin/admin-input-examples'"));
      expect(generated, contains("control: 'textarea'"));
      expect(generated, contains("control: 'checkbox'"));
      expect(generated, contains("control: 'datetime'"));
      expect(generated, contains("control: 'relation'"));
      expect(generated, contains('required: true'));
      expect(regenerated, generated);
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
      expect(
        File('${tempDir.path}/admin_input_example_admin.dart').existsSync(),
        isTrue,
      );
      expect(File('${tempDir.path}/product_admin.dart').existsSync(), isTrue);
      expect(File('${tempDir.path}/post_admin.dart').existsSync(), isTrue);
      expect(
        File('${tempDir.path}/generated_admin_collections.dart').existsSync(),
        isTrue,
      );
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
