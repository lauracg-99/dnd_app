import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Base64 Image Data Tests', () {
    test('Character model supports base64 image data', () {
      // Test that the model has the new fields
      final character = Character(
        id: 'test_char_123',
        name: 'Test Character',
        customImagePath: '/path/to/image.jpg',
        customImageData: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...',
        stats: const CharacterStats(
          strength: 10,
          dexterity: 10,
          constitution: 10,
          intelligence: 10,
          wisdom: 10,
          charisma: 10,
        ),
        savingThrows: const CharacterSavingThrows(),
        skillChecks: const CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 10),
        spellSlots: const CharacterSpellSlots(),
        characterClass: 'Fighter',
        level: 1,
        pillars: const CharacterPillars(),
        appearance: const CharacterAppearance(
          appearanceImagePath: '/path/to/appearance.jpg',
          appearanceImageData: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...',
        ),
        deathSaves: const CharacterDeathSaves(),
        languages: const CharacterLanguages(),
        moneyItems: const CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test that the model has the new fields
      expect(character.customImageData, isNotNull);
      expect(character.appearance.appearanceImageData, isNotNull);
      
      // Test JSON serialization includes image data
      final json = character.toJson();
      expect(json['stats']['custom_image_data']['value'], equals('data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...'));
      expect(json['stats']['appearance']['appearance_image_data']['value'], equals('data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...'));
      
      print('✅ Base64 image data successfully included in JSON');
      print('Profile image data: ${json['stats']['custom_image_data']}');
      print('Appearance image data: ${json['stats']['appearance']['appearance_image_data']}');
    });

    test('Base64 image data can be null', () {
      final characterWithoutImages = Character(
        id: 'test_char_456',
        name: 'Test Character 2',
        stats: const CharacterStats(
          strength: 10,
          dexterity: 10,
          constitution: 10,
          intelligence: 10,
          wisdom: 10,
          charisma: 10,
        ),
        savingThrows: const CharacterSavingThrows(),
        skillChecks: const CharacterSkillChecks(),
        health: const CharacterHealth(maxHitPoints: 10),
        spellSlots: const CharacterSpellSlots(),
        characterClass: 'Wizard',
        level: 1,
        pillars: const CharacterPillars(),
        appearance: const CharacterAppearance(),
        deathSaves: const CharacterDeathSaves(),
        languages: const CharacterLanguages(),
        moneyItems: const CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test JSON serialization without image data
      final json = characterWithoutImages.toJson();
      expect(json['stats'].containsKey('custom_image_data'), isFalse);
      expect(json['stats']['appearance'].containsKey('appearance_image_data'), isFalse);
      
      print('✅ JSON correctly excludes image data when null');
    });
  });
}
