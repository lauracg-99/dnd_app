import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/views/diaries/diary_list_screen.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('DiaryListScreen Widget Tests', () {
    testWidgets('DiaryListScreen widget can be created with required parameters', (WidgetTester tester) async {
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
        () => DiaryListScreen(
          character: character,
        ),
        returnsNormally,
      );
    });
  });
}
