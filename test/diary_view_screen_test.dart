import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/views/characters/diary_view_screen.dart';
import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/models/diary_model.dart';

void main() {
  group('DiaryViewScreen Widget Tests', () {
    testWidgets('DiaryViewScreen widget can be created with required parameters', (WidgetTester tester) async {
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

      // Create a test diary entry
      final diaryEntry = DiaryEntry(
        id: 'test-diary-id',
        characterId: 'test-id',
        title: 'Test Entry',
        content: 'This is a test diary entry.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verify widget can be instantiated without throwing
      expect(
        () => DiaryViewScreen(
          character: character,
          diaryEntry: diaryEntry,
        ),
        returnsNormally,
      );
    });
  });
}
