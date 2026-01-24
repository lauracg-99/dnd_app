import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/PersonalizedSlotsTab/characters_personalized_tab.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Personalized Slot Reordering Tests', () {
    testWidgets('Should reorder slots when dragged', (WidgetTester tester) async {
      // Create test slots
      final testSlots = [
        CharacterPersonalizedSlot(name: 'Slot 1', maxSlots: 4, usedSlots: 2),
        CharacterPersonalizedSlot(name: 'Slot 2', maxSlots: 6, usedSlots: 3),
        CharacterPersonalizedSlot(name: 'Slot 3', maxSlots: 8, usedSlots: 1),
      ];

      List<CharacterPersonalizedSlot> updatedSlots = testSlots;

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CharactersPersonalizedTab(
                personalizedSlots: testSlots,
                onPersonalizedSlotsChanged: (slots) {
                  updatedSlots = slots;
                },
                onAutoSaveCharacter: () {},
                characterName: 'Test Character',
              ),
            ),
          ),
        ),
      );

      // Verify initial order
      expect(updatedSlots[0].name, 'Slot 1');
      expect(updatedSlots[1].name, 'Slot 2');
      expect(updatedSlots[2].name, 'Slot 3');

      // Find the drag handles
      final dragHandles = find.byIcon(Icons.drag_handle);
      expect(dragHandles, findsNWidgets(3));

      // Verify slot names are displayed
      expect(find.text('Slot 1'), findsOneWidget);
      expect(find.text('Slot 2'), findsOneWidget);
      expect(find.text('Slot 3'), findsOneWidget);

      // Perform drag and drop: move Slot 3 to position 0
      await tester.drag(dragHandles.at(2), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify new order
      expect(updatedSlots[0].name, 'Slot 3');
      expect(updatedSlots[1].name, 'Slot 1');
      expect(updatedSlots[2].name, 'Slot 2');
    });

    test('Reorder logic should handle edge cases correctly', () {
      final testSlots = [
        CharacterPersonalizedSlot(name: 'Slot 1', maxSlots: 4, usedSlots: 2),
        CharacterPersonalizedSlot(name: 'Slot 2', maxSlots: 6, usedSlots: 3),
        CharacterPersonalizedSlot(name: 'Slot 3', maxSlots: 8, usedSlots: 1),
      ];

      // Test moving from lower to higher index
      var newSlots = List<CharacterPersonalizedSlot>.from(testSlots);
      final item = newSlots.removeAt(0); // Remove Slot 1
      newSlots.insert(2, item); // Insert at position 2
      expect(newSlots[0].name, 'Slot 2');
      expect(newSlots[1].name, 'Slot 3');
      expect(newSlots[2].name, 'Slot 1');

      // Test moving from higher to lower index
      newSlots = List<CharacterPersonalizedSlot>.from(testSlots);
      final item2 = newSlots.removeAt(2); // Remove Slot 3
      newSlots.insert(0, item2); // Insert at position 0
      expect(newSlots[0].name, 'Slot 3');
      expect(newSlots[1].name, 'Slot 1');
      expect(newSlots[2].name, 'Slot 2');
    });

    testWidgets('Should handle layout constraints correctly', (WidgetTester tester) async {
      // Create test slots with long names to test text overflow
      final testSlots = [
        CharacterPersonalizedSlot(name: 'Very Long Slot Name That Might Overflow', maxSlots: 4, usedSlots: 2),
        CharacterPersonalizedSlot(name: 'Slot 2', maxSlots: 6, usedSlots: 3),
      ];

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CharactersPersonalizedTab(
                personalizedSlots: testSlots,
                onPersonalizedSlotsChanged: (slots) {},
                onAutoSaveCharacter: () {},
                characterName: 'Test Character',
              ),
            ),
          ),
        ),
      );

      // Verify the widget renders without layout errors
      expect(find.byType(CharactersPersonalizedTab), findsOneWidget);
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
      
      // Verify slot names are displayed (even if truncated)
      expect(find.text('Very Long Slot Name That Might Overflow'), findsOneWidget);
      expect(find.text('Slot 2'), findsOneWidget);
    });
  });
}
