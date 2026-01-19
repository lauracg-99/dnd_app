import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/character_model.dart';

class CharacterService {
  static const String _charactersDirName = 'characters';
  static List<Character> _memoryCache = [];
  
  /// Get the directory where character files are stored
  static Future<Directory> _getCharactersDirectory() async {
    try {
      // Use temporary directory as fallback when path_provider is not available
      debugPrint('Using temporary directory for character storage');
      final tempDir = Directory.systemTemp;
      final charactersDir = Directory('${tempDir.path}/$_charactersDirName');
      
      // Create directory if it doesn't exist - use a simpler approach
      try {
        if (!await charactersDir.exists()) {
          await charactersDir.create();
        }
      } catch (e) {
        debugPrint('Directory creation failed, using temp directory directly: $e');
        return tempDir; // Fallback to temp directory itself
      }
      
      return charactersDir;
    } catch (e) {
      debugPrint('Error getting characters directory: $e');
      // Final fallback - use system temp directly
      return Directory.systemTemp;
    }
  }
  
  /// Get the file path for a specific character
  static Future<File> _getCharacterFile(String characterId) async {
    final dir = await _getCharactersDirectory();
    // Sanitize character ID to avoid file system issues
    final sanitizedId = characterId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return File('${dir.path}/character_${sanitizedId}.json');
  }
  
  /// Load all characters from local storage
  static Future<List<Character>> loadAllCharacters() async {
    try {
      // If we have memory cache and it's not empty, return it
      if (_memoryCache.isNotEmpty) {
        return List.from(_memoryCache);
      }
      
      final dir = await _getCharactersDirectory();
      
      if (!await dir.exists()) {
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
        return List.from(_memoryCache); // Return cache if listing fails
      }
      
      final List<Character> characters = [];
      
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
      
      // Sort characters by name
      characters.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      // Update memory cache
      _memoryCache = List.from(characters);
      
      return characters;
    } catch (e) {
      debugPrint('Error loading characters: $e');
      // Return memory cache as fallback
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
  
  /// Save a character to local storage
  static Future<void> saveCharacter(Character character) async {
    try {
      final file = await _getCharacterFile(character.id);
      
      // Update the updatedAt timestamp
      final updatedCharacter = character.copyWith(
        updatedAt: DateTime.now(),
      );
      
      final jsonString = json.encode(updatedCharacter.toJson());
      
      // Try to write to file, but don't fail if it doesn't work
      try {
        await file.writeAsString(jsonString);
        debugPrint('Successfully saved character to file: ${updatedCharacter.name}');
      } catch (e) {
        debugPrint('Failed to save character to file, using memory cache only: $e');
      }
      
      // Always update memory cache
      final index = _memoryCache.indexWhere((c) => c.id == updatedCharacter.id);
      if (index != -1) {
        _memoryCache[index] = updatedCharacter;
      } else {
        _memoryCache.add(updatedCharacter);
      }
      
      debugPrint('Character saved to memory cache: ${updatedCharacter.name}');
    } catch (e) {
      debugPrint('Error saving character ${character.name}: $e');
      // Still update memory cache even if everything else fails
      final index = _memoryCache.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        _memoryCache[index] = character;
      } else {
        _memoryCache.add(character);
      }
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
      final file = await _getCharacterFile(characterId);
      
      // Try to delete file, but don't fail if it doesn't work
      try {
        if (await file.exists()) {
          await file.delete();
          debugPrint('Successfully deleted character file with ID: $characterId');
        } else {
          debugPrint('Character file not found for ID: $characterId');
        }
      } catch (e) {
        debugPrint('Failed to delete character file, removing from memory cache only: $e');
      }
      
      // Always remove from memory cache
      _memoryCache.removeWhere((c) => c.id == characterId);
      debugPrint('Character removed from memory cache: $characterId');
    } catch (e) {
      debugPrint('Error deleting character $characterId: $e');
      // Still remove from memory cache even if file deletion fails
      _memoryCache.removeWhere((c) => c.id == characterId);
    }
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
  
  /// Clear memory cache (useful for testing)
  static void clearMemoryCache() {
    _memoryCache.clear();
  }
}
