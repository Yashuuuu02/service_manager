import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:service_manager_frontend/main.dart' as app; 
import 'package:service_manager_frontend/backend/providers/service_provider.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full Service Entry Flow Test', (WidgetTester tester) async {
    // 1. Start App
    app.main();
    await tester.pumpAndSettle();

    // Verify initial state (Dashboard)
    expect(find.text("Today's Vehicles"), findsOneWidget);
    // Note: Count might be 1 (seed) or more if user created some. 
    // We'll store initial count to compare later.
    // Finding the count text is tricky without keys, but we can look for the value text.
    // Let's rely on adding a record and seeing if UI doesn't crash and returns.

    // 2. Start New Service
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Verify we are on Vehicle Details tab
    expect(find.text('New Service Entry'), findsOneWidget);
    expect(find.text('1. Vehicle Details'), findsOneWidget);

    // 3. Enter Vehicle Details
    await tester.enterText(find.widgetWithText(TextField, 'Customer Name'), 'Test User');
    await tester.enterText(find.widgetWithText(TextField, 'Vehicle Model'), 'Test Car');
    await tester.enterText(find.widgetWithText(TextField, 'Phone'), '1234567890');
    await tester.pumpAndSettle();

    // Go to Next Tab (Inspection)
    await tester.tap(find.text('NEXT ▶'));
    await tester.pumpAndSettle();

    // 4. Inspection Tab
    expect(find.text('ENGINE COMPONENTS'), findsOneWidget);
    // Toggle "Engine Oil Level"
    await tester.tap(find.widgetWithText(InkWell, 'Engine Oil Level')); // Adjust finder if needed
    await tester.pumpAndSettle();
    
    // Go to Next Tab (Parts)
    await tester.tap(find.text('NEXT ▶'));
    await tester.pumpAndSettle();

    // 5. Parts Tab
    expect(find.text('Parts Replaced:'), findsOneWidget);
    // Add a part
    await tester.tap(find.text('Add Part'));
    await tester.pumpAndSettle();
    
    // Fill Dialog
    await tester.enterText(find.widgetWithText(TextField, 'Part Name'), 'Test Part');
    await tester.enterText(find.widgetWithText(TextField, 'Price (₹)'), '1000');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify part added
    expect(find.text('Test Part'), findsOneWidget);
    expect(find.text('₹ 1000 x 1 = ₹ 1000'), findsOneWidget);

    // Go to Next Tab (Summary)
    await tester.tap(find.text('NEXT ▶'));
    await tester.pumpAndSettle();

    // 6. Summary Tab
    expect(find.text('Customer: Test User'), findsOneWidget);
    expect(find.text('Vehicle: Test Car'), findsOneWidget);
    // Total should include Labor (500) + New Part (1000) = 1500
    // Note: Initial mock data might have been mapped differently, but based on current code:
    // _partsUsed starts with Labor 500.
    // We added 1000. Total 1500.
    expect(find.textContaining('1500'), findsOneWidget);

    // 7. Save
    await tester.tap(find.text('SAVE SERVICE'));
    await tester.pumpAndSettle();

    // 8. Verify Return to Dashboard
    expect(find.text("Today's Vehicles"), findsOneWidget);
    // Verify SnackBar
    expect(find.text('Service Saved Successfully!'), findsOneWidget);
    
    // Optional: Check if we can see the PDF button or just that we are back safely
  });
}
