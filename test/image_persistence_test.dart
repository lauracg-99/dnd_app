import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Image Persistence Tests', () {
    test('Character model should save and load customImagePath correctly', () {
      // Create a character with custom image path
      final character = Character(
        id: 'test-character-1',
        name: 'Test Character',
        customImagePath: '/path/to/profile/image.jpg',
        stats: const CharacterStats(
          strength: 10,
          dexterity: 12,
          constitution: 14,
          intelligence: 13,
          wisdom: 15,
          charisma: 11,
        ),
        savingThrows: const CharacterSavingThrows(),
        skillChecks: const CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 20),
        characterClass: 'Fighter',
        level: 1,
        spellSlots: const CharacterSpellSlots(),
        pillars: const CharacterPillars(
          gimmick: '',
          quirk: '',
          wants: '',
          needs: '',
          conflict: '',
        ),
        appearance: const CharacterAppearance(
          height: '5\'10"',
          age: '25',
          eyeColor: 'Blue',
          additionalDetails: '',
          appearanceImagePath: '/path/to/appearance/image.jpg',
        ),
        deathSaves: const CharacterDeathSaves(),
        languages: const CharacterLanguages(),
        moneyItems: const CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test that the customImagePath is set correctly
      expect(character.customImagePath, equals('/path/to/profile/image.jpg'));
      
      // Test that the appearance image path is set correctly
      expect(character.appearance.appearanceImagePath, equals('/path/to/appearance/image.jpg'));

      // Test JSON serialization
      final json = character.toJson();
      expect(json['stats']['custom_image_path']['value'], equals('/path/to/profile/image.jpg'));
      expect(json['stats']['appearance']['appearance_image_path']['value'], equals('/path/to/appearance/image.jpg'));

      // Test JSON deserialization
      final fromJson = Character.fromJson(json);
      expect(fromJson.customImagePath, equals('/path/to/profile/image.jpg'));
      expect(fromJson.appearance.appearanceImagePath, equals('/path/to/appearance/image.jpg'));
    });

    test('Character copyWith should update image paths correctly', () {
      final originalCharacter = Character(
        id: 'test-character-2',
        name: 'Test Character 2',
        stats: const CharacterStats(
          strength: 10,
          dexterity: 12,
          constitution: 14,
          intelligence: 13,
          wisdom: 15,
          charisma: 11,
        ),
        savingThrows: const CharacterSavingThrows(),
        skillChecks: const CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 20),
        characterClass: 'Wizard',
        level: 3,
        spellSlots: const CharacterSpellSlots(),
        pillars: const CharacterPillars(
          gimmick: '',
          quirk: '',
          wants: '',
          needs: '',
          conflict: '',
        ),
        appearance: const CharacterAppearance(),
        deathSaves: const CharacterDeathSaves(),
        languages: const CharacterLanguages(),
        moneyItems: const CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update image paths using copyWith
      final updatedCharacter = originalCharacter.copyWith(
        customImagePath: '/new/path/to/profile.jpg',
        appearance: originalCharacter.appearance.copyWith(
          appearanceImagePath: '/new/path/to/appearance.jpg',
        ),
      );

      // Verify the paths were updated
      expect(updatedCharacter.customImagePath, equals('/new/path/to/profile.jpg'));
      expect(updatedCharacter.appearance.appearanceImagePath, equals('/new/path/to/appearance.jpg'));
      
      // Verify other fields remained unchanged
      expect(updatedCharacter.id, equals(originalCharacter.id));
      expect(updatedCharacter.name, equals(originalCharacter.name));
      expect(updatedCharacter.characterClass, equals(originalCharacter.characterClass));
    });

    test('Character should handle null image paths correctly', () {
      final character = Character(
        id: 'test-character-3',
        name: 'Test Character 3',
        stats: const CharacterStats(
          strength: 10,
          dexterity: 12,
          constitution: 14,
          intelligence: 13,
          wisdom: 15,
          charisma: 11,
        ),
        savingThrows: const CharacterSavingThrows(),
        skillChecks: const CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 20),
        characterClass: 'Rogue',
        level: 2,
        spellSlots: const CharacterSpellSlots(),
        pillars: const CharacterPillars(
          gimmick: '',
          quirk: '',
          wants: '',
          needs: '',
          conflict: '',
        ),
        appearance: const CharacterAppearance(),
        deathSaves: const CharacterDeathSaves(),
        languages: const CharacterLanguages(),
        moneyItems: const CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test that null paths are handled correctly
      expect(character.customImagePath, isNull);
      expect(character.appearance.appearanceImagePath, equals('')); // Default empty string

      // Test JSON serialization with null customImagePath
      final json = character.toJson();
      expect(json['stats'].containsKey('custom_image_path'), isFalse);
      expect(json['stats']['appearance']['appearance_image_path']['value'], equals(''));

      // Test JSON deserialization
      final fromJson = Character.fromJson(json);
      expect(fromJson.customImagePath, isNull);
      expect(fromJson.appearance.appearanceImagePath, equals(''));
    });
  });
}
