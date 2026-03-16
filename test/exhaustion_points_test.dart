import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Exhaustion Points Tests', () {
    test('CharacterDeathSaves should have default exhaustion level of 0', () {
      final deathSaves = CharacterDeathSaves();
      expect(deathSaves.exhaustionLevel, 0);
    });

    test('CharacterDeathSaves should initialize with custom exhaustion level', () {
      final deathSaves = CharacterDeathSaves(
        successes: [true, false, false],
        failures: [false, true, false],
        exhaustionLevel: 3,
      );
      expect(deathSaves.exhaustionLevel, 3);
      expect(deathSaves.successes, [true, false, false]);
      expect(deathSaves.failures, [false, true, false]);
    });

    test('CharacterDeathSaves toJson should include exhaustion level', () {
      final deathSaves = CharacterDeathSaves(
        successes: [true, false, false],
        failures: [false, true, false],
        exhaustionLevel: 2,
      );
      
      final json = deathSaves.toJson();
      expect(json['exhaustion_level'], 2);
      expect(json['successes'], [true, false, false]);
      expect(json['failures'], [false, true, false]);
    });

    test('CharacterDeathSaves fromJson should parse exhaustion level', () {
      final json = {
        'successes': [true, false, false],
        'failures': [false, true, false],
        'exhaustion_level': 4,
      };
      
      final deathSaves = CharacterDeathSaves.fromJson(json);
      expect(deathSaves.exhaustionLevel, 4);
      expect(deathSaves.successes, [true, false, false]);
      expect(deathSaves.failures, [false, true, false]);
    });

    test('CharacterDeathSaves fromJson should default exhaustion level to 0 when missing', () {
      final json = {
        'successes': [true, false, false],
        'failures': [false, true, false],
      };
      
      final deathSaves = CharacterDeathSaves.fromJson(json);
      expect(deathSaves.exhaustionLevel, 0);
    });

    test('CharacterDeathSaves copyWith should update exhaustion level', () {
      final original = CharacterDeathSaves(
        successes: [true, false, false],
        failures: [false, true, false],
        exhaustionLevel: 2,
      );
      
      final updated = original.copyWith(exhaustionLevel: 5);
      expect(updated.exhaustionLevel, 5);
      expect(updated.successes, [true, false, false]);
      expect(updated.failures, [false, true, false]);
    });

    test('CharacterDeathSaves copyWith should preserve original when null', () {
      final original = CharacterDeathSaves(
        successes: [true, false, false],
        failures: [false, true, false],
        exhaustionLevel: 2,
      );
      
      final updated = original.copyWith();
      expect(updated.exhaustionLevel, 2);
      expect(updated.successes, [true, false, false]);
      expect(updated.failures, [false, true, false]);
    });

    test('Exhaustion level validation should accept values 0-6', () {
      for (int level = 0; level <= 6; level++) {
        final deathSaves = CharacterDeathSaves(exhaustionLevel: level);
        expect(deathSaves.exhaustionLevel, level);
      }
    });

    test('Exhaustion level should handle negative values (though not recommended)', () {
      final deathSaves = CharacterDeathSaves(exhaustionLevel: -1);
      expect(deathSaves.exhaustionLevel, -1);
    });

    test('Exhaustion level should handle values above 6 (though not recommended)', () {
      final deathSaves = CharacterDeathSaves(exhaustionLevel: 10);
      expect(deathSaves.exhaustionLevel, 10);
    });
  });
}
