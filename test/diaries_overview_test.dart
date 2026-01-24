import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/views/diaries/diaries_overview_screen.dart';
import '../lib/viewmodels/characters_viewmodel.dart';
import '../lib/models/character_model.dart';

void main() {
  group('DiariesOverviewScreen Tests', () {
    testWidgets('DiariesOverviewScreen should display title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<CharactersViewModel>(
          create: (_) => CharactersViewModel(),
          child: MaterialApp(
            home: DiariesOverviewScreen(),
          ),
        ),
      );

      // Verify the screen title
      expect(find.text('Character Diaries'), findsOneWidget);
    });

    testWidgets('DiariesOverviewScreen should show empty state when no characters', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<CharactersViewModel>(
          create: (_) => CharactersViewModel(),
          child: MaterialApp(
            home: DiariesOverviewScreen(),
          ),
        ),
      );

      // Verify empty state message
      expect(find.text('No characters found. Create your first character to start writing diaries!'), findsOneWidget);
      expect(find.text('Go to Characters'), findsOneWidget);
    });
  });
}
