import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dnd_app/views/diaries/diary_editor_screen.dart';
import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/utils/simple_quill_editor_no_card.dart';
import 'package:dnd_app/utils/QuillToolbarConfigs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('DiaryEditorScreen Widget Tests', () {
    testWidgets('DiaryEditorScreen widget can be created with required parameters', (WidgetTester tester) async {
      // Create a test character
      final character = Character(
        id: 'test-id',
        name: 'Test Character',
        characterClass: 'Fighter',
        level: 1,
        stats: CharacterStats(
          strength: 10,
          dexterity: 10,
          constitution: 10,
          intelligence: 10,
          wisdom: 10,
          charisma: 10,
          proficiencyBonus: 2,
          armorClass: 10,
          speed: 30,
          initiative: 0,
          inspiration: false,
          hasConcentration: false,
          hasShield: false,
        ),
        savingThrows: CharacterSavingThrows(),
        skillChecks: CharacterSkillChecks(),
        health: CharacterHealth(
          maxHitPoints: 10,
          currentHitPoints: 10,
          temporaryHitPoints: 0,
          hitDice: 1,
          hitDiceType: 'd8',
        ),
        spellSlots: CharacterSpellSlots(),
        pillars: CharacterPillars(),
        appearance: CharacterAppearance(),
        deathSaves: CharacterDeathSaves(),
        languages: CharacterLanguages(),
        moneyItems: CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
