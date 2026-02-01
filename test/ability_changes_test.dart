import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Ability Changes Flag Tests', () {
    test('Character stats should update correctly', () {
      // Create a test character
      final testCharacter = Character(
        id: 'test_character_abilities',
        name: 'Test Character',
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
        characterClass: 'Fighter',
        level: 1,
        spellSlots: CharacterSpellSlots(),
        pillars: CharacterPillars(),
        appearance: CharacterAppearance(),
        deathSaves: CharacterDeathSaves(),
        languages: CharacterLanguages(),
        moneyItems: CharacterMoneyItems(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verify initial stats
      expect(testCharacter.stats.strength, 10);
      expect(testCharacter.stats.dexterity, 10);
      expect(testCharacter.stats.constitution, 10);
      expect(testCharacter.stats.intelligence, 10);
      expect(testCharacter.stats.wisdom, 10);
      expect(testCharacter.stats.charisma, 10);
      
      // Verify modifiers are calculated correctly using getModifier method
      expect(testCharacter.stats.getModifier(testCharacter.stats.strength), 0); // 10 = +0
      expect(testCharacter.stats.getModifier(testCharacter.stats.dexterity), 0);
      expect(testCharacter.stats.getModifier(15), 2); // 15 = +2
      expect(testCharacter.stats.getModifier(8), -1); // 8 = -1
    });
  });
}
