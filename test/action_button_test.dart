import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/widgets/action_button.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  group('ActionButton Tests', () {
    testWidgets('ActionButton.primary displays correctly', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ActionButton.primary(
                  context: context,
                  onPressed: () => buttonPressed = true,
                  label: 'Test Button',
                  icon: Symbols.add_circle,
                );
              }
            ),
          ),
        ),
      );

      // Verify the button is displayed
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byIcon(Symbols.add_circle), findsOneWidget);

      // Verify the button can be pressed
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(buttonPressed, isTrue);
    });

    testWidgets('ActionButton with custom properties displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              onPressed: () {},
              label: 'Custom Button',
              icon: Symbols.edit,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              alignment: MainAxisAlignment.center,
            ),
          ),
        ),
      );

      // Verify the button is displayed with custom properties
      expect(find.text('Custom Button'), findsOneWidget);
      expect(find.byIcon(Symbols.edit), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('ActionButton respects alignment property', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              onPressed: () {},
              label: 'Centered Button',
              icon: Symbols.add_circle,
              alignment: MainAxisAlignment.center,
            ),
          ),
        ),
      );

      // Find the specific Row widget that belongs to ActionButton
      final actionButtonRows = find.byType(Row);
      expect(actionButtonRows, findsWidgets);
      
      final rowWidget = tester.widget<Row>(actionButtonRows.first);
      expect(rowWidget.mainAxisAlignment, MainAxisAlignment.center);
    });
  });
}
