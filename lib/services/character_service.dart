import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/character_model.dart';
import 'character_storage_service.dart';

class CharacterService {
  static final _storage = CharacterStorageService();
  
  /// Initialize storage system
  static Future<void> initializeStorage() async {
    await _storage.initializeStorage();
  }

  static Future<void> ensureInitialized() async {
    await _storage.ensureInitialized();
  }
  
  /// Save a character to local storage
  static Future<void> saveCharacter(Character character) async {
    await _storage.save(character);
  }
  
  /// Load all characters from local storage
  static Future<List<Character>> loadAllCharacters() async {
    return await _storage.loadAll();
  }
  
  /// Create a new character
  static Future<Character> createCharacter({
    required String name,
    int level = 1,
    String characterClass = 'Fighter',
    String? subclass,
    String? race,
    String? background,
  }) async {
    final now = DateTime.now();
    final characterId = '${name.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}';
    
    // Validate level is within D&D 5e bounds (1-20)
    if (level < 1 || level > 20) {
      throw ArgumentError('Character level must be between 1 and 20');
    }
    
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
    final defaultAppearance = CharacterAppearance();
    final defaultDeathSaves = CharacterDeathSaves();
    final defaultLanguages = CharacterLanguages();
    final defaultMoneyItems = CharacterMoneyItems();
    
    final character = Character(
      id: characterId,
      name: name,
      stats: defaultStats,
      savingThrows: defaultSavingThrows,
      skillChecks: defaultSkillChecks,
      health: defaultHealth,
      characterClass: characterClass,
      level: level, // Use provided level instead of defaulting to 1
      subclass: subclass,
      race: race,
      background: background,
      spellSlots: defaultSpellSlots,
      pillars: defaultPillars,
      appearance: defaultAppearance,
      deathSaves: defaultDeathSaves,
      languages: defaultLanguages,
      moneyItems: defaultMoneyItems,
      createdAt: now,
      updatedAt: now,
    );
    
    await saveCharacter(character);
    return character;
  }
  
  /// Delete a character
  static Future<void> deleteCharacter(String characterId) async {
    await _storage.delete(characterId);
  }
  
  /// Clear the memory cache (useful for testing or forcing refresh)
  static void clearMemoryCache() {
    _storage.clearMemoryCache();
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
      final dir = await _storage.getDirectory();
      final files = await dir.list().toList();
      
      debugPrint('\n=== Character Storage Debug Report ===');
      debugPrint('Characters directory: ${dir.path}');
      debugPrint('Directory exists: ${await dir.exists()}');
      debugPrint('Total files: ${files.length}');
      
      for (final file in files) {
        if (file.path.endsWith('.json')) {
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
