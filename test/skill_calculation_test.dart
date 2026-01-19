import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Skill Calculation Tests', () {
    test('Should calculate skill bonus correctly without proficiency', () {
      const stats = CharacterStats(
        strength: 14, // +2 modifier
        dexterity: 16, // +3 modifier
        constitution: 12, // +1 modifier
        intelligence: 10, // +0 modifier
        wisdom: 18, // +4 modifier
        charisma: 8, // -1 modifier
      );

      const skillChecks = CharacterSkillChecks();
      const proficiencyBonus = 2;

      // Test acrobatics (DEX-based, no proficiency)
      final acrobaticsBonus = CharacterSkillChecks.calculateSkillBonus(
        stats.dexterity, 
        false, 
        false, 
        proficiencyBonus
      );
      expect(acrobaticsBonus, 3); // +3 from DEX, no proficiency

      // Test athletics (STR-based, no proficiency)
      final athleticsBonus = CharacterSkillChecks.calculateSkillBonus(
        stats.strength, 
        false, 
        false, 
        proficiencyBonus
      );
      expect(athleticsBonus, 2); // +2 from STR, no proficiency
    });

    test('Should calculate skill bonus correctly with proficiency', () {
      const stats = CharacterStats(
        strength: 14, // +2 modifier
        dexterity: 16, // +3 modifier
        constitution: 12, // +1 modifier
        intelligence: 10, // +0 modifier
        wisdom: 18, // +4 modifier
        charisma: 8, // -1 modifier
      );

      const skillChecks = CharacterSkillChecks(
        acrobaticsProficiency: true,
        athleticsProficiency: true,
      );
      const proficiencyBonus = 2;

      // Test acrobatics with proficiency
      final acrobaticsBonus = CharacterSkillChecks.calculateSkillBonus(
        stats.dexterity, 
        true, 
        false, 
        proficiencyBonus
      );
      expect(acrobaticsBonus, 5); // +3 from DEX + +2 proficiency

      // Test athletics with proficiency
      final athleticsBonus = CharacterSkillChecks.calculateSkillBonus(
        stats.strength, 
        true, 
        false, 
        proficiencyBonus
      );
      expect(athleticsBonus, 4); // +2 from STR + +2 proficiency
    });

    test('Should calculate skill bonus correctly with expertise', () {
      const stats = CharacterStats(
        strength: 14, // +2 modifier
        dexterity: 16, // +3 modifier
        constitution: 12, // +1 modifier
        intelligence: 10, // +0 modifier
        wisdom: 18, // +4 modifier
        charisma: 8, // -1 modifier
      );

      const skillChecks = CharacterSkillChecks(
        acrobaticsExpertise: true,
        athleticsExpertise: true,
      );
      const proficiencyBonus = 2;

      // Test acrobatics with expertise
      final acrobaticsBonus = CharacterSkillChecks.calculateSkillBonus(
        stats.dexterity, 
        true, 
        true, 
        proficiencyBonus
      );
      expect(acrobaticsBonus, 7); // +3 from DEX + +4 expertise (2x proficiency)

      // Test athletics with expertise
      final athleticsBonus = CharacterSkillChecks.calculateSkillBonus(
        stats.strength, 
        true, 
        true, 
        proficiencyBonus
      );
      expect(athleticsBonus, 6); // +2 from STR + +4 expertise (2x proficiency)
    });

    test('Should calculate skill modifiers for all skills', () {
      const stats = CharacterStats(
        strength: 16, // +3 modifier
        dexterity: 14, // +2 modifier
        constitution: 12, // +1 modifier
        intelligence: 18, // +4 modifier
        wisdom: 10, // +0 modifier
        charisma: 8, // -1 modifier
      );

      const skillChecks = CharacterSkillChecks(
        acrobaticsProficiency: true,
        arcanaProficiency: true,
        athleticsExpertise: true,
        perceptionProficiency: true,
        persuasionProficiency: true,
      );
      const proficiencyBonus = 3;

      // Test various skills with different abilities and proficiencies
      final acrobatics = skillChecks.calculateSkillModifier('acrobatics', stats, proficiencyBonus);
      expect(acrobatics, 5); // +2 DEX + +3 proficiency

      final arcana = skillChecks.calculateSkillModifier('arcana', stats, proficiencyBonus);
      expect(arcana, 7); // +4 INT + +3 proficiency

      final athletics = skillChecks.calculateSkillModifier('athletics', stats, proficiencyBonus);
      expect(athletics, 9); // +3 STR + +6 expertise (2x proficiency)

      final perception = skillChecks.calculateSkillModifier('perception', stats, proficiencyBonus);
      expect(perception, 3); // +0 WIS + +3 proficiency

      final persuasion = skillChecks.calculateSkillModifier('persuasion', stats, proficiencyBonus);
      expect(persuasion, 2); // -1 CHA + +3 proficiency
    });

    test('Should get correct ability score for each skill', () {
      const stats = CharacterStats(
        strength: 10,
        dexterity: 12,
        constitution: 14,
        intelligence: 16,
        wisdom: 18,
        charisma: 8,
      );

      // Test DEX-based skills
      expect(CharacterSkillChecks.getSkillAbilityScore('acrobatics', stats), 12);
      expect(CharacterSkillChecks.getSkillAbilityScore('sleight_of_hand', stats), 12);
      expect(CharacterSkillChecks.getSkillAbilityScore('stealth', stats), 12);

      // Test STR-based skills
      expect(CharacterSkillChecks.getSkillAbilityScore('athletics', stats), 10);

      // Test INT-based skills
      expect(CharacterSkillChecks.getSkillAbilityScore('arcana', stats), 16);
      expect(CharacterSkillChecks.getSkillAbilityScore('history', stats), 16);
      expect(CharacterSkillChecks.getSkillAbilityScore('investigation', stats), 16);
      expect(CharacterSkillChecks.getSkillAbilityScore('religion', stats), 16);

      // Test WIS-based skills
      expect(CharacterSkillChecks.getSkillAbilityScore('animal_handling', stats), 18);
      expect(CharacterSkillChecks.getSkillAbilityScore('insight', stats), 18);
      expect(CharacterSkillChecks.getSkillAbilityScore('medicine', stats), 18);
      expect(CharacterSkillChecks.getSkillAbilityScore('nature', stats), 18);
      expect(CharacterSkillChecks.getSkillAbilityScore('perception', stats), 18);
      expect(CharacterSkillChecks.getSkillAbilityScore('survival', stats), 18);

      // Test CHA-based skills
      expect(CharacterSkillChecks.getSkillAbilityScore('deception', stats), 8);
      expect(CharacterSkillChecks.getSkillAbilityScore('intimidation', stats), 8);
      expect(CharacterSkillChecks.getSkillAbilityScore('performance', stats), 8);
      expect(CharacterSkillChecks.getSkillAbilityScore('persuasion', stats), 8);
    });

    test('Should handle negative ability modifiers correctly', () {
      const stats = CharacterStats(
        strength: 8,  // -1 modifier
        dexterity: 6, // -2 modifier
        constitution: 4, // -3 modifier
        intelligence: 2, // -4 modifier
        wisdom: 1, // -4 modifier
        charisma: 1, // -4 modifier
      );

      const skillChecks = CharacterSkillChecks();
      const proficiencyBonus = 2;

      // Test with negative modifiers and proficiency
      final athleticsBonus = CharacterSkillChecks.calculateSkillBonus(
        stats.strength, 
        true, 
        false, 
        proficiencyBonus
      );
      expect(athleticsBonus, 1); // -1 from STR + +2 proficiency

      // Test with negative modifiers and expertise
      final acrobaticsBonus = CharacterSkillChecks.calculateSkillBonus(
        stats.dexterity, 
        true, 
        true, 
        proficiencyBonus
      );
      expect(acrobaticsBonus, 2); // -2 from DEX + +4 expertise (2x proficiency)
    });
  });
}
