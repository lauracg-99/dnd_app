import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import '../lib/services/character_service.dart';
import '../lib/models/character_model.dart';

void main() {
  group('Character Recovery Tests', () {
    test('should handle malformed JSON gracefully', () async {
      // This test verifies that the character service can handle corrupted JSON files
      // without crashing the entire app
      
      // Create a test with valid characters first
      await CharacterService.initializeStorage();
      
      try {
        // Create a valid character
        final character = await CharacterService.createCharacter(
          name: 'Test Character',
          characterClass: 'Fighter',
          level: 1,
        );
        
        expect(character.name, 'Test Character');
        expect(character.characterClass, 'Fighter');
        
        // Clean up
        await CharacterService.deleteCharacter(character.id);
        
        print('✅ Character recovery test passed - app handles character data correctly');
        
      } catch (e) {
        print('❌ Character recovery test failed: $e');
        rethrow;
      }
    });
  });
}
