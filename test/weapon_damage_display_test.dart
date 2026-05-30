import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/weapon_model.dart';
import 'package:dnd_app/views/characters/WeaponsTab/weapon_attack_mapper.dart';

void main() {
  group('Weapon Damage Display Tests', () {
    late Weapon lightCrossbow;

    setUp(() {
      // Create Light Crossbow with d8 damage
      lightCrossbow = Weapon(
        id: 'light_crossbow',
        name: 'Light Crossbow',
        source: 'phb',
        isCore: true,
        cost: 25,
        costUnit: 'gold',
        weight: 5.0,
        type: 'crossbow_light',
        rarity: 'none',
        isFinesse: false,
        isThrown: false,
        isLight: false,
        damageDice: [
          DamageDice(diceAmount: 1, diceType: 'd8', damageType: 'piercing'),
        ],
      );
    });

    test('WeaponAttackMapper should return correct formatted damage', () {
      final formattedDamage = WeaponAttackMapper.getFormattedDamage(lightCrossbow);
      
      expect(formattedDamage, equals('1d8 piercing'));
      if (kDebugMode) {
        print('✅ WeaponAttackMapper formatted damage: $formattedDamage');
      }
    });

    test('Weapon should return correct formatted damage from model', () {
      final formattedDamage = lightCrossbow.formattedDamage;
      
      expect(formattedDamage, equals('1d8 piercing'));
      if (kDebugMode) {
        print('✅ Weapon model formatted damage: $formattedDamage');
      }
    });

    test('Weapon with multiple damage dice should work correctly', () {
      final weapon = Weapon(
        id: 'test',
        name: 'Test Weapon',
        source: 'test',
        isCore: false,
        cost: 0,
        costUnit: 'gold',
        weight: 1.0,
        type: 'test',
        rarity: 'none',
        isFinesse: false,
        isThrown: false,
        isLight: false,
        damageDice: [
          DamageDice(diceAmount: 1, diceType: 'd6', damageType: 'slashing'),
          DamageDice(diceAmount: 1, diceType: 'd4', damageType: 'fire'),
        ],
      );

      final formattedDamage = WeaponAttackMapper.getFormattedDamage(weapon);
      final modelFormattedDamage = weapon.formattedDamage;
      
      expect(formattedDamage, equals('1d6 slashing + 1d4 fire'));
      expect(modelFormattedDamage, equals('1d6 slashing, 1d4 fire'));
      if (kDebugMode) {
        print('✅ Multi-dice weapon: AttackMapper=$formattedDamage | Model=$modelFormattedDamage');
      }
    });

    test('Light Crossbow should show d8 not d6 in all contexts', () {
      // Test that all damage display methods show the correct d8 value
      final weaponModelDamage = lightCrossbow.formattedDamage;
      final mapperDamage = WeaponAttackMapper.getFormattedDamage(lightCrossbow);
      
      // All should show 1d8, not 1d6
      expect(weaponModelDamage, contains('1d8'));
      expect(mapperDamage, contains('1d8'));
      expect(weaponModelDamage, isNot(contains('1d6')));
      expect(mapperDamage, isNot(contains('1d6')));

      if (kDebugMode) {
        print('✅ Light Crossbow consistently shows 1d8 damage');
        print('   Weapon Model: $weaponModelDamage');
        print('   Attack Mapper: $mapperDamage');
      }
    });
  });
}
