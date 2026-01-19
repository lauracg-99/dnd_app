import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/character_model.dart';

// Conditional import for path_provider
import 'package:path_provider/path_provider.dart' if (dart.library.io) 'package:path_provider/path_provider.dart';

class CharacterService {
  static const String _charactersDirName = 'characters';
  static List<Character> _memoryCache = [];
  static bool _useMemoryStorage = false;
  
  /// Initialize storage system
  static Future<void> initializeStorage() async {
    try {
      if (kIsWeb) {
        _useMemoryStorage = true;
        debugPrint('Web platform detected, using memory-only storage');
        return;
      }
      
      // Test if file operations work
      final testDir = Directory.systemTemp;
      final testFile = File('${testDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.tmp');
      
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
        _useMemoryStorage = false;
        debugPrint('File system operations available, using file storage');
      } catch (e) {
        _useMemoryStorage = true;
        debugPrint('File system operations failed, using memory storage: $e');
      }
    } catch (e) {
      _useMemoryStorage = true;
      debugPrint('Storage initialization failed, using memory storage: $e');
    }
  }
  
  /// Get the directory where character files are stored
  static Future<Directory> _getCharactersDirectory() async {
    if (_useMemoryStorage) {
      throw Exception('Memory storage in use');
    }
    
    try {
      // Try to get the application documents directory first (mobile/desktop)
      final appDir = await getApplicationDocumentsDirectory();
      final charactersDir = Directory('${appDir.path}/$_charactersDirName');
      
      // Create directory if it doesn't exist
      if (!await charactersDir.exists()) {
        await charactersDir.create(recursive: true);
        debugPrint('Created characters directory: ${charactersDir.path}');
      }
      
      debugPrint('Using documents directory for character storage: ${charactersDir.path}');
      return charactersDir;
    } catch (e) {
      debugPrint('Documents directory failed, falling back to temp: $e');
      // Fallback to temporary directory
      final tempDir = Directory.systemTemp;
      final charactersDir = Directory('${tempDir.path}/$_charactersDirName');
      
      try {
        if (!await charactersDir.exists()) {
          await charactersDir.create(recursive: true);
        }
        debugPrint('Using temp directory for character storage: ${charactersDir.path}');
        return charactersDir;
      } catch (fallbackError) {
        debugPrint('Temp directory also failed: $fallbackError');
        // Switch to memory storage
        _useMemoryStorage = true;
        throw Exception('All directory options failed, switching to memory storage');
      }
    }
  }
  
  /// Get the file path for a specific character
  static Future<File> _getCharacterFile(String characterId) async {
    final dir = await _getCharactersDirectory();
    // Sanitize character ID to avoid file system issues
    final sanitizedId = characterId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return File('${dir.path}/character_$sanitizedId.json');
  }
  
  /// Save a character to local storage
  static Future<void> saveCharacter(Character character) async {
    try {
      // Initialize storage if not already done
      if (!_useMemoryStorage && kIsWeb) {
        await initializeStorage();
      }
      
      // Update the updatedAt timestamp
      final updatedCharacter = character.copyWith(
        updatedAt: DateTime.now(),
      );
      
      if (_useMemoryStorage) {
        // Memory-based storage
        final index = _memoryCache.indexWhere((c) => c.id == updatedCharacter.id);
        if (index != -1) {
          _memoryCache[index] = updatedCharacter;
        } else {
          _memoryCache.add(updatedCharacter);
        }
        debugPrint('Saved character to memory storage: ${updatedCharacter.name}');
      } else {
        // File-based storage
        final jsonString = json.encode(updatedCharacter.toJson());
        final file = await _getCharacterFile(updatedCharacter.id);
        await file.writeAsString(jsonString);
        debugPrint('Successfully saved character to file: ${updatedCharacter.name} at ${file.path}');
        
        // Update memory cache
        final index = _memoryCache.indexWhere((c) => c.id == updatedCharacter.id);
        if (index != -1) {
          _memoryCache[index] = updatedCharacter;
        } else {
          _memoryCache.add(updatedCharacter);
        }
      }
      
      debugPrint('Character saved to memory cache: ${updatedCharacter.name}');
    } catch (e) {
      debugPrint('Error saving character ${character.name}: $e');
      
      // Fallback to memory storage
      if (!_useMemoryStorage) {
        debugPrint('Falling back to memory storage due to error');
        _useMemoryStorage = true;
        await saveCharacter(character);
        return;
      }
      
      // Still update memory cache even if everything else fails
      final index = _memoryCache.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        _memoryCache[index] = character;
      } else {
        _memoryCache.add(character);
      }
      rethrow; // Re-throw to let the caller know there was an issue
    }
  }
  
  /// Load all characters from local storage
  static Future<List<Character>> loadAllCharacters() async {
    try {
      // Initialize storage if not already done
      if (!_useMemoryStorage && kIsWeb) {
        await initializeStorage();
      }
      
      List<Character> characters = [];
      
      if (_useMemoryStorage) {
        // Memory-based storage
        characters = List.from(_memoryCache);
        debugPrint('Loaded ${characters.length} characters from memory storage');
      } else {
        // File-based storage
        final dir = await _getCharactersDirectory();
        
        if (!await dir.exists()) {
          debugPrint('Characters directory does not exist, returning empty list');
          return [];
        }
        
        // Use a simpler approach to list files
        List<File> characterFiles = [];
        try {
          await for (final entity in dir.list()) {
            if (entity is File && 
                entity.path.endsWith('.json') &&
                entity.path.contains('character_')) {
              characterFiles.add(entity);
            }
          }
        } catch (e) {
          debugPrint('Error listing files: $e');
          debugPrint('Falling back to memory storage');
          _useMemoryStorage = true;
          return List.from(_memoryCache);
        }
        
        for (final file in characterFiles) {
          try {
            debugPrint('Loading character from: ${file.path}');
            final character = await _loadCharacterFromFile(file);
            characters.add(character);
            debugPrint('Successfully loaded character: ${character.name}');
          } catch (e) {
            debugPrint('Error loading character from ${file.path}: $e');
          }
        }
        
        // Update memory cache with loaded characters
        _memoryCache = List.from(characters);
      }
      
      // Sort characters by name
      characters.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      debugPrint('Loaded ${characters.length} characters from storage');
      return characters;
    } catch (e) {
      debugPrint('Error loading characters: $e');
      
      // Fallback to memory storage
      if (!_useMemoryStorage) {
        debugPrint('Falling back to memory storage due to error');
        _useMemoryStorage = true;
        return List.from(_memoryCache);
      }
      
      // Return memory cache as final fallback
      return List.from(_memoryCache);
    }
  }
  
  /// Load a single character from a file
  static Future<Character> _loadCharacterFromFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      return Character.fromJson(jsonData);
    } catch (e, stackTrace) {
      debugPrint('Error loading character from ${file.path}: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Create a new character
  static Future<Character> createCharacter({
    required String name,
    String characterClass = 'Fighter',
    String? subclass,
  }) async {
    final now = DateTime.now();
    final characterId = '${name.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}';
    
    // Create default character with basic stats
    final defaultStats = CharacterStats(
      strength: 10,
      dexterity: 10,
      constitution: 10,
      intelligence: 10,
      wisdom: 10,
      charisma: 10,
    );
    
    final defaultSavingThrows = CharacterSavingThrows();
    final defaultSkillChecks = CharacterSkillChecks();
    final defaultHealth = CharacterHealth(maxHitPoints: 10, currentHitPoints: 10);
    final defaultSpellSlots = CharacterSpellSlots();
    final defaultPillars = CharacterPillars();
    
    final character = Character(
      id: characterId,
      name: name,
      stats: defaultStats,
      savingThrows: defaultSavingThrows,
      skillChecks: defaultSkillChecks,
      health: defaultHealth,
      characterClass: characterClass,
      subclass: subclass,
      spellSlots: defaultSpellSlots,
      pillars: defaultPillars,
      createdAt: now,
      updatedAt: now,
    );
    
    await saveCharacter(character);
    return character;
  }
  
  /// Delete a character
  static Future<void> deleteCharacter(String characterId) async {
    try {
      // Initialize storage if not already done
      if (!_useMemoryStorage && kIsWeb) {
        await initializeStorage();
      }
      
      if (_useMemoryStorage) {
        // Memory-based deletion
        _memoryCache.removeWhere((c) => c.id == characterId);
        debugPrint('Deleted character from memory storage: $characterId');
      } else {
        // File-based deletion
        final file = await _getCharacterFile(characterId);
        
        // Delete file if it exists
        if (await file.exists()) {
          await file.delete();
          debugPrint('Successfully deleted character file: ${file.path}');
        } else {
          debugPrint('Character file not found for ID: $characterId');
        }
        
        // Remove from memory cache
        _memoryCache.removeWhere((c) => c.id == characterId);
      }
      
      debugPrint('Character removed from memory cache: $characterId');
    } catch (e) {
      debugPrint('Error deleting character $characterId: $e');
      
      // Fallback to memory storage
      if (!_useMemoryStorage) {
        debugPrint('Falling back to memory storage for deletion');
        _useMemoryStorage = true;
        await deleteCharacter(characterId);
        return;
      }
      
      // Still remove from memory cache even if file deletion fails
      _memoryCache.removeWhere((c) => c.id == characterId);
      rethrow; // Re-throw to let the caller know there was an issue
    }
  }
  
  /// Clear the memory cache (useful for testing or forcing refresh)
  static void clearMemoryCache() {
    _memoryCache.clear();
    debugPrint('Memory cache cleared');
  }

  /// Search characters by name or class
  static List<Character> searchCharacters(List<Character> characters, String query) {
    if (query.isEmpty) return characters;
    
    final lowerQuery = query.toLowerCase();
    return characters.where((character) {
      return character.name.toLowerCase().contains(lowerQuery) ||
             character.characterClass.toLowerCase().contains(lowerQuery) ||
             (character.subclass?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
  
  /// Filter characters by class
  static List<Character> filterByClass(List<Character> characters, String className) {
    if (className.isEmpty) return characters;
    return characters.where((character) => 
      character.characterClass.toLowerCase() == className.toLowerCase()
    ).toList();
  }
  
  /// Get all unique classes from all characters
  static Set<String> getAllAvailableClasses(List<Character> characters) {
    final classes = <String>{};
    for (final character in characters) {
      classes.add(character.characterClass);
      if (character.subclass != null) {
        classes.add(character.subclass!);
      }
    }
    return classes;
  }
  
  /// Export character to JSON string (for sharing/backup)
  static String exportCharacter(Character character) {
    return json.encode(character.toJson());
  }
  
  /// Import character from JSON string
  static Future<Character> importCharacter(String jsonString) async {
    try {
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final character = Character.fromJson(jsonData);
      
      // Generate a new ID to avoid conflicts
      final now = DateTime.now();
      final newId = '${character.name.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}';
      final importedCharacter = character.copyWith(
        id: newId,
        createdAt: now,
        updatedAt: now,
      );
      
      await saveCharacter(importedCharacter);
      return importedCharacter;
    } catch (e) {
      debugPrint('Error importing character: $e');
      rethrow;
    }
  }
  
  /// Debug method to check character storage
  static Future<void> debugCheckCharacterStorage() async {
    try {
      final dir = await _getCharactersDirectory();
      final files = await dir.list().toList();
      
      debugPrint('\n=== Character Storage Debug Report ===');
      debugPrint('Characters directory: ${dir.path}');
      debugPrint('Directory exists: ${await dir.exists()}');
      debugPrint('Total files: ${files.length}');
      debugPrint('Memory cache size: ${_memoryCache.length}');
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          debugPrint('Character file: ${file.path}');
        }
      }
      
      final characters = await loadAllCharacters();
      debugPrint('Loaded characters: ${characters.length}');
      
      for (final character in characters) {
        debugPrint('Character: ${character.name} (${character.characterClass})');
      }
      
      debugPrint('=====================================\n');
      
    } catch (e) {
      debugPrint('Error checking character storage: $e');
    }
  }
}
