import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:service_manager_frontend/main.dart';

void main() {
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.'; // Return CWD
      },
    );
  });

  testWidgets('Full Service Entry Flow Test (Headless)', (WidgetTester tester) async {
    await tester.pumpWidget(const ServiceManagerApp());
    await tester.pumpAndSettle();

    // 1. Verify Dashboard
    expect(find.text("Today's Vehicles"), findsOneWidget, reason: "Dashboard should be visible");

    // 2. Start New Service
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // 3. Verify Tabs
    expect(find.text('New Service Entry'), findsOneWidget);
    expect(find.text('1. Vehicle Details'), findsOneWidget);

    // 4. Enter Vehicle Details
    await tester.enterText(find.widgetWithText(TextField, 'Customer Name'), 'Test User');
    await tester.enterText(find.widgetWithText(TextField, 'Vehicle Model'), 'Test Car');
    await tester.pumpAndSettle();

    // Next
    await tester.tap(find.text('NEXT ▶'));
    await tester.pumpAndSettle();

    // 5. Inspection
    expect(find.text('ENGINE COMPONENTS'), findsOneWidget);
    // Find the InkWell inside the ListTile for 'Engine Oil Level'
    // Structure: Card -> ListTile -> trailing: InkWell
    final itemWidget = find.widgetWithText(ListTile, 'Engine Oil Level');
    final trailing = find.descendant(of: itemWidget, matching: find.byType(InkWell));
    await tester.tap(trailing);
    await tester.pumpAndSettle();

    // Next
    await tester.tap(find.text('NEXT ▶'));
    await tester.pumpAndSettle();

    // 6. Parts
    expect(find.text('Parts Replaced:'), findsOneWidget);
    await tester.tap(find.text('Add Part'));
    await tester.pumpAndSettle();

    // Dialog (Find by label text since we used standard InputDecorations)
    await tester.enterText(find.ancestor(of: find.text('Part Name'), matching: find.byType(TextField)), 'Test Part');
    await tester.enterText(find.ancestor(of: find.text('Price (₹)'), matching: find.byType(TextField)), '1000');
    
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Next
    await tester.tap(find.text('NEXT ▶'));
    await tester.pumpAndSettle();

    // 7. Summary
    expect(find.text('Customer: Test User'), findsOneWidget);
    // 500 (Labor) + 1000 (Part) = 1500
    // "Total: ₹ 1500"
    expect(find.textContaining('1500'), findsOneWidget);

    // 8. Save
    await tester.tap(find.text('SAVE SERVICE'));
    await tester.pumpAndSettle();

    // 9. Verify Return
    // Wait for SnackBar and pop animation
    // await tester.pumpAndSettle() called above should handle it.
    expect(find.text("Today's Vehicles"), findsOneWidget);
    expect(find.text('Service Saved Successfully!'), findsOneWidget);
  });
}
