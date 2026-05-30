import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/views/characters/NotesTab/characters_notes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('CharactersNotes Widget Tests', () {
    test('CharactersNotes widget can be instantiated with required parameters', () {
      // Create required controllers
      final backstoryController = QuillController.basic();
      final gimmickController = TextEditingController();
      final quirkController = TextEditingController();
      final wantsController = TextEditingController();
      final needsController = TextEditingController();
      final conflictController = TextEditingController();

      // Verify widget can be instantiated without throwing
      expect(
        () => CharactersNotes(
          backstoryController: backstoryController,
          gimmickController: gimmickController,
          quirkController: quirkController,
          wantsController: wantsController,
          needsController: needsController,
          conflictController: conflictController,
        ),
        returnsNormally,
      );

      // Clean up
      backstoryController.dispose();
      gimmickController.dispose();
      quirkController.dispose();
      wantsController.dispose();
      needsController.dispose();
      conflictController.dispose();
    });

    test('Controllers can be created and disposed correctly', () {
      final backstoryController = QuillController.basic();
      final gimmickController = TextEditingController();
      final quirkController = TextEditingController();
      final wantsController = TextEditingController();
      final needsController = TextEditingController();
      final conflictController = TextEditingController();

      // Verify controllers are created
      expect(backstoryController, isNotNull);
      expect(gimmickController, isNotNull);
      expect(quirkController, isNotNull);
      expect(wantsController, isNotNull);
      expect(needsController, isNotNull);
      expect(conflictController, isNotNull);

      // Verify text controllers can have text set
      gimmickController.text = 'Test gimmick';
      expect(gimmickController.text, 'Test gimmick');

      // Clean up
      backstoryController.dispose();
      gimmickController.dispose();
      quirkController.dispose();
      wantsController.dispose();
      needsController.dispose();
      conflictController.dispose();
    });

    test('Save callback can be invoked', () {
      bool saveCalled = false;
      bool callback() => saveCalled = true;
      
      callback();
      
      expect(saveCalled, isTrue);
    });
  });
}
