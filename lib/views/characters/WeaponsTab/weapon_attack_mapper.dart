import '../../../models/weapon_model.dart';
import '../../../models/character_model.dart';
import '../../../helpers/character_ability_helper.dart';

class WeaponAttackMapper {
  /// Maps a Weapon to a CharacterAttack with calculated attack bonus and damage
  static CharacterAttack mapWeaponToAttack(
    Weapon weapon, 
    Character character, {
    String? customAttackBonus,
    String? customDamage,
  }) {
    // Calculate total attack bonus
    final attackBonus = _calculateTotalAttackBonus(weapon, character, customAttackBonus);
    
    // Use custom damage if provided, otherwise use weapon's base damage
    final damage = customDamage?.isNotEmpty == true 
        ? customDamage!
        : _getDamageDiceOnly(weapon);
    
    // Get damage type (use the first one if multiple)
    final damageType = weapon.damageDice.isNotEmpty 
        ? weapon.damageDice.first.damageType 
        : 'bludgeoning';
    
    return CharacterAttack(
      id: 'weapon_${weapon.id}_${DateTime.now().millisecondsSinceEpoch}',
      name: weapon.name,
      attackBonus: attackBonus,
      damage: damage,
      damageType: damageType,
    );
  }

  /// Calculates total attack bonus by combining weapon base bonus with user input
  static String _calculateTotalAttackBonus(Weapon weapon, Character character, String? customAttackBonus) {
    if (customAttackBonus?.isNotEmpty == true) {
      // User provided custom bonus, use it directly
      return customAttackBonus!;
    } else {
      // Use calculated weapon bonus
      return _calculateAttackBonus(weapon, character);
    }
  }

  /// Gets damage dice without the type (e.g., "1d6" instead of "1d6 slashing")
  static String _getDamageDiceOnly(Weapon weapon) {
    if (weapon.damageDice.isEmpty) return '';
    
    final buffer = StringBuffer();
    for (int i = 0; i < weapon.damageDice.length; i++) {
      if (i > 0) buffer.write(' + ');
      final dice = weapon.damageDice[i];
      buffer.write('${dice.diceAmount}d6');
    }
    return buffer.toString();
  }

  /// Calculates the attack bonus for a weapon based on character stats and weapon properties
  static String _calculateAttackBonus(Weapon weapon, Character character) {
    int bonus = 0;
    
    // Determine ability modifier based on weapon type
    if (weapon.isFinesse) {
      // Finesse weapons can use Strength or Dexterity
      final strengthMod = CharacterAbilityHelper.getAbilityModifier(character.stats.strength);
      final dexterityMod = CharacterAbilityHelper.getAbilityModifier(character.stats.dexterity);
      bonus = strengthMod >= dexterityMod ? strengthMod : dexterityMod;
    } else if (weapon.isThrown || weapon.type.contains('ranged')) {
      // Ranged and thrown weapons use Dexterity
      bonus = CharacterAbilityHelper.getAbilityModifier(character.stats.dexterity);
    } else {
      // Melee weapons use Strength
      bonus = CharacterAbilityHelper.getAbilityModifier(character.stats.strength);
    }
    
    // Add proficiency bonus
    bonus += character.stats.proficiencyBonus;
    
    // Format as +X or -X
    return bonus >= 0 ? '+$bonus' : '$bonus';
  }

  /// Gets a descriptive attack name including weapon properties
  static String getAttackName(Weapon weapon) {
    final parts = [weapon.name];
    
    if (weapon.isThrown) {
      parts.add('(Thrown)');
    }
    
    if (weapon.isFinesse) {
      parts.add('(Finesse)');
    }
    
    if (weapon.isLight) {
      parts.add('(Light)');
    }
    
    return parts.join(' ');
  }

  /// Gets formatted damage with type
  static String getFormattedDamage(Weapon weapon) {
    if (weapon.damageDice.isEmpty) return 'No damage';
    
    final buffer = StringBuffer();
    for (int i = 0; i < weapon.damageDice.length; i++) {
      if (i > 0) buffer.write(' + ');
      final dice = weapon.damageDice[i];
      buffer.write('${dice.diceAmount}d6 ${dice.damageType}');
    }
    return buffer.toString();
  }
}
