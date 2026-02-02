import '../models/character_model.dart';

/// Helper class for spell-related calculations
/// 
/// Provides utilities for:
/// - Determining spellcasting ability by class
/// - Calculating spell save DC
/// - Calculating spell attack bonus
/// - Getting spellcasting modifier
class SpellCalculationHelper {
  /// Get the spellcasting ability for a given class
  /// 
  /// Returns the ability name (e.g., 'Intelligence', 'Wisdom', 'Charisma')
  /// or null if the class doesn't cast spells
  static String? getSpellcastingAbility(String characterClass) {
    final className = characterClass.trim().toLowerCase();

    switch (className) {
      case 'wizard':
      case 'artificer':
      case 'eldritch knight':
      case 'arcane trickster':
        return 'Intelligence';
      case 'cleric':
      case 'druid':
      case 'ranger':
      case 'monk':
        return 'Wisdom';
      case 'sorcerer':
      case 'bard':
      case 'warlock':
      case 'paladin':
        return 'Charisma';
      default:
        return null;
    }
  }

  /// Calculate spell save DC
  /// 
  /// Formula: 8 + proficiency bonus + spellcasting ability modifier
  static int calculateSpellSaveDC({
    required String characterClass,
    required int level,
    required int abilityModifier,
  }) {
    final spellcastingAbility = getSpellcastingAbility(characterClass);
    if (spellcastingAbility == null) return 0;

    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(level);
    return 8 + proficiencyBonus + abilityModifier;
  }

  /// Calculate spell attack bonus
  /// 
  /// Formula: proficiency bonus + spellcasting ability modifier
  static int calculateSpellAttackBonus({
    required String characterClass,
    required int level,
    required int abilityModifier,
  }) {
    final spellcastingAbility = getSpellcastingAbility(characterClass);
    if (spellcastingAbility == null) return 0;

    final proficiencyBonus = CharacterStats.calculateProficiencyBonus(level);
    return proficiencyBonus + abilityModifier;
  }

  /// Get the ability modifier for spellcasting based on character class
  static int getSpellcastingModifier({
    required String characterClass,
    required CharacterStats stats,
  }) {
    final ability = getSpellcastingAbility(characterClass);
    if (ability == null) return 0;

    switch (ability) {
      case 'Intelligence':
        return ((stats.intelligence - 10) / 2).floor();
      case 'Wisdom':
        return ((stats.wisdom - 10) / 2).floor();
      case 'Charisma':
        return ((stats.charisma - 10) / 2).floor();
      default:
        return 0;
    }
  }

  /// Get the name of the spellcasting modifier for display
  /// 
  /// Returns abbreviated form (e.g., 'INT', 'WIS', 'CHA')
  static String getModifierName(String characterClass) {
    final className = characterClass.trim().toLowerCase();

    switch (className) {
      case 'wizard':
      case 'artificer':
      case 'eldritch knight':
      case 'arcane trickster':
        return 'INT';
      case 'cleric':
      case 'druid':
      case 'ranger':
      case 'monk':
        return 'WIS';
      case 'sorcerer':
      case 'bard':
      case 'warlock':
      case 'paladin':
        return 'CHA';
      default:
        return 'N/A';
    }
  }

  /// Check if a class can cast spells
  static bool canCastSpells(String characterClass) {
    return getSpellcastingAbility(characterClass) != null;
  }

  /// Get spell slot information for a specific level
  static Map<String, int> getSpellSlotInfo(
    CharacterSpellSlots spellSlots,
    int level,
  ) {
    switch (level) {
      case 1:
        return {
          'total': spellSlots.level1Slots,
          'used': spellSlots.level1Used,
          'available': spellSlots.level1Slots - spellSlots.level1Used,
        };
      case 2:
        return {
          'total': spellSlots.level2Slots,
          'used': spellSlots.level2Used,
          'available': spellSlots.level2Slots - spellSlots.level2Used,
        };
      case 3:
        return {
          'total': spellSlots.level3Slots,
          'used': spellSlots.level3Used,
          'available': spellSlots.level3Slots - spellSlots.level3Used,
        };
      case 4:
        return {
          'total': spellSlots.level4Slots,
          'used': spellSlots.level4Used,
          'available': spellSlots.level4Slots - spellSlots.level4Used,
        };
      case 5:
        return {
          'total': spellSlots.level5Slots,
          'used': spellSlots.level5Used,
          'available': spellSlots.level5Slots - spellSlots.level5Used,
        };
      case 6:
        return {
          'total': spellSlots.level6Slots,
          'used': spellSlots.level6Used,
          'available': spellSlots.level6Slots - spellSlots.level6Used,
        };
      case 7:
        return {
          'total': spellSlots.level7Slots,
          'used': spellSlots.level7Used,
          'available': spellSlots.level7Slots - spellSlots.level7Used,
        };
      case 8:
        return {
          'total': spellSlots.level8Slots,
          'used': spellSlots.level8Used,
          'available': spellSlots.level8Slots - spellSlots.level8Used,
        };
      case 9:
        return {
          'total': spellSlots.level9Slots,
          'used': spellSlots.level9Used,
          'available': spellSlots.level9Slots - spellSlots.level9Used,
        };
      default:
        return {'total': 0, 'used': 0, 'available': 0};
    }
  }
}
