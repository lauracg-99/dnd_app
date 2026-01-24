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
          'stats': {
            'strength': {'value': 10},
            'dexterity': {'value': 10},
            'constitution': {'value': 10},
            'intelligence': {'value': 10},
            'wisdom': {'value': 10},
            'charisma': {'value': 10},
            'proficiency_bonus': {'value': 2},
            'armor_class': {'value': 10},
            'speed': {'value': 30},
            'initiative': {'value': 0},
            'inspiration': {'value': false},
            'has_concentration': {'value': false},
            'has_shield': {'value': false},
          },
          'saving_throws': {
            'strength_proficiency': {'value': false},
            'dexterity_proficiency': {'value': false},
            'constitution_proficiency': {'value': false},
            'intelligence_proficiency': {'value': false},
            'wisdom_proficiency': {'value': false},
            'charisma_proficiency': {'value': false},
          },
          'skill_checks': {
            'acrobatics_proficiency': {'value': false},
            'acrobatics_expertise': {'value': false},
            'animal_handling_proficiency': {'value': false},
            'animal_handling_expertise': {'value': false},
            'arcana_proficiency': {'value': false},
            'arcana_expertise': {'value': false},
            'athletics_proficiency': {'value': false},
            'athletics_expertise': {'value': false},
            'deception_proficiency': {'value': false},
            'deception_expertise': {'value': false},
            'history_proficiency': {'value': false},
            'history_expertise': {'value': false},
            'insight_proficiency': {'value': false},
            'insight_expertise': {'value': false},
            'intimidation_proficiency': {'value': false},
            'intimidation_expertise': {'value': false},
            'investigation_proficiency': {'value': false},
            'investigation_expertise': {'value': false},
            'medicine_proficiency': {'value': false},
            'medicine_expertise': {'value': false},
            'nature_proficiency': {'value': false},
            'nature_expertise': {'value': false},
            'perception_proficiency': {'value': false},
            'perception_expertise': {'value': false},
            'performance_proficiency': {'value': false},
            'performance_expertise': {'value': false},
            'persuasion_proficiency': {'value': false},
            'persuasion_expertise': {'value': false},
            'religion_proficiency': {'value': false},
            'religion_expertise': {'value': false},
            'sleight_of_hand_proficiency': {'value': false},
            'sleight_of_hand_expertise': {'value': false},
            'stealth_proficiency': {'value': false},
            'stealth_expertise': {'value': false},
            'survival_proficiency': {'value': false},
            'survival_expertise': {'value': false},
          },
          'health': {
            'max_hit_points': {'value': 10},
            'current_hit_points': {'value': 10},
            'temporary_hit_points': {'value': 0},
            'hit_dice': {'value': 1},
            'hit_dice_type': {'value': 'd8'},
          },
          'class': {'value': 'Fighter'},
          'level': {'value': 1},
          'spell_slots': {
            'level1_slots': {'value': 0},
            'level1_used': {'value': 0},
            'level2_slots': {'value': 0},
            'level2_used': {'value': 0},
            'level3_slots': {'value': 0},
            'level3_used': {'value': 0},
            'level4_slots': {'value': 0},
            'level4_used': {'value': 0},
            'level5_slots': {'value': 0},
            'level5_used': {'value': 0},
            'level6_slots': {'value': 0},
            'level6_used': {'value': 0},
            'level7_slots': {'value': 0},
            'level7_used': {'value': 0},
            'level8_slots': {'value': 0},
            'level8_used': {'value': 0},
            'level9_slots': {'value': 0},
            'level9_used': {'value': 0},
          },
          'spells': {'value': []},
          'feats': {'value': []},
          'personalized_slots': {'value': []},
          'spell_preparation': {
            'prepared_spells': {'value': []},
            'always_prepared_spells': {'value': []},
            'free_use_spells': {'value': []},
            'max_prepared_spells': {'value': 0},
            'enable_preparation': {'value': true},
          },
          'quick_guide': {'value': ''},
          'proficiencies': {'value': ''},
          'features_traits': {'value': ''},
          'backstory': {'value': ''},
          'pillars': {
            'gimmick': {'value': ''},
            'quirk': {'value': ''},
            'wants': {'value': ''},
            'needs': {'value': ''},
            'conflict': {'value': ''},
          },
          'appearance': {
            'appearance_image_path': {'value': '/path/to/appearance.jpg'},
            'appearance_image_data': {'value': 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYGBgYJCQg...'},
          },
          'death_saves': {
            'successes': [false, false, false],
            'failures': [false, false, false],
          },
          'languages': {
            'languages': [],
          },
          'money_items': {
            'money': '',
            'items': [''],
          },
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
          'stats': {
            'strength': {'value': 10},
            'dexterity': {'value': 10},
            'constitution': {'value': 10},
            'intelligence': {'value': 10},
            'wisdom': {'value': 10},
            'charisma': {'value': 10},
            'proficiency_bonus': {'value': 2},
            'armor_class': {'value': 10},
            'speed': {'value': 30},
            'initiative': {'value': 0},
            'inspiration': {'value': false},
            'has_concentration': {'value': false},
            'has_shield': {'value': false},
          },
          'saving_throws': {
            'strength_proficiency': {'value': false},
            'dexterity_proficiency': {'value': false},
            'constitution_proficiency': {'value': false},
            'intelligence_proficiency': {'value': false},
            'wisdom_proficiency': {'value': false},
            'charisma_proficiency': {'value': false},
          },
          'skill_checks': {
            'acrobatics_proficiency': {'value': false},
            'acrobatics_expertise': {'value': false},
            'animal_handling_proficiency': {'value': false},
            'animal_handling_expertise': {'value': false},
            'arcana_proficiency': {'value': false},
            'arcana_expertise': {'value': false},
            'athletics_proficiency': {'value': false},
            'athletics_expertise': {'value': false},
            'deception_proficiency': {'value': false},
            'deception_expertise': {'value': false},
            'history_proficiency': {'value': false},
            'history_expertise': {'value': false},
            'insight_proficiency': {'value': false},
            'insight_expertise': {'value': false},
            'intimidation_proficiency': {'value': false},
            'intimidation_expertise': {'value': false},
            'investigation_proficiency': {'value': false},
            'investigation_expertise': {'value': false},
            'medicine_proficiency': {'value': false},
            'medicine_expertise': {'value': false},
            'nature_proficiency': {'value': false},
            'nature_expertise': {'value': false},
            'perception_proficiency': {'value': false},
            'perception_expertise': {'value': false},
            'performance_proficiency': {'value': false},
            'performance_expertise': {'value': false},
            'persuasion_proficiency': {'value': false},
            'persuasion_expertise': {'value': false},
            'religion_proficiency': {'value': false},
            'religion_expertise': {'value': false},
            'sleight_of_hand_proficiency': {'value': false},
            'sleight_of_hand_expertise': {'value': false},
            'stealth_proficiency': {'value': false},
            'stealth_expertise': {'value': false},
            'survival_proficiency': {'value': false},
            'survival_expertise': {'value': false},
          },
          'health': {
            'max_hit_points': {'value': 10},
            'current_hit_points': {'value': 10},
            'temporary_hit_points': {'value': 0},
            'hit_dice': {'value': 1},
            'hit_dice_type': {'value': 'd8'},
          },
          'class': {'value': 'Wizard'},
          'level': {'value': 1},
          'spell_slots': {
            'level1_slots': {'value': 0},
            'level1_used': {'value': 0},
            'level2_slots': {'value': 0},
            'level2_used': {'value': 0},
            'level3_slots': {'value': 0},
            'level3_used': {'value': 0},
            'level4_slots': {'value': 0},
            'level4_used': {'value': 0},
            'level5_slots': {'value': 0},
            'level5_used': {'value': 0},
            'level6_slots': {'value': 0},
            'level6_used': {'value': 0},
            'level7_slots': {'value': 0},
            'level7_used': {'value': 0},
            'level8_slots': {'value': 0},
            'level8_used': {'value': 0},
            'level9_slots': {'value': 0},
            'level9_used': {'value': 0},
          },
          'spells': {'value': []},
          'feats': {'value': []},
          'personalized_slots': {'value': []},
          'spell_preparation': {
            'prepared_spells': {'value': []},
            'always_prepared_spells': {'value': []},
            'free_use_spells': {'value': []},
            'max_prepared_spells': {'value': 0},
            'enable_preparation': {'value': true},
          },
          'quick_guide': {'value': ''},
          'proficiencies': {'value': ''},
          'features_traits': {'value': ''},
          'backstory': {'value': ''},
          'pillars': {
            'gimmick': {'value': ''},
            'quirk': {'value': ''},
            'wants': {'value': ''},
            'needs': {'value': ''},
            'conflict': {'value': ''},
          },
          'appearance': {
            'appearance_image_path': {'value': ''},
            'appearance_image_data': {'value': null},
          },
          'death_saves': {
            'successes': [false, false, false],
            'failures': [false, false, false],
          },
          'languages': {
            'languages': [],
          },
          'money_items': {
            'money': '',
            'items': [''],
          },
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
