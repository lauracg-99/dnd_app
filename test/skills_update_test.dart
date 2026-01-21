import 'package:flutter_test/flutter_test.dart';
import '../lib/models/character_model.dart';

void main() {
  group('Skill Modifier Calculation Tests', () {
    test('Should calculate correct skill modifier with updated ability scores', () {
      // Test case: Dexterity 15 should give +2 modifier, Dexterity 17 should give +3 modifier
      
      // Create character with DEX 15
      final stats15 = CharacterStats(
        strength: 10,
        dexterity: 15,
        constitution: 10,
        intelligence: 10,
        wisdom: 10,
        charisma: 10,
      );
      
      final skillChecks = CharacterSkillChecks();
      final proficiencyBonus = 2;
      
      // Calculate stealth modifier with DEX 15
      final stealthMod15 = skillChecks.calculateSkillModifier('stealth', stats15, proficiencyBonus);
      final expected15 = ((15 - 10) / 2).floor(); // +2
      expect(stealthMod15, equals(expected15));
      
      // Create character with DEX 17
      final stats17 = CharacterStats(
        strength: 10,
        dexterity: 17,
        constitution: 10,
        intelligence: 10,
        wisdom: 10,
        charisma: 10,
      );
      
      // Calculate stealth modifier with DEX 17
      final stealthMod17 = skillChecks.calculateSkillModifier('stealth', stats17, proficiencyBonus);
      final expected17 = ((17 - 10) / 2).floor(); // +3
      expect(stealthMod17, equals(expected17));
      
      // Verify the difference
      expect(stealthMod17 - stealthMod15, equals(1));
    });
    
    test('Should calculate correct skill modifier with proficiency', () {
      final stats = CharacterStats(
        strength: 10,
        dexterity: 15,
        constitution: 10,
        intelligence: 10,
        wisdom: 10,
        charisma: 10,
      );
      
      final skillChecks = CharacterSkillChecks(
        acrobaticsProficiency: true,
      );
      final proficiencyBonus = 2;
      
      // Calculate acrobatics modifier with DEX 15 and proficiency
      final acrobaticsMod = skillChecks.calculateSkillModifier('acrobatics', stats, proficiencyBonus);
      final expected = ((15 - 10) / 2).floor() + proficiencyBonus; // +2 (dex) + +2 (prof) = +4
      expect(acrobaticsMod, equals(4));
    });
    
    test('Should calculate correct skill modifier with expertise', () {
      final stats = CharacterStats(
        strength: 10,
        dexterity: 15,
        constitution: 10,
        intelligence: 10,
        wisdom: 10,
        charisma: 10,
      );
      
      final skillChecks = CharacterSkillChecks(
        stealthProficiency: true,
        stealthExpertise: true,
      );
      final proficiencyBonus = 2;
      
      // Calculate stealth modifier with DEX 15 and expertise
      final stealthMod = skillChecks.calculateSkillModifier('stealth', stats, proficiencyBonus);
      final expected = ((15 - 10) / 2).floor() + (proficiencyBonus * 2); // +2 (dex) + +4 (expertise) = +6
      expect(stealthMod, equals(6));
    });
  });
}
