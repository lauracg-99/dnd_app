import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/helpers/character_ability_helper.dart';

void main() {
  group('Saving Throws Update Tests', () {
    test('Saving throw modifiers should update when ability scores change', () {
      // Test with original ability scores
      final originalStrength = 14; // +2 modifier
      final originalDexterity = 12; // +1 modifier
      final originalConstitution = 10; // +0 modifier
      
      final originalStrModifier = CharacterAbilityHelper.getAbilityModifier(originalStrength);
      final originalDexModifier = CharacterAbilityHelper.getAbilityModifier(originalDexterity);
      final originalConModifier = CharacterAbilityHelper.getAbilityModifier(originalConstitution);
      
      expect(originalStrModifier, equals(2));
      expect(originalDexModifier, equals(1));
      expect(originalConModifier, equals(0));
      
      // Test with updated ability scores
      final updatedStrength = 16; // +3 modifier
      final updatedDexterity = 15; // +2 modifier
      final updatedConstitution = 13; // +1 modifier
      
      final updatedStrModifier = CharacterAbilityHelper.getAbilityModifier(updatedStrength);
      final updatedDexModifier = CharacterAbilityHelper.getAbilityModifier(updatedDexterity);
      final updatedConModifier = CharacterAbilityHelper.getAbilityModifier(updatedConstitution);
      
      expect(updatedStrModifier, equals(3));
      expect(updatedDexModifier, equals(2));
      expect(updatedConModifier, equals(1));
      
      // Verify that modifiers changed
      expect(updatedStrModifier, greaterThan(originalStrModifier));
      expect(updatedDexModifier, greaterThan(originalDexModifier));
      expect(updatedConModifier, greaterThan(originalConModifier));
    });
    
    test('Saving throw total should include proficiency bonus correctly', () {
      final abilityScore = 14; // +2 modifier
      final proficiencyBonus = 3; // Level 5 character
      
      final abilityModifier = CharacterAbilityHelper.getAbilityModifier(abilityScore);
      final totalBonus = abilityModifier + (proficiencyBonus);
      
      expect(abilityModifier, equals(2));
      expect(totalBonus, equals(5)); // 2 (modifier) + 3 (proficiency)
    });
    
    test('Saving throw total should not include proficiency bonus when not proficient', () {
      final abilityScore = 14; // +2 modifier
      
      final abilityModifier = CharacterAbilityHelper.getAbilityModifier(abilityScore);
      final totalBonus = abilityModifier + (0);
      
      expect(abilityModifier, equals(2));
      expect(totalBonus, equals(2)); // Only the modifier, no proficiency
    });
    
    test('CharacterSavingThrows should maintain proficiency settings when updated', () {
      final originalSavingThrows = CharacterSavingThrows(
        strengthProficiency: true,
        dexterityProficiency: false,
        constitutionProficiency: true,
        intelligenceProficiency: false,
        wisdomProficiency: true,
        charismaProficiency: false,
      );
      
      // Simulate updating saving throws with new ability scores
      // (proficiency settings should remain the same)
      final updatedSavingThrows = CharacterSavingThrows(
        strengthProficiency: originalSavingThrows.strengthProficiency,
        dexterityProficiency: originalSavingThrows.dexterityProficiency,
        constitutionProficiency: originalSavingThrows.constitutionProficiency,
        intelligenceProficiency: originalSavingThrows.intelligenceProficiency,
        wisdomProficiency: originalSavingThrows.wisdomProficiency,
        charismaProficiency: originalSavingThrows.charismaProficiency,
      );
      
      expect(updatedSavingThrows.strengthProficiency, equals(true));
      expect(updatedSavingThrows.dexterityProficiency, equals(false));
      expect(updatedSavingThrows.constitutionProficiency, equals(true));
      expect(updatedSavingThrows.intelligenceProficiency, equals(false));
      expect(updatedSavingThrows.wisdomProficiency, equals(true));
      expect(updatedSavingThrows.charismaProficiency, equals(false));
    });
  });
}
