import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/health_section.dart';
import 'package:flutter/material.dart';

void main() {
  group('Cumulative Exhaustion Tests', () {
    late HealthSection healthSection;
    
    setUp(() {
      healthSection = HealthSection(
        maxHpController: TextEditingController(),
        currentHpController: TextEditingController(),
        tempHpController: TextEditingController(),
        hitDiceController: TextEditingController(),
        hitDiceTypeController: TextEditingController(),
        exhaustionLevel: 0,
        onExhaustionChanged: (level) {},
      );
    });

    test('Exhaustion level 0 should show no effects', () {
      final result = healthSection.getCumulativeExhaustionDescription(0);
      expect(result, 'No exhaustion effects.');
    });

    test('Exhaustion level 1 should show only level 1 effect', () {
      final result = healthSection.getCumulativeExhaustionDescription(1);
      expect(result, '· Level 1: Disadvantage on ability checks');
    });

    test('Exhaustion level 2 should show cumulative effects of levels 1 and 2', () {
      final result = healthSection.getCumulativeExhaustionDescription(2);
      expect(result, '· Level 1: Disadvantage on ability checks\n· Level 2: Speed halved');
    });

    test('Exhaustion level 3 should show cumulative effects of levels 1, 2, and 3', () {
      final result = healthSection.getCumulativeExhaustionDescription(3);
      expect(result, '· Level 1: Disadvantage on ability checks\n· Level 2: Speed halved\n· Level 3: Disadvantage on attack and saving throws');
    });

    test('Exhaustion level 4 should show cumulative effects of levels 1-4', () {
      final result = healthSection.getCumulativeExhaustionDescription(4);
      expect(result, '· Level 1: Disadvantage on ability checks\n· Level 2: Speed halved\n· Level 3: Disadvantage on attack and saving throws\n· Level 4: Maximum hit points halved');
    });

    test('Exhaustion level 5 should show cumulative effects of levels 1-5', () {
      final result = healthSection.getCumulativeExhaustionDescription(5);
      expect(result, '· Level 1: Disadvantage on ability checks\n· Level 2: Speed halved\n· Level 3: Disadvantage on attack and saving throws\n· Level 4: Maximum hit points halved\n· Level 5: Movement speed reduced to zero');
    });

    test('Exhaustion level 6 should show cumulative effects of levels 1-6', () {
      final result = healthSection.getCumulativeExhaustionDescription(6);
      expect(result, '· Level 1: Disadvantage on ability checks\n· Level 2: Speed halved\n· Level 3: Disadvantage on attack and saving throws\n· Level 4: Maximum hit points halved\n· Level 5: Movement speed reduced to zero\n· Level 6: Death');
    });

    test('All exhaustion effects should be in correct order', () {
      for (int level = 1; level <= 6; level++) {
        final result = healthSection.getCumulativeExhaustionDescription(level);
        expect(result, isNotEmpty);
        expect(result, contains('Disadvantage on ability checks'));
        
        if (level >= 2) {
          expect(result, contains('Speed halved'));
        }
        if (level >= 3) {
          expect(result, contains('Disadvantage on attack and saving throws'));
        }
        if (level >= 4) {
          expect(result, contains('Maximum hit points halved'));
        }
        if (level >= 5) {
          expect(result, contains('Movement speed reduced to zero'));
        }
        if (level >= 6) {
          expect(result, contains('Death'));
        }
      }
    });
  });
}
