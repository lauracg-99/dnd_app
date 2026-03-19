import 'package:flutter_test/flutter_test.dart';
import '../lib/models/weapon_model.dart';

void main() {
  group('Weapon Model Formatted Type', () {
    test('should format crossbow_hand to Crossbow Hand', () {
      final weapon = Weapon(
        id: 'test1',
        name: 'Hand Crossbow',
        source: 'PHB',
        isCore: true,
        cost: 75,
        costUnit: 'gold',
        weight: 3.0,
        type: 'crossbow_hand',
        rarity: 'none',
        isFinesse: false,
        isThrown: false,
        isLight: false,
        damageDice: [DamageDice(diceAmount: 1, damageType: 'piercing')],
      );

      expect(weapon.formattedType, 'Crossbow Hand');
    });

    test('should format longsword to Longsword', () {
      final weapon = Weapon(
        id: 'test2',
        name: 'Longsword',
        source: 'PHB',
        isCore: true,
        cost: 15,
        costUnit: 'gold',
        weight: 3.0,
        type: 'longsword',
        rarity: 'none',
        isFinesse: false,
        isThrown: false,
        isLight: false,
        damageDice: [DamageDice(diceAmount: 1, damageType: 'slashing')],
      );

      expect(weapon.formattedType, 'Longsword');
    });

    test('should format battleaxe_two_handed to Battleaxe Two Handed', () {
      final weapon = Weapon(
        id: 'test3',
        name: 'Battleaxe',
        source: 'PHB',
        isCore: true,
        cost: 10,
        costUnit: 'gold',
        weight: 4.0,
        type: 'battleaxe_two_handed',
        rarity: 'none',
        isFinesse: false,
        isThrown: false,
        isLight: false,
        damageDice: [DamageDice(diceAmount: 1, damageType: 'slashing')],
      );

      expect(weapon.formattedType, 'Battleaxe Two Handed');
    });

    test('should handle empty type gracefully', () {
      final weapon = Weapon(
        id: 'test4',
        name: 'Unknown Weapon',
        source: 'PHB',
        isCore: true,
        cost: 0,
        costUnit: 'gold',
        weight: 0.0,
        type: '',
        rarity: 'none',
        isFinesse: false,
        isThrown: false,
        isLight: false,
        damageDice: [],
      );

      expect(weapon.formattedType, '');
    });

    test('should handle single word type', () {
      final weapon = Weapon(
        id: 'test5',
        name: 'Dagger',
        source: 'PHB',
        isCore: true,
        cost: 2,
        costUnit: 'gold',
        weight: 1.0,
        type: 'dagger',
        rarity: 'none',
        isFinesse: true,
        isThrown: true,
        isLight: true,
        damageDice: [DamageDice(diceAmount: 1, damageType: 'piercing')],
      );

      expect(weapon.formattedType, 'Dagger');
    });
  });
}
