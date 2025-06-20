import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel_drive_smart/main.dart';

void main() {
  testWidgets('Admin panel renders a Scaffold', (WidgetTester tester) async {
    // Pump your real app
    await tester.pumpWidget(const DriveSmartAdminApp());
    await tester.pumpAndSettle();

    // Verify that at least one Scaffold is in the widget tree
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
