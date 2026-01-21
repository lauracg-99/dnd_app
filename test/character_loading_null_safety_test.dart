import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import '../lib/models/character_model.dart';

void main() {
  group('Character Loading Null Safety Tests', () {
    test('Should handle CharacterAttack with null id gracefully', () {
      // Test corrupted attack data with null id
      final corruptedAttackJson = {
        'id': null, // This should not crash
        'name': {'value': 'Test Attack'},
        'attack_bonus': {'value': '+5'},
        'damage': {'value': '1d8'},
        'damage_type': {'value': 'slashing'},
        'description': {'value': 'Test description'},
      };

      // Should not throw an exception
      expect(
        () => CharacterAttack.fromJson(corruptedAttackJson),
        returnsNormally,
      );

      final attack = CharacterAttack.fromJson(corruptedAttackJson);
      expect(attack.id, equals('')); // Should use default value
      expect(attack.name, equals('Test Attack'));
    });

    test('Should handle CharacterAttack with missing fields gracefully', () {
      // Test attack data with missing required fields
      final incompleteAttackJson = {
        'name': {'value': 'Incomplete Attack'},
        // Missing id, attack_bonus, damage, damage_type
      };

      // Should not throw an exception
      expect(
        () => CharacterAttack.fromJson(incompleteAttackJson),
        returnsNormally,
      );

      final attack = CharacterAttack.fromJson(incompleteAttackJson);
      expect(attack.id, equals('')); // Default value
      expect(attack.name, equals('Incomplete Attack'));
      expect(attack.attackBonus, equals('')); // Default from _getValue
      expect(attack.damage, equals('')); // Default from _getValue
      expect(attack.damageType, equals('')); // Default from _getValue
    });

    test('Should handle Character with null attack data gracefully', () {
      // Test character with corrupted attacks array
      final corruptedCharacterJson = {
        'resource_id': 'character',
        'stats': {
          'id': {'value': 'test-character'},
          'name': {'value': 'Test Character'},
          'level': {'value': 1},
          'class': {'value': 'Fighter'},
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
            'animal_handling_proficiency': {'value': false},
            'animal_handling_expertise': {'value': false},
            'arcana_proficiency': {'value': false},
            'arcana_expertise': {'value': false},
          },
          'health': {
            'max_hit_points': {'value': 10},
            'current_hit_points': {'value': 10},
            'temporary_hit_points': {'value': 0},
            'hit_dice': {'value': 1},
            'hit_dice_type': {'value': 'd8'},
          },
          'attacks': [
            null, // Null attack
            {'invalid': 'data'}, // Invalid attack format
            {
              'id': null, // Null id
              'name': {'value': 'Valid Attack'},
              'attack_bonus': {'value': '+5'},
              'damage': {'value': '1d8'},
              'damage_type': {'value': 'slashing'},
            },
          ],
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
          'spell_preparation': {},
          'quick_guide': {'value': ''},
          'backstory': {'value': ''},
          'pillars': {
            'gimmick': {'value': ''},
            'quirk': {'value': ''},
            'wants': {'value': ''},
            'needs': {'value': ''},
            'conflict': {'value': ''},
          },
          'appearance': {},
          'death_saves': {
            'successes': [false, false, false],
            'failures': [false, false, false],
          },
          'languages': {'value': ''},
          'money_items': {
            'money': '',
            'items': [],
          },
          'feat_notes': {'value': ''},
          'created_at': {'value': '2024-01-01T00:00:00.000Z'},
          'updated_at': {'value': '2024-01-01T00:00:00.000Z'},
        },
      };

      try {
        final character = Character.fromJson(corruptedCharacterJson);
        expect(character.name, equals('Test Character'));
        expect(character.attacks.length, equals(2)); // Both invalid and valid attacks are loaded
        expect(character.attacks.last.name, equals('Valid Attack')); // Valid attack should be last
      } catch (e) {
        print('Error loading character: $e');
        print('Error type: ${e.runtimeType}');
        print('Stack trace: ${StackTrace.current}');
        rethrow;
      }
    });

    test('Should handle CharacterPersonalizedSlot with null data gracefully', () {
      // Test corrupted personalized slot data
      final corruptedSlotJson = {
        'name': null, // Null name
        'max_slots': {'value': 3},
        'used_slots': {'value': 1},
        'dice_type': {'value': 'd6'},
      };

      // Should not throw an exception
      expect(
        () => CharacterPersonalizedSlot.fromJson(corruptedSlotJson),
        returnsNormally,
      );

      final slot = CharacterPersonalizedSlot.fromJson(corruptedSlotJson);
      expect(slot.name, equals('Slot')); // Default value
      expect(slot.maxSlots, equals(3));
      expect(slot.usedSlots, equals(1));
      expect(slot.diceType, equals('d6'));
    });
  });
}
