import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/weapon_model.dart';

void main() {
  group('Weapon Model Tests', () {
    test('Weapon should be created from JSON correctly', () {
      // Sample JSON based on the dagger example
      final json = {
        "resource_id": "weapon",
        "stats": {
          "name": {"value": "Dagger"},
          "source": {"value": "phb"},
          "is_core": {"value": true},
          "cost": {
            "value": {
              "resource_id": "cost",
              "stats": {
                "value": {"value": 2},
                "unit": {"value": "gold"},
                "id": "8c935501-2803-4dde-9042-a37514673479"
              }
            }
          },
          "weight": {
            "value": {
              "resource_id": "weight",
              "stats": {
                "value": {"value": 1},
                "id": "930acbd2-0f64-42cb-acdc-af388064574b"
              }
            }
          },
          "type": {"value": "dagger"},
          "rarity": {"value": "none"},
          "is_finesse": {"value": true},
          "is_thrown": {"value": true},
          "thrown_range": {"value": "20/60"},
          "is_light": {"value": true},
          "damage_dice": {
            "value": [
              {
                "resource_id": "damage_dice",
                "stats": {
                  "dices": {
                    "value": [
                      {
                        "resource_id": "dice_roll",
                        "stats": {
                          "dice_amount": {"value": 1},
                          "id": "ff1d7862-fde8-45cf-92ad-d80867bb2dec"
                        }
                      }
                    ]
                  },
                  "damage_type": {"value": "piercing"},
                  "id": "b1b63384-3a5f-4936-a0c6-8f318a85ebbb"
                }
              }
            ]
          },
          "id": "e89374ce-2494-4937-813e-4d829d8eaeee"
        }
      };

      final weapon = Weapon.fromJson(json);

      expect(weapon.name, equals('Dagger'));
      expect(weapon.source, equals('phb'));
      expect(weapon.isCore, isTrue);
      expect(weapon.cost, equals(2));
      expect(weapon.costUnit, equals('gold'));
      expect(weapon.weight, equals(1.0));
      expect(weapon.type, equals('dagger'));
      expect(weapon.rarity, equals('none'));
      expect(weapon.isFinesse, isTrue);
      expect(weapon.isThrown, isTrue);
      expect(weapon.thrownRange, equals('20/60'));
      expect(weapon.isLight, isTrue);
      expect(weapon.damageDice.length, equals(1));
      expect(weapon.damageDice.first.diceAmount, equals(1));
      expect(weapon.damageDice.first.damageType, equals('piercing'));
    });

    test('Weapon should handle missing data gracefully', () {
      final json = {
        "resource_id": "weapon",
        "stats": {
          "name": {"value": "Simple Weapon"},
          "source": {"value": "homebrew"},
        }
      };

      final weapon = Weapon.fromJson(json);

      expect(weapon.name, equals('Simple Weapon'));
      expect(weapon.source, equals('homebrew'));
      expect(weapon.isCore, isFalse);
      expect(weapon.cost, equals(0));
      expect(weapon.costUnit, equals('gold'));
      expect(weapon.weight, equals(0.0));
      expect(weapon.type, equals('unknown'));
      expect(weapon.rarity, equals('none'));
      expect(weapon.isFinesse, isFalse);
      expect(weapon.isThrown, isFalse);
      expect(weapon.thrownRange, isNull);
      expect(weapon.isLight, isFalse);
      expect(weapon.damageDice.isEmpty, isTrue);
    });

    test('formattedDamage should return correct string', () {
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
          DamageDice(diceAmount: 1, damageType: 'slashing'),
          DamageDice(diceAmount: 2, damageType: 'fire'),
        ],
      );

      expect(weapon.formattedDamage, equals('1d6 slashing, 2d6 fire'));
    });

    test('formattedDamage should return No damage for empty damage dice', () {
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
        damageDice: [],
      );

      expect(weapon.formattedDamage, equals('No damage'));
    });

    test('formattedProperties should return correct string', () {
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
        isFinesse: true,
        isThrown: true,
        thrownRange: '20/60',
        isLight: true,
        damageDice: [],
      );

      expect(weapon.formattedProperties, equals('Finesse, Light, Thrown, Range 20/60'));
    });

    test('formattedProperties should return No special properties for basic weapon', () {
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
        damageDice: [],
      );

      expect(weapon.formattedProperties, equals('No special properties'));
    });
  });

  group('DamageDice Model Tests', () {
    test('DamageDice should be created correctly', () {
      final damageDice = DamageDice(diceAmount: 2, damageType: 'piercing');

      expect(damageDice.diceAmount, equals(2));
      expect(damageDice.damageType, equals('piercing'));
    });
  });
}
