import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketpod_admin_ui/main.dart';

void main() {
  testWidgets('renders the Cycle 1 admin shell', (tester) async {
    await tester.pumpWidget(const PocketPodAdminApp());

    expect(find.text('PocketPod Admin'), findsOneWidget);
    expect(find.text('Admin Input Examples'), findsNWidgets(2));
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.byKey(const Key('admin_status_line')), findsOneWidget);
    expect(find.byKey(const Key('client_base_line')), findsOneWidget);
    expect(find.byKey(const Key('cycle_1_placeholder')), findsOneWidget);
  });
}
