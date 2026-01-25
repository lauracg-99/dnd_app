import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/services/character_service.dart';
import '../lib/services/cloud_sync_service.dart';
import '../lib/services/firebase_auth_service.dart';
import '../lib/models/character_model.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Character Deletion Tests', () {
    setUp(() async {
      // Initialize storage for tests
      await CharacterService.initializeStorage();
      CharacterService.clearMemoryCache();
    });

    test('should delete character locally without authentication', () async {
      // Create a test character
      final character = await CharacterService.createCharacter(
        name: 'Test Character',
        level: 5,
        characterClass: 'Fighter',
      );

      // Verify character exists
      final charactersBefore = await CharacterService.loadAllCharacters();
      expect(charactersBefore.any((c) => c.id == character.id), isTrue);

      // Delete the character
      await CharacterService.deleteCharacter(character.id);

      // Verify character is deleted locally
      final charactersAfter = await CharacterService.loadAllCharacters();
      expect(charactersAfter.any((c) => c.id == character.id), isFalse);
    });

    test('should handle deletion of non-existent character gracefully', () async {
      // Try to delete a character that doesn't exist
      expect(
        () async => await CharacterService.deleteCharacter('non_existent_id'),
        returnsNormally,
      );
    });

    test('should clear character from memory cache', () async {
      // Create a test character
      final character = await CharacterService.createCharacter(
        name: 'Test Character',
        level: 3,
        characterClass: 'Wizard',
      );

      // Verify character is in memory cache
      final charactersBefore = await CharacterService.loadAllCharacters();
      expect(charactersBefore.any((c) => c.id == character.id), isTrue);

      // Delete the character
      await CharacterService.deleteCharacter(character.id);

      // Verify character is removed from memory cache
      final charactersAfter = await CharacterService.loadAllCharacters();
      expect(charactersAfter.any((c) => c.id == character.id), isFalse);
    });

    test('should not fail when cloud deletion fails', () async {
      // Create a test character
      final character = await CharacterService.createCharacter(
        name: 'Test Character',
        level: 2,
        characterClass: 'Rogue',
      );

      // Verify character exists
      final charactersBefore = await CharacterService.loadAllCharacters();
      expect(charactersBefore.any((c) => c.id == character.id), isTrue);

      // Delete the character (cloud deletion might fail if not authenticated)
      await CharacterService.deleteCharacter(character.id);

      // Local deletion should still work even if cloud deletion fails
      final charactersAfter = await CharacterService.loadAllCharacters();
      expect(charactersAfter.any((c) => c.id == character.id), isFalse);
    });

    test('should handle multiple character deletions', () async {
      // Create multiple test characters
      final character1 = await CharacterService.createCharacter(
        name: 'Test Character 1',
        level: 1,
        characterClass: 'Fighter',
      );

      final character2 = await CharacterService.createCharacter(
        name: 'Test Character 2',
        level: 2,
        characterClass: 'Wizard',
      );

      final character3 = await CharacterService.createCharacter(
        name: 'Test Character 3',
        level: 3,
        characterClass: 'Rogue',
      );

      // Verify all characters exist
      var characters = await CharacterService.loadAllCharacters();
      expect(characters.length, greaterThanOrEqualTo(3));
      expect(characters.any((c) => c.id == character1.id), isTrue);
      expect(characters.any((c) => c.id == character2.id), isTrue);
      expect(characters.any((c) => c.id == character3.id), isTrue);

      // Delete characters one by one
      await CharacterService.deleteCharacter(character1.id);
      characters = await CharacterService.loadAllCharacters();
      expect(characters.any((c) => c.id == character1.id), isFalse);
      expect(characters.any((c) => c.id == character2.id), isTrue);
      expect(characters.any((c) => c.id == character3.id), isTrue);

      await CharacterService.deleteCharacter(character2.id);
      characters = await CharacterService.loadAllCharacters();
      expect(characters.any((c) => c.id == character1.id), isFalse);
      expect(characters.any((c) => c.id == character2.id), isFalse);
      expect(characters.any((c) => c.id == character3.id), isTrue);

      await CharacterService.deleteCharacter(character3.id);
      characters = await CharacterService.loadAllCharacters();
      expect(characters.any((c) => c.id == character1.id), isFalse);
      expect(characters.any((c) => c.id == character2.id), isFalse);
      expect(characters.any((c) => c.id == character3.id), isFalse);
    });
  });
}
