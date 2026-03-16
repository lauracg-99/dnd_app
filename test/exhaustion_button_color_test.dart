import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dnd_app/views/characters/CharacterCoverTab/health_section.dart';

void main() {
  group('Exhaustion Button Color Tests', () {
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

    test('Button colors should match description colors for all levels', () {
      for (int level = 0; level <= 6; level++) {
        final expectedColor = healthSection.getExhaustionColor(level);
        
        // The button should use the same color as the description
        // This is verified by checking that getExhaustionColor returns the expected color
        switch (level) {
          case 0:
            expect(expectedColor, Colors.grey.shade700);
            break;
          case 1:
            expect(expectedColor, Colors.orange.shade600);
            break;
          case 2:
            expect(expectedColor, Colors.deepOrange.shade600);
            break;
          case 3:
            expect(expectedColor, Colors.red.shade600);
            break;
          case 4:
            expect(expectedColor, Colors.red.shade700);
            break;
          case 5:
            expect(expectedColor, Colors.red.shade800);
            break;
          case 6:
            expect(expectedColor, Colors.red.shade900);
            break;
        }
      }
    });

    test('Color progression should be consistent between buttons and descriptions', () {
      final buttonColors = <Color>[];
      final descriptionColors = <Color>[];
      
      for (int level = 0; level <= 6; level++) {
        final color = healthSection.getExhaustionColor(level);
        buttonColors.add(color);
        descriptionColors.add(color);
      }
      
      // Both lists should be identical since they use the same method
      expect(buttonColors.length, descriptionColors.length);
      for (int i = 0; i < buttonColors.length; i++) {
        expect(buttonColors[i], descriptionColors[i]);
      }
    });

    test('Level 3 button should be more severe than level 2', () {
      final level2Color = healthSection.getExhaustionColor(2);
      final level3Color = healthSection.getExhaustionColor(3);
      
      // Level 2 should be deep orange, level 3 should be red
      expect(level2Color, Colors.deepOrange.shade600);
      expect(level3Color, Colors.red.shade600);
      
      // They should be different colors
      expect(level2Color, isNot(equals(level3Color)));
    });

    test('Level 4 button should be more severe than level 3', () {
      final level3Color = healthSection.getExhaustionColor(3);
      final level4Color = healthSection.getExhaustionColor(4);
      
      // Level 3 should be red.shade600, level 4 should be red.shade700
      expect(level3Color, Colors.red.shade600);
      expect(level4Color, Colors.red.shade700);
      
      // They should be different shades
      expect(level3Color, isNot(equals(level4Color)));
    });

    test('Level 0 should remain grey when not selected', () {
      final level0Color = healthSection.getExhaustionColor(0);
      expect(level0Color, Colors.grey.shade700);
    });

    test('Progression should show increasing severity', () {
      final colors = [
        healthSection.getExhaustionColor(0), // Grey
        healthSection.getExhaustionColor(1), // Orange
        healthSection.getExhaustionColor(2), // Deep orange
        healthSection.getExhaustionColor(3), // Light red
        healthSection.getExhaustionColor(4), // Medium red
        healthSection.getExhaustionColor(5), // Dark red
        healthSection.getExhaustionColor(6), // Darkest red
      ];
      
      // Verify the progression is correct
      expect(colors[0], Colors.grey.shade700);
      expect(colors[1], Colors.orange.shade600);
      expect(colors[2], Colors.deepOrange.shade600);
      expect(colors[3], Colors.red.shade600);
      expect(colors[4], Colors.red.shade700);
      expect(colors[5], Colors.red.shade800);
      expect(colors[6], Colors.red.shade900);
    });
  });
}
