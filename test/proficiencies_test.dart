import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Proficiencies Tests', () {
    test('Character model should save and load proficiencies correctly', () {
      final now = DateTime.now();
      
      // Create a character with proficiencies
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
        proficiencies: 'Smith\'s tools, Herbalism kit, Shortbow',
        createdAt: now,
        updatedAt: now,
      );

      // Verify proficiencies is set correctly
      expect(character.proficiencies, equals('Smith\'s tools, Herbalism kit, Shortbow'));

      // Test JSON serialization
      final json = character.toJson();
      expect(json['stats']['proficiencies']['value'], equals('Smith\'s tools, Herbalism kit, Shortbow'));

      // Test JSON deserialization
      final loadedCharacter = Character.fromJson(json);
      expect(loadedCharacter.proficiencies, equals('Smith\'s tools, Herbalism kit, Shortbow'));
    });

    test('Character copyWith should update proficiencies correctly', () {
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
        proficiencies: 'Original proficiencies',
        createdAt: now,
        updatedAt: now,
      );

      // Update proficiencies using copyWith
      final updatedCharacter = originalCharacter.copyWith(
        proficiencies: 'Tinker\'s tools, Disguise kit, Light armor',
        updatedAt: DateTime.now(),
      );

      // Verify the proficiencies was updated
      expect(updatedCharacter.proficiencies, equals('Tinker\'s tools, Disguise kit, Light armor'));
      expect(updatedCharacter.name, equals(originalCharacter.name)); // Other fields unchanged
    });

    test('Character should handle empty proficiencies', () {
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

      // Verify default proficiencies is empty string
      expect(character.proficiencies, equals(''));

      // Test JSON serialization with empty proficiencies
      final json = character.toJson();
      expect(json['stats']['proficiencies']['value'], equals(''));

      // Test JSON deserialization with empty proficiencies
      final loadedCharacter = Character.fromJson(json);
      expect(loadedCharacter.proficiencies, equals(''));
    });

    test('Character should handle proficiencies with quick guide and backstory', () {
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
        quickGuide: 'Quick guide content',
        proficiencies: 'Tool proficiencies and languages',
        backstory: 'Character backstory',
        createdAt: now,
        updatedAt: now,
      );

      // Verify all text fields are set correctly
      expect(character.quickGuide, equals('Quick guide content'));
      expect(character.proficiencies, equals('Tool proficiencies and languages'));
      expect(character.backstory, equals('Character backstory'));

      // Test JSON serialization
      final json = character.toJson();
      expect(json['stats']['quick_guide']['value'], equals('Quick guide content'));
      expect(json['stats']['proficiencies']['value'], equals('Tool proficiencies and languages'));
      expect(json['stats']['backstory']['value'], equals('Character backstory'));

      // Test JSON deserialization
      final loadedCharacter = Character.fromJson(json);
      expect(loadedCharacter.quickGuide, equals('Quick guide content'));
      expect(loadedCharacter.proficiencies, equals('Tool proficiencies and languages'));
      expect(loadedCharacter.backstory, equals('Character backstory'));
    });
  });
}
