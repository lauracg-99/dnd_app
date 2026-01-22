import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  group('Base64 Image Data Tests', () {
    test('Character model includes base64 image data in JSON', () {
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

      final json = character.toJson();
      
      // Check if image data is included in JSON
      expect(json['stats']['custom_image_data']['value'], equals('data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...'));
      expect(json['stats']['appearance']['appearance_image_data']['value'], equals('data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...'));
      
      print('JSON with base64 image data: ${json['stats']['custom_image_data']}');
      print('JSON with appearance image data: ${json['stats']['appearance']['appearance_image_data']}');
    });

    test('Character model loads base64 image data from JSON', () {
      final json = {
        'resource_id': 'character',
        'stats': {
          'id': {'value': 'test_char_123'},
          'name': {'value': 'Test Character'},
          'custom_image_path': {'value': '/path/to/image.jpg'},
          'custom_image_data': {'value': 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...'},
          'stats': {}, // Add missing stats field
          'saving_throws': {},
          'skill_checks': {},
          'health': {},
          'class': {'value': 'Fighter'},
          'level': {'value': 1},
          'spell_slots': {},
          'spells': {'value': []},
          'feats': {'value': []},
          'personalized_slots': {'value': []},
          'spell_preparation': {},
          'quick_guide': {'value': ''},
          'proficiencies': {'value': ''},
          'features_traits': {'value': ''},
          'backstory': {'value': ''},
          'pillars': {},
          'appearance': {
            'appearance_image_path': {'value': '/path/to/appearance.jpg'},
            'appearance_image_data': {'value': 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...'},
          },
          'death_saves': {},
          'languages': {},
          'money_items': {},
          'feat_notes': {'value': ''},
          'created_at': {'value': DateTime.now().toIso8601String()},
          'updated_at': {'value': DateTime.now().toIso8601String()},
        },
      };

      final character = Character.fromJson(json);
      
      expect(character.customImagePath, equals('/path/to/image.jpg'));
      expect(character.customImageData, equals('data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...'));
      expect(character.appearance.appearanceImagePath, equals('/path/to/appearance.jpg'));
      expect(character.appearance.appearanceImageData, equals('data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...'));
      
      print('Loaded customImagePath: ${character.customImagePath}');
      print('Loaded customImageData: ${character.customImageData?.substring(0, 50)}...');
      print('Loaded appearanceImagePath: ${character.appearance.appearanceImagePath}');
      print('Loaded appearanceImageData: ${character.appearance.appearanceImageData?.substring(0, 50)}...');
    });

    test('Character model handles null image data correctly', () {
      final character = Character(
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

      final json = character.toJson();
      
      // Check that null image data doesn't create JSON entries
      expect(json['stats'].containsKey('custom_image_data'), isFalse);
      expect(json['stats']['appearance'].containsKey('appearance_image_data'), isFalse);
      
      // Test loading null values
      final jsonWithNulls = {
        'resource_id': 'character',
        'stats': {
          'id': {'value': 'test_char_456'},
          'name': {'value': 'Test Character 2'},
          'custom_image_path': {'value': null},
          'custom_image_data': {'value': null},
          'stats': {}, // Add missing stats field
          'saving_throws': {},
          'skill_checks': {},
          'health': {},
          'class': {'value': 'Wizard'},
          'level': {'value': 1},
          'spell_slots': {},
          'spells': {'value': []},
          'feats': {'value': []},
          'personalized_slots': {'value': []},
          'spell_preparation': {},
          'quick_guide': {'value': ''},
          'proficiencies': {'value': ''},
          'features_traits': {'value': ''},
          'backstory': {'value': ''},
          'pillars': {},
          'appearance': {
            'appearance_image_path': {'value': ''},
            'appearance_image_data': {'value': null},
          },
          'death_saves': {},
          'languages': {},
          'money_items': {},
          'feat_notes': {'value': ''},
          'created_at': {'value': DateTime.now().toIso8601String()},
          'updated_at': {'value': DateTime.now().toIso8601String()},
        },
      };

      final loadedCharacter = Character.fromJson(jsonWithNulls);
      expect(loadedCharacter.customImagePath, isNull);
      expect(loadedCharacter.customImageData, isNull);
      expect(loadedCharacter.appearance.appearanceImagePath, equals(''));
      expect(loadedCharacter.appearance.appearanceImageData, isNull);
    });
  });
}
