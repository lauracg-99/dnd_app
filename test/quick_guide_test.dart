import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Quick Guide Tests', () {
    test('Character model should save and load quick guide correctly', () {
      final now = DateTime.now();
      
      // Create a character with quick guide
      final character = Character(
        id: 'test-id',
        name: 'Test Character',
        stats: CharacterStats.withLevel(
          strength: 10,
          dexterity: 12,
          constitution: 14,
          intelligence: 8,
          wisdom: 13,
          charisma: 11,
          level: 1,
        ),
        savingThrows: CharacterSavingThrows(),
        skillChecks: CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 10),
        characterClass: 'Fighter',
        level: 1,
        spellSlots: const CharacterSpellSlots(),
        pillars: const CharacterPillars(),
        appearance: const CharacterAppearance(),
        deathSaves: const CharacterDeathSaves(),
        languages: const CharacterLanguages(),
        moneyItems: const CharacterMoneyItems(),
        quickGuide: 'This is a test quick guide with character information.',
        createdAt: now,
        updatedAt: now,
      );

      // Verify quick guide is set correctly
      expect(character.quickGuide, equals('This is a test quick guide with character information.'));

      // Test JSON serialization
      final json = character.toJson();
      expect(json['stats']['quick_guide']['value'], equals('This is a test quick guide with character information.'));

      // Test JSON deserialization
      final loadedCharacter = Character.fromJson(json);
      expect(loadedCharacter.quickGuide, equals('This is a test quick guide with character information.'));
    });

    test('Character copyWith should update quick guide correctly', () {
      final now = DateTime.now();
      
      final originalCharacter = Character(
        id: 'test-id',
        name: 'Test Character',
        stats: CharacterStats.withLevel(
          strength: 10,
          dexterity: 12,
          constitution: 14,
          intelligence: 8,
          wisdom: 13,
          charisma: 11,
          level: 1,
        ),
        savingThrows: CharacterSavingThrows(),
        skillChecks: CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 10),
        characterClass: 'Fighter',
        level: 1,
        spellSlots: const CharacterSpellSlots(),
        pillars: const CharacterPillars(),
        appearance: const CharacterAppearance(),
        deathSaves: const CharacterDeathSaves(),
        languages: const CharacterLanguages(),
        moneyItems: const CharacterMoneyItems(),
        quickGuide: 'Original quick guide',
        createdAt: now,
        updatedAt: now,
      );

      // Update quick guide using copyWith
      final updatedCharacter = originalCharacter.copyWith(
        quickGuide: 'Updated quick guide with new information',
        updatedAt: DateTime.now(),
      );

      // Verify the quick guide was updated
      expect(updatedCharacter.quickGuide, equals('Updated quick guide with new information'));
      expect(updatedCharacter.name, equals(originalCharacter.name)); // Other fields unchanged
    });

    test('Character should handle empty quick guide', () {
      final now = DateTime.now();
      
      final character = Character(
        id: 'test-id',
        name: 'Test Character',
        stats: CharacterStats.withLevel(
          strength: 10,
          dexterity: 12,
          constitution: 14,
          intelligence: 8,
          wisdom: 13,
          charisma: 11,
          level: 1,
        ),
        savingThrows: CharacterSavingThrows(),
        skillChecks: CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 10),
        characterClass: 'Fighter',
        level: 1,
        spellSlots: const CharacterSpellSlots(),
        pillars: const CharacterPillars(),
        appearance: const CharacterAppearance(),
        deathSaves: const CharacterDeathSaves(),
        languages: const CharacterLanguages(),
        moneyItems: const CharacterMoneyItems(),
        createdAt: now,
        updatedAt: now,
      );

      // Verify default quick guide is empty string
      expect(character.quickGuide, equals(''));

      // Test JSON serialization with empty quick guide
      final json = character.toJson();
      expect(json['stats']['quick_guide']['value'], equals(''));

      // Test JSON deserialization with empty quick guide
      final loadedCharacter = Character.fromJson(json);
      expect(loadedCharacter.quickGuide, equals(''));
    });
  });
}
