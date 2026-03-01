import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SnackBar Duration Tests', () {
    testWidgets('SnackBar with 2 second duration', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test message'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Show SnackBar'),
              );
            },
          ),
        ),
      ));

      // Verify the button exists
      expect(find.text('Show SnackBar'), findsOneWidget);

      // Tap the button to show the SnackBar
      await tester.tap(find.text('Show SnackBar'));
      await tester.pump();

      // Verify the SnackBar is shown
      expect(find.text('Test message'), findsOneWidget);

      // Verify the SnackBar has the correct duration
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, const Duration(seconds: 2));
    });

    testWidgets('SnackBar with 3 second duration', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test message'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text('Show SnackBar'),
              );
            },
          ),
        ),
      ));

      // Verify the button exists
      expect(find.text('Show SnackBar'), findsOneWidget);

      // Tap the button to show the SnackBar
      await tester.tap(find.text('Show SnackBar'));
      await tester.pump();

      // Verify the SnackBar is shown
      expect(find.text('Test message'), findsOneWidget);

      // Verify the SnackBar has the correct duration
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, const Duration(seconds: 3));
    });
  });
}
