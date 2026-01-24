import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/character_edit_screen.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Character Edit Screen Diaries Navigation', () {
    testWidgets('should show diaries navigation button with correct tooltip', (WidgetTester tester) async {
      // Create a minimal test character using default values where possible
      final testCharacter = Character(
        id: 'test-character-id',
        name: 'Test Character',
        level: 1,
        characterClass: 'Fighter',
        race: 'Human',
        stats: CharacterStats.withLevel(
          strength: 10,
          dexterity: 10,
          constitution: 10,
          intelligence: 10,
          wisdom: 10,
          charisma: 10,
          level: 1,
        ),
        savingThrows: const CharacterSavingThrows(),
        skillChecks: const CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 10),
        spellSlots: const CharacterSpellSlots(),
        pillars: const CharacterPillars(
          gimmick: '',
          quirk: '',
          wants: '',
          needs: '',
          conflict: '',
        ),
        appearance: const CharacterAppearance(
          height: '',
          age: '',
          eyeColor: '',
          additionalDetails: '',
        ),
        deathSaves: const CharacterDeathSaves(
          failures: [false, false, false],
          successes: [false, false, false],
        ),
        languages: const CharacterLanguages(
          languages: [],
        ),
        moneyItems: const CharacterMoneyItems(
          money: '',
          items: [],
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Build the character edit screen
      await tester.pumpWidget(
        MaterialApp(
          home: CharacterEditScreen(character: testCharacter),
        ),
      );

      // Find the diaries navigation button (book icon)
      final diariesButton = find.byIcon(Icons.book);
      expect(diariesButton, findsOneWidget);

      // Verify the tooltip
      expect(tester.widget<IconButton>(diariesButton).tooltip, "Character's Diary");

      // Verify the button is positioned before the reorder button
      final reorderButton = find.byIcon(Icons.reorder);
      expect(reorderButton, findsOneWidget);

      // Get the positions to verify diaries button is to the left of reorder button
      final diariesButtonRect = tester.getRect(diariesButton);
      final reorderButtonRect = tester.getRect(reorderButton);
      
      // Diaries button should be to the left (smaller x coordinate) of reorder button
      expect(diariesButtonRect.right, lessThanOrEqualTo(reorderButtonRect.left));
    });
  });
}
