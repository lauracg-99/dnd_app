import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/health_section.dart';

void main() {
  group('Exhaustion Color Progression Tests', () {
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

    test('Exhaustion level 0 should be grey', () {
      final color = healthSection.getExhaustionColor(0);
      expect(color, Colors.grey.shade700);
    });

    test('Exhaustion level 1 should be light orange', () {
      final color = healthSection.getExhaustionColor(1);
      expect(color, Colors.orange.shade600);
    });

    test('Exhaustion level 2 should be deep orange', () {
      final color = healthSection.getExhaustionColor(2);
      expect(color, Colors.deepOrange.shade600);
    });

    test('Exhaustion level 3 should be light red', () {
      final color = healthSection.getExhaustionColor(3);
      expect(color, Colors.red.shade600);
    });

    test('Exhaustion level 4 should be medium red', () {
      final color = healthSection.getExhaustionColor(4);
      expect(color, Colors.red.shade700);
    });

    test('Exhaustion level 5 should be dark red', () {
      final color = healthSection.getExhaustionColor(5);
      expect(color, Colors.red.shade800);
    });

    test('Exhaustion level 6 should be darkest red', () {
      final color = healthSection.getExhaustionColor(6);
      expect(color, Colors.red.shade900);
    });

    test('Colors should progress from mild to severe', () {
      final colors = [
        healthSection.getExhaustionColor(0),
        healthSection.getExhaustionColor(1),
        healthSection.getExhaustionColor(2),
        healthSection.getExhaustionColor(3),
        healthSection.getExhaustionColor(4),
        healthSection.getExhaustionColor(5),
        healthSection.getExhaustionColor(6),
      ];

      // Level 0 should be grey (no exhaustion)
      expect(colors[0], Colors.grey.shade700);
      
      // Level 1 should be orange (warning)
      expect(colors[1], Colors.orange.shade600);
      
      // Level 2 should be deep orange (moderate warning)
      expect(colors[2], Colors.deepOrange.shade600);
      
      // Levels 3-6 should be progressively darker reds
      expect(colors[3], Colors.red.shade600);   // Light red
      expect(colors[4], Colors.red.shade700);   // Medium red
      expect(colors[5], Colors.red.shade800);   // Dark red
      expect(colors[6], Colors.red.shade900);   // Darkest red
    });

    test('Invalid level should default to grey', () {
      final color = healthSection.getExhaustionColor(99);
      expect(color, Colors.grey.shade700);
    });

    test('Negative level should default to grey', () {
      final color = healthSection.getExhaustionColor(-1);
      expect(color, Colors.grey.shade700);
    });
  });
}
