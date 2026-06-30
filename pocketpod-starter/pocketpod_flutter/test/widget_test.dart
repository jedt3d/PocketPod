import 'package:flutter_test/flutter_test.dart';
import 'package:pocketpod_flutter/main.dart';

void main() {
  testWidgets('renders the starter greeting screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Serverpod Example'), findsOneWidget);
    expect(find.text('Send to Server'), findsOneWidget);
    expect(find.text('No server response yet.'), findsOneWidget);
  });
}
