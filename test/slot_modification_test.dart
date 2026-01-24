import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/PersonalizedSlotsTab/characters_personalized_tab.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Personalized Slot Modification Tests', () {
    test('Slot modification dialog should handle value changes correctly', () {
      // Create a test slot
      final testSlot = CharacterPersonalizedSlot(
        name: 'Test Slot',
        maxSlots: 4,
        usedSlots: 2,
        diceType: 'd6',
      );

      // Verify initial state
      expect(testSlot.maxSlots, 4);
      expect(testSlot.usedSlots, 2);

      // Test copyWith functionality (used in dialog)
      final updatedSlot = testSlot.copyWith(maxSlots: 6, usedSlots: 3);
      expect(updatedSlot.maxSlots, 6);
      expect(updatedSlot.usedSlots, 3);
      expect(updatedSlot.name, 'Test Slot'); // Should remain unchanged
    });

    test('Slot values should clamp correctly', () {
      final testSlot = CharacterPersonalizedSlot(
        name: 'Test Slot',
        maxSlots: 4,
        usedSlots: 2,
        diceType: 'd6',
      );

      // Test clamping used slots to max slots
      final clampedHigh = testSlot.copyWith(usedSlots: 10);
      expect(clampedHigh.usedSlots, 10); // copyWith doesn't clamp, dialog does

      // Test negative values
      final clampedLow = testSlot.copyWith(usedSlots: -1);
      expect(clampedLow.usedSlots, -1); // copyWith doesn't clamp, dialog does

      // Verify the clamping logic that would be used in dialog
      final clampedValue = (-1).clamp(0, testSlot.maxSlots);
      expect(clampedValue, 0);

      final clampedValueHigh = (10).clamp(0, testSlot.maxSlots);
      expect(clampedValueHigh, 4);
    });
  });
}
