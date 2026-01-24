import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/views/diaries/diary_editor_screen.dart';
import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/utils/simple_quill_editor_no_card.dart';
import 'package:dnd_app/utils/QuillToolbarConfigs.dart';

void main() {
  group('DiaryEditorScreen Widget Tests', () {
    testWidgets('DiaryEditorScreen widget can be created with required parameters', (WidgetTester tester) async {
      // Create a test character
      final character = Character.withLevel(
        id: 'test-id',
        name: 'Test Character',
        characterClass: 'Fighter',
        level: 1,
        background: 'Soldier',
        race: 'Human',
        alignment: 'Lawful Good',
        experience: 0,
        proficiencyBonus: 2,
      );

      // Verify widget can be instantiated without throwing
      expect(
        () => DiaryEditorScreen(
          character: character,
        ),
        returnsNormally,
      );
    });

    testWidgets('SimpleQuillEditorNoCard widget can be created with required parameters', (WidgetTester tester) async {
      // Create required controller
      final controller = QuillController.basic();

      // Verify widget can be instantiated without throwing
      expect(
        () => SimpleQuillEditorNoCard(
          controller: controller,
          toolbarConfig: QuillToolbarConfigs.minimal,
        ),
        returnsNormally,
      );

      // Clean up
      controller.dispose();
    });
  });
}
