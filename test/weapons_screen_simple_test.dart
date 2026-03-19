import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dnd_app/views/information/weapons_screen.dart';
import 'package:dnd_app/viewmodels/weapons_viewmodel.dart';

void main() {
  group('WeaponsScreen Simple Tests', () {
    testWidgets('WeaponsScreen should display loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<WeaponsViewModel>(
          create: (_) => WeaponsViewModel(),
          child: const MaterialApp(
            home: WeaponsScreen(),
          ),
        ),
      );

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('WeaponsScreen should display search field', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<WeaponsViewModel>(
          create: (_) => WeaponsViewModel(),
          child: const MaterialApp(
            home: WeaponsScreen(),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify search field is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search weapons...'), findsOneWidget);
    });

    testWidgets('WeaponsScreen should show filter dialog when filter button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<WeaponsViewModel>(
          create: (_) => WeaponsViewModel(),
          child: const MaterialApp(
            home: WeaponsScreen(),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Tap filter button
      await tester.tap(find.byIcon(Icons.filter_alt));
      await tester.pumpAndSettle();

      // Verify filter dialog is shown
      expect(find.text('Filter Weapons'), findsOneWidget);
      expect(find.text('Weapon Type'), findsOneWidget);
    });

    testWidgets('WeaponsScreen should have correct app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<WeaponsViewModel>(
          create: (_) => WeaponsViewModel(),
          child: const MaterialApp(
            home: WeaponsScreen(),
          ),
        ),
      );

      // Verify app bar title
      expect(find.text('Weapons'), findsOneWidget);
    });

    testWidgets('WeaponsScreen should have filter button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<WeaponsViewModel>(
          create: (_) => WeaponsViewModel(),
          child: const MaterialApp(
            home: WeaponsScreen(),
          ),
        ),
      );

      // Verify filter button exists
      expect(find.byIcon(Icons.filter_alt), findsOneWidget);
    });
  });
}
