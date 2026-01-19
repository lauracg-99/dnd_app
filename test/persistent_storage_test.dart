import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/services/character_service.dart';
import 'package:dnd_app/models/character_model.dart';

void main() {
  group('Persistent Storage Tests', () {
    setUp(() {
      // Clear memory cache before each test
      CharacterService.clearMemoryCache();
    });

    test('Should save character to persistent storage', () async {
      // Create a character
      final character = await CharacterService.createCharacter(
        name: 'Persistent Test Character',
        characterClass: 'Wizard',
        subclass: 'Evocation',
      );

      // Verify character was created
      expect(character.name, 'Persistent Test Character');
      expect(character.characterClass, 'Wizard');
      expect(character.subclass, 'Evocation');

      // Clear memory cache to simulate app restart
      CharacterService.clearMemoryCache();

      // Load characters from storage
      final loadedCharacters = await CharacterService.loadAllCharacters();

      // Verify character persists after cache clear
      expect(loadedCharacters.length, 1);
      expect(loadedCharacters.first.name, 'Persistent Test Character');
      expect(loadedCharacters.first.characterClass, 'Wizard');
      expect(loadedCharacters.first.subclass, 'Evocation');
    });

    test('Should maintain multiple characters across restarts', () async {
      // Create multiple characters
      await CharacterService.createCharacter(name: 'Character 1', characterClass: 'Fighter');
      await CharacterService.createCharacter(name: 'Character 2', characterClass: 'Rogue');
      await CharacterService.createCharacter(name: 'Character 3', characterClass: 'Cleric');

      // Clear memory cache to simulate app restart
      CharacterService.clearMemoryCache();

      // Load characters from storage
      final loadedCharacters = await CharacterService.loadAllCharacters();

      // Verify all characters persist
      expect(loadedCharacters.length, 3);
      expect(loadedCharacters.any((c) => c.name == 'Character 1'), true);
      expect(loadedCharacters.any((c) => c.name == 'Character 2'), true);
      expect(loadedCharacters.any((c) => c.name == 'Character 3'), true);
    });

    test('Should handle character deletion permanently', () async {
      // Create characters
      final char1 = await CharacterService.createCharacter(name: 'To Delete', characterClass: 'Fighter');
      final char2 = await CharacterService.createCharacter(name: 'To Keep', characterClass: 'Wizard');

      // Verify both exist
      var characters = await CharacterService.loadAllCharacters();
      expect(characters.length, 2);

      // Delete one character
      await CharacterService.deleteCharacter(char1.id);

      // Clear cache and reload
      CharacterService.clearMemoryCache();
      characters = await CharacterService.loadAllCharacters();

      // Verify deletion persists
      expect(characters.length, 1);
      expect(characters.first.name, 'To Keep');
      expect(characters.any((c) => c.id == char1.id), false);
    });

    test('Should handle character updates permanently', () async {
      // Create character
      final original = await CharacterService.createCharacter(
        name: 'Original Name',
        characterClass: 'Fighter',
      );

      // Update character
      final updated = original.copyWith(
        name: 'Updated Name',
        characterClass: 'Paladin',
      );
      await CharacterService.saveCharacter(updated);

      // Clear cache and reload
      CharacterService.clearMemoryCache();
      final characters = await CharacterService.loadAllCharacters();

      // Verify update persists
      expect(characters.length, 1);
      expect(characters.first.name, 'Updated Name');
      expect(characters.first.characterClass, 'Paladin');
    });
  });
}
