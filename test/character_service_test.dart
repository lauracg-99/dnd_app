import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/services/character_service.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Character Service Integration Tests', () {
    setUp(() {
      // Clear memory cache before each test
      CharacterService.clearMemoryCache();
    });

    test('Should create and save character successfully', () async {
      final character = await CharacterService.createCharacter(
        name: 'Test Hero',
        characterClass: 'Fighter',
        subclass: 'Champion',
      );

      expect(character.name, 'Test Hero');
      expect(character.characterClass, 'Fighter');
      expect(character.level, 1); // Default level should be 1
      expect(character.subclass, 'Champion');
      expect(character.stats.strength, 10);
      expect(character.health.maxHitPoints, 10);
    });

    test('Should load all characters', () async {
      // Create a few test characters
      await CharacterService.createCharacter(name: 'Hero 1', characterClass: 'Fighter');
      await CharacterService.createCharacter(name: 'Hero 2', characterClass: 'Wizard');
      
      final characters = await CharacterService.loadAllCharacters();
      
      expect(characters.length, 2);
      expect(characters.any((c) => c.name == 'Hero 1'), true);
      expect(characters.any((c) => c.name == 'Hero 2'), true);
    });

    test('Should search characters correctly', () async {
      await CharacterService.createCharacter(name: 'Aragorn', characterClass: 'Ranger');
      await CharacterService.createCharacter(name: 'Gandalf', characterClass: 'Wizard');
      await CharacterService.createCharacter(name: 'Frodo', characterClass: 'Hobbit');
      
      final characters = await CharacterService.loadAllCharacters();
      
      // Search by name
      final aragornResults = CharacterService.searchCharacters(characters, 'Aragorn');
      expect(aragornResults.length, 1);
      expect(aragornResults.first.name, 'Aragorn');
      
      // Search by class
      final wizardResults = CharacterService.searchCharacters(characters, 'Wizard');
      expect(wizardResults.length, 1);
      expect(wizardResults.first.name, 'Gandalf');
      
      // Search with no results
      final noResults = CharacterService.searchCharacters(characters, 'Sauron');
      expect(noResults.length, 0);
    });

    test('Should filter characters by class', () async {
      await CharacterService.createCharacter(name: 'Hero 1', characterClass: 'Fighter');
      await CharacterService.createCharacter(name: 'Hero 2', characterClass: 'Fighter');
      await CharacterService.createCharacter(name: 'Hero 3', characterClass: 'Wizard');
      
      final characters = await CharacterService.loadAllCharacters();
      
      final fighters = CharacterService.filterByClass(characters, 'Fighter');
      expect(fighters.length, 2);
      
      final wizards = CharacterService.filterByClass(characters, 'Wizard');
      expect(wizards.length, 1);
    });

    test('Should update character successfully', () async {
      final character = await CharacterService.createCharacter(
        name: 'Original Name',
        characterClass: 'Fighter',
      );
      
      // Update character
      final updatedCharacter = character.copyWith(
        name: 'Updated Name',
        characterClass: 'Paladin',
      );
      
      await CharacterService.saveCharacter(updatedCharacter);
      
      // Load and verify
      final characters = await CharacterService.loadAllCharacters();
      final loadedCharacter = characters.firstWhere((c) => c.id == character.id);
      
      expect(loadedCharacter.name, 'Updated Name');
      expect(loadedCharacter.characterClass, 'Paladin');
    });

    test('Should delete character successfully', () async {
      final character1 = await CharacterService.createCharacter(name: 'Hero 1', characterClass: 'Fighter');
      final character2 = await CharacterService.createCharacter(name: 'Hero 2', characterClass: 'Wizard');
      
      // Verify both characters exist
      var characters = await CharacterService.loadAllCharacters();
      expect(characters.length, 2);
      
      // Delete one character
      await CharacterService.deleteCharacter(character1.id);
      
      // Verify deletion
      characters = await CharacterService.loadAllCharacters();
      expect(characters.length, 1);
      expect(characters.first.id, character2.id);
    });

    test('Should export and import character', () async {
      final original = await CharacterService.createCharacter(
        name: 'Exported Hero',
        characterClass: 'Ranger',
        subclass: 'Hunter',
      );
      
      // Export character
      final exportedJson = CharacterService.exportCharacter(original);
      expect(exportedJson, isA<String>());
      expect(exportedJson.contains('Exported Hero'), true);
      
      // Import character
      final imported = await CharacterService.importCharacter(exportedJson);
      
      expect(imported.name, 'Exported Hero');
      expect(imported.characterClass, 'Ranger');
      expect(imported.subclass, 'Hunter');
      expect(imported.id, isNot(original.id)); // Should have new ID
    });

    test('Should get all available classes', () async {
      await CharacterService.createCharacter(name: 'Hero 1', characterClass: 'Fighter');
      await CharacterService.createCharacter(name: 'Hero 2', characterClass: 'Wizard', subclass: 'Evocation');
      await CharacterService.createCharacter(name: 'Hero 3', characterClass: 'Cleric');
      
      final characters = await CharacterService.loadAllCharacters();
      final classes = CharacterService.getAllAvailableClasses(characters);
      
      expect(classes.contains('Fighter'), true);
      expect(classes.contains('Wizard'), true);
      expect(classes.contains('Evocation'), true);
      expect(classes.contains('Cleric'), true);
      expect(classes.length, 4);
    });
  });
}
