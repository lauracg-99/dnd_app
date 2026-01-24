import 'package:flutter/material.dart';

class CharacterAbilityHelper {
  /// Gets the ability score for a given ability abbreviation
  /// Returns the parsed value from the controller or 10 as default
  static int getAbilityScore(
    String ability, {
    required TextEditingController strengthController,
    required TextEditingController dexterityController,
    required TextEditingController constitutionController,
    required TextEditingController intelligenceController,
    required TextEditingController wisdomController,
    required TextEditingController charismaController,
  }) {
    switch (ability) {
      case 'STR':
        return int.tryParse(strengthController.text) ?? 10;
      case 'DEX':
        return int.tryParse(dexterityController.text) ?? 10;
      case 'CON':
        return int.tryParse(constitutionController.text) ?? 10;
      case 'INT':
        return int.tryParse(intelligenceController.text) ?? 10;
      case 'WIS':
        return int.tryParse(wisdomController.text) ?? 10;
      case 'CHA':
        return int.tryParse(charismaController.text) ?? 10;
      default:
        return 10;
    }
  }

  /// Calculates the ability modifier for a given ability score
  /// Returns the modifier as an integer (positive or negative)
  static int getAbilityModifier(int score) {
    return ((score - 10) / 2).floor();
  }

  /// Gets the ability modifier for a given ability abbreviation
  /// Combines getAbilityScore and getAbilityModifier for convenience
  static int getAbilityModifierFromControllers(
    String ability, {
    required TextEditingController strengthController,
    required TextEditingController dexterityController,
    required TextEditingController constitutionController,
    required TextEditingController intelligenceController,
    required TextEditingController wisdomController,
    required TextEditingController charismaController,
  }) {
    final score = getAbilityScore(
      ability,
      strengthController: strengthController,
      dexterityController: dexterityController,
      constitutionController: constitutionController,
      intelligenceController: intelligenceController,
      wisdomController: wisdomController,
      charismaController: charismaController,
    );
    return getAbilityModifier(score);
  }

  /// Formats a modifier as a string with + sign for positive values
  /// Example: 2 -> "+2", -1 -> "-1", 0 -> "+0"
  static String formatModifier(int modifier) {
    return modifier >= 0 ? '+$modifier' : '$modifier';
  }

  /// Gets the formatted modifier string for a given ability abbreviation
  /// Combines getAbilityModifierFromControllers and formatModifier
  static String getFormattedModifier(
    String ability, {
    required TextEditingController strengthController,
    required TextEditingController dexterityController,
    required TextEditingController constitutionController,
    required TextEditingController intelligenceController,
    required TextEditingController wisdomController,
    required TextEditingController charismaController,
  }) {
    final modifier = getAbilityModifierFromControllers(
      ability,
      strengthController: strengthController,
      dexterityController: dexterityController,
      constitutionController: constitutionController,
      intelligenceController: intelligenceController,
      wisdomController: wisdomController,
      charismaController: charismaController,
    );
    return formatModifier(modifier);
  }

  /// Gets the full ability name from abbreviation
  /// Example: 'STR' -> 'Strength', 'DEX' -> 'Dexterity'
  static String getAbilityName(String ability) {
    switch (ability) {
      case 'STR':
        return 'Strength';
      case 'DEX':
        return 'Dexterity';
      case 'CON':
        return 'Constitution';
      case 'INT':
        return 'Intelligence';
      case 'WIS':
        return 'Wisdom';
      case 'CHA':
        return 'Charisma';
      default:
        return ability;
    }
  }

  /// Gets the ability abbreviation from full name
  /// Example: 'Strength' -> 'STR', 'Dexterity' -> 'DEX'
  static String getAbilityAbbreviation(String abilityName) {
    switch (abilityName) {
      case 'Strength':
        return 'STR';
      case 'Dexterity':
        return 'DEX';
      case 'Intelligence':
        return 'INT';
      case 'Wisdom':
        return 'WIS';
      case 'Charisma':
        return 'CHA';
      default:
        return abilityName.substring(0, 3).toUpperCase();
    }
  }
}
