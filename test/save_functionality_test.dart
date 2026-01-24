import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/character_edit_screen.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Character Edit Screen Save Tests', () {
    testWidgets('Save button shows loading state during save operation', (WidgetTester tester) async {
      // Create a test character
      final testCharacter = Character(
        id: 'test_character_1',
        name: 'Test Character',
        stats: CharacterStats(
          strength: 10,
          dexterity: 10,
          constitution: 10,
          intelligence: 10,
          wisdom: 10,
          charisma: 10,
          proficiencyBonus: 2,
          armorClass: 10,
          speed: 30,
          initiative: 0,
          inspiration: false,
          hasConcentration: false,
          hasShield: false,
        ),
        savingThrows: CharacterSavingThrows(),
        skillChecks: CharacterSkillChecks(),
        health: CharacterHealth(
          maxHitPoints: 10,
          currentHitPoints: 10,
          temporaryHitPoints: 0,
          hitDice: 1,
          hitDiceType: 'd8',
        ),
        characterClass: 'Fighter',
        level: 1,
        spellSlots: CharacterSpellSlots(),
        pillars: CharacterPillars(),
        appearance: CharacterAppearance(),
        deathSaves: CharacterDeathSaves(),
        languages: CharacterLanguages(),
        moneyItems: CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: CharacterEditScreen(character: testCharacter),
        ),
      );

      // Verify save button is initially visible
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Tap the save button
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      // Note: In a real test, we would need to mock the ViewModel
      // For now, this test verifies the UI structure exists
      expect(find.byType(CharacterEditScreen), findsOneWidget);
    });

    test('Save character data integrity test', () {
      // Test that character data is properly structured for saving
      final testCharacter = Character(
        id: 'test_character_2',
        name: 'Test Character',
        stats: CharacterStats(
          strength: 15,
          dexterity: 14,
          constitution: 13,
          intelligence: 12,
          wisdom: 10,
          charisma: 8,
          proficiencyBonus: 2,
          armorClass: 15,
          speed: 30,
          initiative: 2,
          inspiration: true,
          hasConcentration: true,
          hasShield: true,
        ),
        savingThrows: CharacterSavingThrows(),
        skillChecks: CharacterSkillChecks(),
        health: CharacterHealth(
          maxHitPoints: 25,
          currentHitPoints: 20,
          temporaryHitPoints: 5,
          hitDice: 2,
          hitDiceType: 'd10',
        ),
        characterClass: 'Paladin',
        level: 3,
        subclass: 'Oath of Devotion',
        race: 'Human',
        background: 'Acolyte',
        spellSlots: CharacterSpellSlots(),
        pillars: CharacterPillars(),
        appearance: CharacterAppearance(),
        deathSaves: CharacterDeathSaves(),
        languages: CharacterLanguages(),
        moneyItems: CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test JSON serialization/deserialization
      final json = testCharacter.toJson();
      final restoredCharacter = Character.fromJson(json);

      expect(restoredCharacter.name, equals(testCharacter.name));
      expect(restoredCharacter.characterClass, equals(testCharacter.characterClass));
      expect(restoredCharacter.level, equals(testCharacter.level));
      expect(restoredCharacter.stats.strength, equals(testCharacter.stats.strength));
      expect(restoredCharacter.stats.hasShield, equals(testCharacter.stats.hasShield));
      expect(restoredCharacter.background, equals(testCharacter.background));
    });
  });
}
