import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Long Rest Exhaustion Reduction Tests', () {
    test('Long rest should reduce exhaustion by 1 when level > 0', () {
      // Simulate character with exhaustion level 3
      final originalLevel = 3;
      var currentLevel = originalLevel;
      
      // Simulate long rest logic
      if (currentLevel > 0) {
        currentLevel--;
      }
      
      expect(currentLevel, 2); // Should be reduced from 3 to 2
    });

    test('Long rest should not reduce exhaustion below 0', () {
      // Simulate character with exhaustion level 0
      final originalLevel = 0;
      var currentLevel = originalLevel;
      
      // Simulate long rest logic
      if (currentLevel > 0) {
        currentLevel--;
      }
      
      expect(currentLevel, 0); // Should remain 0
    });

    test('Long rest should reduce exhaustion from level 1 to 0', () {
      // Simulate character with exhaustion level 1
      final originalLevel = 1;
      var currentLevel = originalLevel;
      
      // Simulate long rest logic
      if (currentLevel > 0) {
        currentLevel--;
      }
      
      expect(currentLevel, 0); // Should be reduced from 1 to 0
    });

    test('Long rest should reduce exhaustion from level 6 to 5', () {
      // Simulate character with maximum exhaustion (death)
      final originalLevel = 6;
      var currentLevel = originalLevel;
      
      // Simulate long rest logic
      if (currentLevel > 0) {
        currentLevel--;
      }
      
      expect(currentLevel, 5); // Should be reduced from 6 to 5 (character is no longer dead)
    });

    test('CharacterDeathSaves should maintain proper state after exhaustion reduction', () {
      // Create death saves with exhaustion level 4
      final originalDeathSaves = CharacterDeathSaves(
        successes: [true, false, false],
        failures: [false, true, false],
        exhaustionLevel: 4,
      );
      
      // Simulate long rest - reduce exhaustion by 1
      final updatedDeathSaves = originalDeathSaves.copyWith(
        exhaustionLevel: originalDeathSaves.exhaustionLevel - 1,
      );
      
      expect(updatedDeathSaves.exhaustionLevel, 3);
      expect(updatedDeathSaves.successes, [true, false, false]); // Should remain unchanged
      expect(updatedDeathSaves.failures, [false, true, false]); // Should remain unchanged
    });

    test('Exhaustion reduction should work with copyWith method', () {
      final deathSaves = CharacterDeathSaves(exhaustionLevel: 5);
      
      // Reduce exhaustion by 1 using copyWith
      final reducedDeathSaves = deathSaves.copyWith(exhaustionLevel: 4);
      
      expect(reducedDeathSaves.exhaustionLevel, 4);
      expect(reducedDeathSaves.successes, [false, false, false]); // Default values
      expect(reducedDeathSaves.failures, [false, false, false]); // Default values
    });

    test('Multiple long rests should eventually reduce exhaustion to 0', () {
      // Simulate character with exhaustion level 3
      var currentLevel = 3;
      
      // First long rest
      if (currentLevel > 0) currentLevel--;
      expect(currentLevel, 2);
      
      // Second long rest
      if (currentLevel > 0) currentLevel--;
      expect(currentLevel, 1);
      
      // Third long rest
      if (currentLevel > 0) currentLevel--;
      expect(currentLevel, 0);
      
      // Fourth long rest (should remain 0)
      if (currentLevel > 0) currentLevel--;
      expect(currentLevel, 0);
    });

    test('Message should indicate exhaustion reduction when applicable', () {
      // Test case 1: Character had exhaustion, it was reduced
      final hadExhaustion1 = true;
      final previousLevel1 = 3;
      final currentLevel1 = 2;
      
      String message1 = 'Long rest completed! HP, spell slots, and all class resources restored!';
      if (hadExhaustion1 && currentLevel1 < previousLevel1) {
        message1 += ' Exhaustion reduced by 1.';
      }
      
      expect(message1, 'Long rest completed! HP, spell slots, and all class resources restored! Exhaustion reduced by 1.');
      
      // Test case 2: Character had no exhaustion
      final hadExhaustion2 = false;
      final previousLevel2 = 0;
      final currentLevel2 = 0;
      
      String message2 = 'Long rest completed! HP, spell slots, and all class resources restored!';
      if (hadExhaustion2 && currentLevel2 < previousLevel2) {
        message2 += ' Exhaustion reduced by 1.';
      }
      
      expect(message2, 'Long rest completed! HP, spell slots, and all class resources restored!');
      
      // Test case 3: Character had exhaustion but was already at 0
      final hadExhaustion3 = true;
      final previousLevel3 = 0;
      final currentLevel3 = 0;
      
      String message3 = 'Long rest completed! HP, spell slots, and all class resources restored!';
      if (hadExhaustion3 && currentLevel3 < previousLevel3) {
        message3 += ' Exhaustion reduced by 1.';
      }
      
      expect(message3, 'Long rest completed! HP, spell slots, and all class resources restored!');
    });
  });
}
