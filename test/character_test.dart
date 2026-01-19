import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/viewmodels/characters_viewmodel.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Character System Tests', () {
    test('CharactersViewModel should initialize correctly', () {
      final viewModel = CharactersViewModel();
      
      expect(viewModel.characters.isEmpty, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      expect(viewModel.searchQuery, '');
      expect(viewModel.selectedClass, '');
    });

    test('CharactersViewModel should filter correctly', () {
      final viewModel = CharactersViewModel();
      
      // Test available classes
      expect(viewModel.availableClasses.contains('Fighter'), true);
      expect(viewModel.availableClasses.contains('Wizard'), true);
      expect(viewModel.availableClasses.length, greaterThan(10));
    });

    test('Character model should create correctly', () {
      final now = DateTime.now();
      final stats = CharacterStats(
        strength: 16,
        dexterity: 14,
        constitution: 15,
        intelligence: 12,
        wisdom: 13,
        charisma: 10,
      );
      
      final character = Character(
        id: 'test-character-1',
        name: 'Test Character',
        stats: stats,
        savingThrows: CharacterSavingThrows(),
        skillChecks: CharacterSkillChecks(),
        health: CharacterHealth(maxHitPoints: 20, currentHitPoints: 20),
        characterClass: 'Fighter',
        spellSlots: CharacterSpellSlots(),
        pillars: CharacterPillars(),
        createdAt: now,
        updatedAt: now,
      );
      
      expect(character.name, 'Test Character');
      expect(character.characterClass, 'Fighter');
      expect(character.stats.strength, 16);
      expect(character.health.maxHitPoints, 20);
    });

    test('Character model should serialize/deserialize correctly', () {
      final original = Character(
        id: 'test-123',
        name: 'Test Hero',
        stats: CharacterStats(
          strength: 18,
          dexterity: 16,
          constitution: 14,
          intelligence: 12,
          wisdom: 10,
          charisma: 8,
        ),
        savingThrows: CharacterSavingThrows(
          strengthProficiency: true,
          constitutionProficiency: true,
        ),
        skillChecks: CharacterSkillChecks(
          athleticsProficiency: true,
          intimidationProficiency: true,
        ),
        health: CharacterHealth(
          maxHitPoints: 25,
          currentHitPoints: 25,
          hitDice: 2,
          hitDiceType: 'd10',
        ),
        characterClass: 'Barbarian',
        subclass: 'Path of the Zealot',
        attacks: [
          CharacterAttack(
            id: 'attack-1',
            name: 'Greataxe',
            attackBonus: '+5',
            damage: '2d12+3',
            damageType: 'Slashing',
          ),
        ],
        spellSlots: CharacterSpellSlots(),
        spells: ['Rage', 'Unarmored Defense'],
        quickGuide: 'Brave warrior',
        backstory: 'Born in the mountains',
        pillars: CharacterPillars(
          gimmick: 'Always angry',
          quirk: 'Collects rocks',
          wants: 'Glory',
          needs: 'Revenge',
          conflict: 'Anger vs. Compassion',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Test serialization
      final json = original.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['resource_id'], 'character');
      expect(json['stats']['name']['value'], 'Test Hero');
      
      // Test deserialization
      final deserialized = Character.fromJson(json);
      expect(deserialized.id, original.id);
      expect(deserialized.name, original.name);
      expect(deserialized.characterClass, original.characterClass);
      expect(deserialized.stats.strength, original.stats.strength);
      expect(deserialized.savingThrows.strengthProficiency, original.savingThrows.strengthProficiency);
      expect(deserialized.skillChecks.athleticsProficiency, original.skillChecks.athleticsProficiency);
      expect(deserialized.health.maxHitPoints, original.health.maxHitPoints);
      expect(deserialized.attacks.length, original.attacks.length);
      expect(deserialized.attacks.first.name, original.attacks.first.name);
      expect(deserialized.spells, original.spells);
      expect(deserialized.quickGuide, original.quickGuide);
      expect(deserialized.backstory, original.backstory);
      expect(deserialized.pillars.gimmick, original.pillars.gimmick);
    });

    test('Character stats should calculate modifiers correctly', () {
      final stats = CharacterStats(
        strength: 20, // +5 modifier
        dexterity: 10, // +0 modifier
        constitution: 8, // -1 modifier
        intelligence: 14, // +2 modifier
        wisdom: 16, // +3 modifier
        charisma: 12, // +1 modifier
      );
      
      expect(stats.getModifier(20), 5);
      expect(stats.getModifier(10), 0);
      expect(stats.getModifier(8), -1);
      expect(stats.getModifier(14), 2);
      expect(stats.getModifier(16), 3);
      expect(stats.getModifier(12), 1);
    });
  });
}
