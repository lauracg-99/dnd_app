import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/weapon_model.dart';

void main() {
  group('Light Crossbow Damage Tests', () {
    test('Light Crossbow should display 1d8 piercing damage', () {
      // JSON from the actual Light Crossbow weapon file
      final json = {
        "resource_id": "weapon",
        "stats": {
          "name": {"value": "Light Crossbow"},
          "source": {"value": "phb"},
          "is_core": {"value": true},
          "cost": {
            "value": {
              "resource_id": "cost",
              "stats": {
                "value": {"value": 25},
                "unit": {"value": "gold"},
                "id": "67c23587-605f-4685-b1d5-bdb26f4f57af"
              }
            }
          },
          "weight": {
            "value": {
              "resource_id": "weight",
              "stats": {
                "value": {"value": 5},
                "id": "c0896212-eed6-451e-8565-de9a15067448"
              }
            }
          },
          "type": {"value": "crossbow_light"},
          "attack_ability": {"value": "dexterity"},
          "rarity": {"value": "none"},
          "is_two_handed": {"value": true},
          "is_loading": {"value": true},
          "is_range": {"value": true},
          "ammunition_type": {"value": "bolt"},
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
                          "dice_type": {"value": "d8"},
                          "id": "e5d0f7ca-5b3d-43e7-b961-35f58f54b2c4"
                        }
                      }
                    ]
                  },
                  "damage_type": {"value": "piercing"},
                  "id": "271fa789-0600-4a92-bdea-6aa1c1b28c90"
                }
              }
            ]
          },
          "id": "fa5db9bd-dc77-4745-8c30-91a4deedcbc1"
        }
      };

      final weapon = Weapon.fromJson(json);

      // Verify basic weapon properties
      expect(weapon.name, equals('Light Crossbow'));
      expect(weapon.type, equals('crossbow_light'));
      expect(weapon.damageDice.length, equals(1));
      
      // Verify damage dice properties
      final damageDice = weapon.damageDice.first;
      expect(damageDice.diceAmount, equals(1));
      expect(damageDice.diceType, equals('d8'));
      expect(damageDice.damageType, equals('piercing'));
      
      // Verify formatted damage output
      expect(weapon.formattedDamage, equals('1d8 piercing'));
      
      print('✅ Light Crossbow correctly displays: ${weapon.formattedDamage}');
    });
  });
}
