import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/character_edit_screen.dart';
import 'package:dnd_app/services/character_service.dart';

void main() {
  group('Character Edit Screen Tab Controller Initialization Test', () {
    testWidgets('Tab controller should be initialized without LateInitializationError', (WidgetTester tester) async {
      // Create a test character using CharacterService
      final testCharacter = await CharacterService.createCharacter(
        name: 'Test Character',
        characterClass: 'Fighter',
        subclass: 'Champion',
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: CharacterEditScreen(character: testCharacter),
        ),
      );

      // Wait for initialization to complete
      await tester.pumpAndSettle();

      // Verify the screen builds without errors
      expect(find.byType(CharacterEditScreen), findsOneWidget);
      
      // Verify tab bar is present
      expect(find.byType(TabBar), findsOneWidget);
      
      // Verify tab view is present
      expect(find.byType(TabBarView), findsOneWidget);
    });
  });
}
