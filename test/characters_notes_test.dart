import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/characters/NotesTab/characters_notes.dart';

void main() {
  group('CharactersNotes Widget Tests', () {
    testWidgets('CharactersNotes renders correctly with all required parameters', (WidgetTester tester) async {
      // Create required controllers
      final backstoryController = TextEditingController();
      final gimmickController = TextEditingController();
      final quirkController = TextEditingController();
      final wantsController = TextEditingController();
      final needsController = TextEditingController();
      final conflictController = TextEditingController();

      // Create the widget
      final widget = MaterialApp(
        home: Scaffold(
          body: CharactersNotes(
            backstoryController: backstoryController,
            gimmickController: gimmickController,
            quirkController: quirkController,
            wantsController: wantsController,
            needsController: needsController,
            conflictController: conflictController,
            onSaveCharacter: () {},
          ),
        ),
      );

      // Build the widget
      await tester.pumpWidget(widget);

      // Verify the widget renders
      expect(find.byType(CharactersNotes), findsOneWidget);
      expect(find.text('Character Backstory'), findsOneWidget);
      expect(find.text('Character Pillars'), findsOneWidget);
      // No save button should be present initially
      
      // Verify text fields are present
      expect(find.byType(TextField), findsNWidgets(6)); // Backstory + 5 pillar fields
      
      // Verify pillar labels
      expect(find.text('Gimmick'), findsOneWidget);
      expect(find.text('Quirk'), findsOneWidget);
      expect(find.text('Wants'), findsOneWidget);
      expect(find.text('Needs'), findsOneWidget);
      expect(find.text('Conflict'), findsOneWidget);

      // Clean up
      backstoryController.dispose();
      gimmickController.dispose();
      quirkController.dispose();
      wantsController.dispose();
      needsController.dispose();
      conflictController.dispose();
    });

    testWidgets('CharactersNotes shows unsaved changes indicator when text is entered', (WidgetTester tester) async {
      // Create required controllers
      final backstoryController = TextEditingController();
      final gimmickController = TextEditingController();
      final quirkController = TextEditingController();
      final wantsController = TextEditingController();
      final needsController = TextEditingController();
      final conflictController = TextEditingController();

      // Create the widget
      final widget = MaterialApp(
        home: Scaffold(
          body: CharactersNotes(
            backstoryController: backstoryController,
            gimmickController: gimmickController,
            quirkController: quirkController,
            wantsController: wantsController,
            needsController: needsController,
            conflictController: conflictController,
            onSaveCharacter: () {},
          ),
        ),
      );

      // Build the widget
      await tester.pumpWidget(widget);

      // Initially should not show auto-save indicator
      expect(find.text('Auto-save in 30 seconds...'), findsNothing);

      // Enter text in a field
      final backstoryField = find.byType(TextField).first;
      await tester.enterText(backstoryField, 'Test backstory');
      
      // Wait for debounce timer to complete (500ms)
      await tester.pump(const Duration(milliseconds: 600));

      // Should now show auto-save indicator
      expect(find.text('Auto-save in 30 seconds...'), findsOneWidget);

      // Clean up
      backstoryController.dispose();
      gimmickController.dispose();
      quirkController.dispose();
      wantsController.dispose();
      needsController.dispose();
      conflictController.dispose();
    });

    testWidgets('CharactersNotes auto-save timer works correctly', (WidgetTester tester) async {
      // Create required controllers
      final backstoryController = TextEditingController();
      final gimmickController = TextEditingController();
      final quirkController = TextEditingController();
      final wantsController = TextEditingController();
      final needsController = TextEditingController();
      final conflictController = TextEditingController();

      bool saveCalled = false;

      // Create the widget
      final widget = MaterialApp(
        home: Scaffold(
          body: CharactersNotes(
            backstoryController: backstoryController,
            gimmickController: gimmickController,
            quirkController: quirkController,
            wantsController: wantsController,
            needsController: needsController,
            conflictController: conflictController,
            onSaveCharacter: () => saveCalled = true,
          ),
        ),
      );

      // Build the widget
      await tester.pumpWidget(widget);

      // Enter text to create unsaved changes
      final backstoryField = find.byType(TextField).first;
      await tester.enterText(backstoryField, 'Test backstory');
      
      // Wait for debounce timer to complete (500ms)
      await tester.pump(const Duration(milliseconds: 600));

      // Verify auto-save indicator is shown
      expect(find.text('Auto-save in 30 seconds...'), findsOneWidget);

      // Wait for auto-save timer to complete (simulate 30 seconds passing)
      await tester.pump(const Duration(seconds: 31));

      // Verify save callback was called
      expect(saveCalled, isTrue);

      // Verify auto-save indicator is hidden after save
      expect(find.text('Auto-save in 30 seconds...'), findsNothing);

      // Clean up
      backstoryController.dispose();
      gimmickController.dispose();
      quirkController.dispose();
      wantsController.dispose();
      needsController.dispose();
      conflictController.dispose();
    });
  });
}
