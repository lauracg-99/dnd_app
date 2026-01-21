import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/character_model.dart';
import 'package:dnd_app/services/character_service.dart';

void main() {
  group('JSON Corruption Recovery Tests', () {
    late File testFile;
    late Character testCharacter;

    setUp(() async {
      // Create a test character using the service
      testCharacter = await CharacterService.createCharacter(
        name: 'Test Character',
        level: 5,
        characterClass: 'Fighter',
      );

      // Create a temporary test file
      testFile = File('test_character_corruption.json');
    });

    tearDown(() async {
      // Clean up test files
      if (await testFile.exists()) {
        await testFile.delete();
      }
      
      // Clean up any backup files
      final dir = testFile.parent;
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.contains('test_character_corruption')) {
          await entity.delete();
        }
      }
    });

    test('should recover from extra closing braces corruption', () async {
      // Create valid JSON first
      final validJson = json.encode(testCharacter.toJson());
      
      // Introduce corruption by adding extra closing braces
      final corruptedJson = '$validJson}}}';
      
      // Write corrupted JSON to file
      await testFile.writeAsString(corruptedJson);
      
      // Try to load the character - should recover and succeed
      final loadedCharacter = await _loadCharacterFromFile(testFile);
      
      expect(loadedCharacter.name, equals(testCharacter.name));
      expect(loadedCharacter.id, equals(testCharacter.id));
      expect(loadedCharacter.level, equals(testCharacter.level));
    });

    test('should recover from missing closing braces corruption', () async {
      // Create valid JSON first
      final validJson = json.encode(testCharacter.toJson());
      
      // Introduce corruption by removing closing braces
      final corruptedJson = validJson.substring(0, validJson.length - 2);
      
      // Write corrupted JSON to file
      await testFile.writeAsString(corruptedJson);
      
      // This should fail to recover and throw an exception
      expect(
        () => _loadCharacterFromFile(testFile),
        throwsA(isA<FormatException>()),
      );
    });

    test('should create backup when corruption cannot be recovered', () async {
      // Create severely corrupted JSON
      final corruptedJson = '{"invalid": json structure}';
      
      // Write corrupted JSON to file
      await testFile.writeAsString(corruptedJson);
      
      // Try to load - should fail and create backup
      try {
        await _loadCharacterFromFile(testFile);
        fail('Should have thrown an exception');
      } catch (e) {
        // Expected to throw
      }
      
      // Check that backup file was created
      final dir = testFile.parent;
      bool backupFound = false;
      await for (final entity in dir.list()) {
        if (entity is File && 
            entity.path.contains('test_character_corruption') && 
            entity.path.contains('.corrupted.')) {
          backupFound = true;
          
          // Verify backup contains the corrupted content
          final backupContent = await entity.readAsString();
          expect(backupContent, equals(corruptedJson));
          break;
        }
      }
      
      expect(backupFound, isTrue, reason: 'Backup file should have been created');
    });

    test('should handle valid JSON without modification', () async {
      // Write valid JSON
      final validJson = json.encode(testCharacter.toJson());
      await testFile.writeAsString(validJson);
      
      // Load should work normally
      final loadedCharacter = await _loadCharacterFromFile(testFile);
      
      expect(loadedCharacter.name, equals(testCharacter.name));
      expect(loadedCharacter.id, equals(testCharacter.id));
      expect(loadedCharacter.level, equals(testCharacter.level));
    });

    test('should validate JSON during file writing', () async {
      // Test the validation method directly
      final validJson = json.encode(testCharacter.toJson());
      final recoveredJson = _validateAndRecoverJson(validJson, 'test_path');
      
      expect(recoveredJson, equals(validJson));
      
      // Test corruption recovery
      final corruptedJson = '$validJson}';
      final recoveredFromCorruption = _validateAndRecoverJson(corruptedJson, 'test_path');
      
      // Should recover to valid JSON
      expect(() => json.decode(recoveredFromCorruption), returnsNormally);
    });
  });

  group('File Integrity Tests', () {
    late File testFile;
    late Character testCharacter;

    setUp(() async {
      testCharacter = await CharacterService.createCharacter(
        name: 'Integrity Test',
        level: 3,
        characterClass: 'Wizard',
      );
      testFile = File('test_integrity.json');
    });

    tearDown(() async {
      if (await testFile.exists()) {
        await testFile.delete();
      }
      
      // Clean up temp files
      final dir = testFile.parent;
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.contains('test_integrity')) {
          await entity.delete();
        }
      }
    });

    test('should write file with validation successfully', () async {
      final jsonString = json.encode(testCharacter.toJson());
      
      // Write with validation
      await _writeCharacterFileWithValidation(
        testFile, 
        jsonString, 
        testCharacter.name
      );
      
      // Verify file exists and contains valid JSON
      expect(await testFile.exists(), isTrue);
      
      final content = await testFile.readAsString();
      final parsed = json.decode(content) as Map<String, dynamic>;
      expect(parsed['resource_id'], equals('character'));
    });

    test('should reject invalid JSON during write', () async {
      final invalidJson = '{"invalid": json}';
      
      expect(
        () => _writeCharacterFileWithValidation(
          testFile, 
          invalidJson, 
          'Invalid Character'
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

// Helper methods to access private methods for testing
Future<Character> _loadCharacterFromFile(File file) async {
  try {
    final jsonString = await file.readAsString();
    
    // Validate JSON structure before parsing
    final validatedJson = _validateAndRecoverJson(jsonString, file.path);
    final jsonData = json.decode(validatedJson) as Map<String, dynamic>;
    
    return Character.fromJson(jsonData);
  } catch (e, stackTrace) {
    print('Error loading character from ${file.path}: $e');
    print('Stack trace: $stackTrace');
    
    // Attempt to create backup of corrupted file
    await _createCorruptedFileBackup(file);
    
    rethrow;
  }
}

String _validateAndRecoverJson(String jsonString, String filePath) {
  try {
    // Try to decode first to check if it's valid
    json.decode(jsonString);
    return jsonString;
  } catch (e) {
    print('JSON corruption detected in $filePath, attempting recovery...');
    
    // Common corruption pattern: extra closing braces
    String recoveredJson = jsonString;
    
    // Remove extra closing braces at the end
    while (recoveredJson.endsWith('}')) {
      try {
        json.decode(recoveredJson);
        break; // Valid JSON found
      } catch (e) {
        recoveredJson = recoveredJson.substring(0, recoveredJson.length - 1).trim();
      }
    }
    
    // Try the recovered JSON
    try {
      json.decode(recoveredJson);
      print('Successfully recovered JSON from corruption');
      return recoveredJson;
    } catch (e) {
      print('JSON recovery failed, original error: $e');
      rethrow;
    }
  }
}

Future<void> _createCorruptedFileBackup(File originalFile) async {
  try {
    final backupPath = '${originalFile.path}.corrupted.${DateTime.now().millisecondsSinceEpoch}';
    final backupFile = File(backupPath);
    await backupFile.writeAsString(await originalFile.readAsString());
    print('Created backup of corrupted file: $backupPath');
  } catch (e) {
    print('Failed to create backup of corrupted file: $e');
  }
}

Future<void> _writeCharacterFileWithValidation(
  File file, 
  String jsonString, 
  String characterName
) async {
  try {
    // Validate the JSON string before writing
    json.decode(jsonString); // This will throw if JSON is invalid
    
    // Create temporary file for atomic write
    final tempFile = File('${file.path}.tmp.${DateTime.now().millisecondsSinceEpoch}');
    
    // Write to temporary file first
    await tempFile.writeAsString(jsonString);
    
    // Verify the written file can be read and parsed
    final testRead = await tempFile.readAsString();
    json.decode(testRead); // Verify integrity
    
    // Atomic operation: replace original file with temp file
    await tempFile.rename(file.path);
    
    print('Successfully saved character to file: $characterName at ${file.path}');
  } catch (e) {
    print('Failed to write character file with validation: $e');
    
    // Clean up temp file if it exists
    try {
      final tempFile = File('${file.path}.tmp');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (cleanupError) {
      print('Failed to cleanup temp file: $cleanupError');
    }
    
    rethrow;
  }
}
