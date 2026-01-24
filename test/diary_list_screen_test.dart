import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/diary_list_screen.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('DiaryListScreen Widget Tests', () {
    testWidgets('DiaryListScreen widget can be created with required parameters', (WidgetTester tester) async {
      // Create a test character
      final character = Character.withLevel(
        id: 'test-id',
        name: 'Test Character',
        characterClass: 'Fighter',
        level: 1,
        background: 'Soldier',
        race: 'Human',
        alignment: 'Lawful Good',
        experience: 0,
        proficiencyBonus: 2,
      );

      // Verify widget can be instantiated without throwing
      expect(
        () => DiaryListScreen(
          character: character,
        ),
        returnsNormally,
      );
    });
  });
}
