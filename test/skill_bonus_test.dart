import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Skill Bonus Tests', () {
    test('CharacterSkillChecks should initialize with default bonus values', () {
      final skillChecks = CharacterSkillChecks();
      
      expect(skillChecks.acrobaticsBonus, 0);
      expect(skillChecks.animalHandlingBonus, 0);
      expect(skillChecks.arcanaBonus, 0);
      expect(skillChecks.athleticsBonus, 0);
      expect(skillChecks.deceptionBonus, 0);
      expect(skillChecks.historyBonus, 0);
      expect(skillChecks.insightBonus, 0);
      expect(skillChecks.intimidationBonus, 0);
      expect(skillChecks.investigationBonus, 0);
      expect(skillChecks.medicineBonus, 0);
      expect(skillChecks.natureBonus, 0);
      expect(skillChecks.perceptionBonus, 0);
      expect(skillChecks.performanceBonus, 0);
      expect(skillChecks.persuasionBonus, 0);
      expect(skillChecks.religionBonus, 0);
      expect(skillChecks.sleightOfHandBonus, 0);
      expect(skillChecks.stealthBonus, 0);
      expect(skillChecks.survivalBonus, 0);
    });

    test('CharacterSkillChecks should initialize with custom bonus values', () {
      final skillChecks = CharacterSkillChecks(
        acrobaticsBonus: 2,
        animalHandlingBonus: 1,
        arcanaBonus: 3,
        athleticsBonus: 0,
        deceptionBonus: -1,
        historyBonus: 2,
        insightBonus: 1,
        intimidationBonus: 4,
        investigationBonus: 2,
        medicineBonus: 0,
        natureBonus: 1,
        perceptionBonus: 3,
        performanceBonus: 2,
        persuasionBonus: 1,
        religionBonus: 2,
        sleightOfHandBonus: 0,
        stealthBonus: 5,
        survivalBonus: 1,
      );
      
      expect(skillChecks.acrobaticsBonus, 2);
      expect(skillChecks.animalHandlingBonus, 1);
      expect(skillChecks.arcanaBonus, 3);
      expect(skillChecks.athleticsBonus, 0);
      expect(skillChecks.deceptionBonus, -1);
      expect(skillChecks.historyBonus, 2);
      expect(skillChecks.insightBonus, 1);
      expect(skillChecks.intimidationBonus, 4);
      expect(skillChecks.investigationBonus, 2);
      expect(skillChecks.medicineBonus, 0);
      expect(skillChecks.natureBonus, 1);
      expect(skillChecks.perceptionBonus, 3);
      expect(skillChecks.performanceBonus, 2);
      expect(skillChecks.persuasionBonus, 1);
      expect(skillChecks.religionBonus, 2);
      expect(skillChecks.sleightOfHandBonus, 0);
      expect(skillChecks.stealthBonus, 5);
      expect(skillChecks.survivalBonus, 1);
    });

    test('CharacterSkillChecks should serialize and deserialize bonus fields correctly', () {
      final originalSkillChecks = CharacterSkillChecks(
        acrobaticsBonus: 2,
        animalHandlingBonus: 1,
        arcanaBonus: 3,
        athleticsBonus: 0,
        deceptionBonus: -1,
        historyBonus: 2,
        insightBonus: 1,
        intimidationBonus: 4,
        investigationBonus: 2,
        medicineBonus: 0,
        natureBonus: 1,
        perceptionBonus: 3,
        performanceBonus: 2,
        persuasionBonus: 1,
        religionBonus: 2,
        sleightOfHandBonus: 0,
        stealthBonus: 5,
        survivalBonus: 1,
      );

      // Test serialization
      final json = originalSkillChecks.toJson();
      expect(json['acrobatics_bonus']['value'], 2);
      expect(json['animal_handling_bonus']['value'], 1);
      expect(json['arcana_bonus']['value'], 3);
      expect(json['athletics_bonus']['value'], 0);
      expect(json['deception_bonus']['value'], -1);
      expect(json['history_bonus']['value'], 2);
      expect(json['insight_bonus']['value'], 1);
      expect(json['intimidation_bonus']['value'], 4);
      expect(json['investigation_bonus']['value'], 2);
      expect(json['medicine_bonus']['value'], 0);
      expect(json['nature_bonus']['value'], 1);
      expect(json['perception_bonus']['value'], 3);
      expect(json['performance_bonus']['value'], 2);
      expect(json['persuasion_bonus']['value'], 1);
      expect(json['religion_bonus']['value'], 2);
      expect(json['sleight_of_hand_bonus']['value'], 0);
      expect(json['stealth_bonus']['value'], 5);
      expect(json['survival_bonus']['value'], 1);

      // Test deserialization
      final deserializedSkillChecks = CharacterSkillChecks.fromJson(json);
      expect(deserializedSkillChecks.acrobaticsBonus, 2);
      expect(deserializedSkillChecks.animalHandlingBonus, 1);
      expect(deserializedSkillChecks.arcanaBonus, 3);
      expect(deserializedSkillChecks.athleticsBonus, 0);
      expect(deserializedSkillChecks.deceptionBonus, -1);
      expect(deserializedSkillChecks.historyBonus, 2);
      expect(deserializedSkillChecks.insightBonus, 1);
      expect(deserializedSkillChecks.intimidationBonus, 4);
      expect(deserializedSkillChecks.investigationBonus, 2);
      expect(deserializedSkillChecks.medicineBonus, 0);
      expect(deserializedSkillChecks.natureBonus, 1);
      expect(deserializedSkillChecks.perceptionBonus, 3);
      expect(deserializedSkillChecks.performanceBonus, 2);
      expect(deserializedSkillChecks.persuasionBonus, 1);
      expect(deserializedSkillChecks.religionBonus, 2);
      expect(deserializedSkillChecks.sleightOfHandBonus, 0);
      expect(deserializedSkillChecks.stealthBonus, 5);
      expect(deserializedSkillChecks.survivalBonus, 1);
    });

    test('CharacterSkillChecks.calculateSkillBonus should include custom bonus', () {
      // Test with no proficiency or expertise, just custom bonus
      int result1 = CharacterSkillChecks.calculateSkillBonus(14, false, false, 2, 3);
      expect(result1, 5); // 2 (ability modifier) + 3 (custom bonus)

      // Test with proficiency and custom bonus
      int result2 = CharacterSkillChecks.calculateSkillBonus(14, true, false, 2, 3);
      expect(result2, 7); // 2 (ability modifier) + 2 (proficiency) + 3 (custom bonus)

      // Test with expertise and custom bonus
      int result3 = CharacterSkillChecks.calculateSkillBonus(14, false, true, 2, 3);
      expect(result3, 7); // 2 (ability modifier) + 4 (expertise) + 3 (custom bonus)

      // Test with proficiency, expertise, and custom bonus
      int result4 = CharacterSkillChecks.calculateSkillBonus(14, true, true, 2, 3);
      expect(result4, 9); // 2 (ability modifier) + 4 (expertise) + 3 (custom bonus)

      // Test with negative custom bonus
      int result5 = CharacterSkillChecks.calculateSkillBonus(14, true, false, 2, -1);
      expect(result5, 3); // 2 (ability modifier) + 2 (proficiency) - 1 (custom bonus)

      // Test with zero custom bonus (should work like original method)
      int result6 = CharacterSkillChecks.calculateSkillBonus(14, true, false, 2, 0);
      expect(result6, 4); // 2 (ability modifier) + 2 (proficiency) + 0 (custom bonus)
    });

    test('CharacterSkillChecks.calculateSkillBonus should handle edge cases', () {
      // Test with very high ability score
      int result1 = CharacterSkillChecks.calculateSkillBonus(20, true, false, 3, 5);
      expect(result1, 10); // 5 (ability modifier) + 3 (proficiency) + 5 (custom bonus)

      // Test with very low ability score
      int result2 = CharacterSkillChecks.calculateSkillBonus(1, false, false, 2, 2);
      expect(result2, -3); // -5 (ability modifier) + 2 (custom bonus)

      // Test with negative custom bonus that could make result negative
      int result3 = CharacterSkillChecks.calculateSkillBonus(8, false, false, 2, -3);
      expect(result3, -4); // -1 (ability modifier) - 3 (custom bonus)

      // Test with large custom bonus
      int result4 = CharacterSkillChecks.calculateSkillBonus(10, true, true, 4, 10);
      expect(result4, 18); // 0 (ability modifier) + 8 (expertise) + 10 (custom bonus)
    });

    test('CharacterSkillChecks.fromJson should handle missing bonus fields gracefully', () {
      final json = {
        'acrobatics_proficiency': {'value': true},
        'acrobatics_expertise': {'value': false},
        // Missing acrobatics_bonus
        'animal_handling_proficiency': {'value': false},
        'animal_handling_expertise': {'value': false},
        'animal_handling_bonus': {'value': 2},
        // Missing other fields
      };

      final skillChecks = CharacterSkillChecks.fromJson(json);
      
      expect(skillChecks.acrobaticsProficiency, true);
      expect(skillChecks.acrobaticsExpertise, false);
      expect(skillChecks.acrobaticsBonus, 0); // Should default to 0
      expect(skillChecks.animalHandlingProficiency, false);
      expect(skillChecks.animalHandlingExpertise, false);
      expect(skillChecks.animalHandlingBonus, 2); // Should use provided value
    });
  });
}
