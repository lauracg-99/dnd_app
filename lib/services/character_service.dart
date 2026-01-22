import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/character_model.dart';

// Conditional import for path_provider
import 'package:path_provider/path_provider.dart';


class CharacterService {
  static const String _charactersDirName = 'characters';
  static List<Character> _memoryCache = [];
  static bool _useMemoryStorage = false;
  static bool get _isIOSRelease =>
    !kIsWeb && Platform.isIOS && kReleaseMode;

  
  /// Initialize storage system
  static bool _initialized = false;

  static Future<void> initializeStorage() async {
    if (kIsWeb) {
      _useMemoryStorage = true;
      _initialized = true;
      return;
    }


    final dir = await getApplicationDocumentsDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    _useMemoryStorage = false;
    _initialized = true;
  }

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await initializeStorage();
  }


  
  /// Get the directory where character files are stored
  static Future<Directory> _getCharactersDirectory() async {
    await ensureInitialized();

    if (_useMemoryStorage) {
      throw StateError('Filesystem access while using memory storage');
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
        _useMemoryStorage = true;
        throw Exception('Failed to access documents directory');
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
    await ensureInitialized();
    try {
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
        // File-based storage with integrity validation
        final jsonString = json.encode(updatedCharacter.toJson());
        final file = await _getCharacterFile(updatedCharacter.id);
        
        // Validate JSON before writing
        await _writeCharacterFileWithValidation(file, jsonString, updatedCharacter.name);
        
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
      
      if (_isIOSRelease) {
        rethrow; // NO caer a memoria en iOS release
      }
      if (_useMemoryStorage) {
        rethrow; // ⬅️ evita recursión infinita
      }
    // Solo fallback en debug / Android
      _useMemoryStorage = true;
      await saveCharacter(character);
    }
  }
  
  /// Load all characters from local storage
  static Future<List<Character>> loadAllCharacters() async {
    try {
      // Initialize storage if not already done
      await ensureInitialized();
      
      List<Character> characters = [];
      
      if (_useMemoryStorage) {
        // Memory-based storage
        characters = List.from(_memoryCache);
        debugPrint('Loaded ${characters.length} characters from memory storage');
      } else {
        _memoryCache.clear();
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
          if (_isIOSRelease) {
            rethrow; // no ocultar errores en iOS
          }
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

        if (_isIOSRelease) {
          rethrow;
        }

        _useMemoryStorage = true;
        return List.from(_memoryCache);
    }
  }
  
  /// Load a single character from a file
  static Future<Character> _loadCharacterFromFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      
      // Validate JSON structure before parsing
      final validatedJson = _validateAndRecoverJson(jsonString, file.path);
      final jsonData = json.decode(validatedJson) as Map<String, dynamic>;
      
      return Character.fromJson(jsonData);
    } catch (e, stackTrace) {
      debugPrint('Error loading character from ${file.path}: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Attempt to create backup of corrupted file
      await _createCorruptedFileBackup(file);
      
      rethrow;
    }
  }

  /// Validate and attempt to recover from JSON corruption
  static String _validateAndRecoverJson(String jsonString, String filePath) {
    try {
      // Try to decode first to check if it's valid
      json.decode(jsonString);
      return jsonString;
    } catch (e) {
      debugPrint('JSON corruption detected in $filePath, attempting recovery...');
      
      // Common corruption pattern: extra closing braces
      String recoveredJson = jsonString;
      
      // Remove extra closing braces at the end
      int attempts = 3;
      while (attempts-- > 0 && recoveredJson.endsWith('}')) {
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
        debugPrint('Successfully recovered JSON from corruption');
        return recoveredJson;
      } catch (e) {
        debugPrint('JSON recovery failed, original error: $e');
        rethrow;
      }
    }
  }

  /// Create backup of corrupted file for debugging
  static Future<void> _createCorruptedFileBackup(File originalFile) async {
    try {
      final backupPath = '${originalFile.path}.corrupted.${DateTime.now().millisecondsSinceEpoch}';
      final backupFile = File(backupPath);
      await backupFile.writeAsString(
        await originalFile.readAsString(),
        flush: true,
      );

      debugPrint('Created backup of corrupted file: $backupPath');
    } catch (e) {
      debugPrint('Failed to create backup of corrupted file: $e');
    }
  }

  /// Write character file with validation and atomic operation
  static Future<void> _writeCharacterFileWithValidation(
    File file, 
    String jsonString, 
    String characterName
  ) async {
    String? tempPath;
    try {
      // Validate the JSON string before writing
      json.decode(jsonString); // This will throw if JSON is invalid
      
      // Create temporary file for atomic write
      tempPath = '${file.path}.tmp.${DateTime.now().millisecondsSinceEpoch}';
      final tempFile = File(tempPath);

      // Write to temporary file first
      await tempFile.writeAsString(jsonString, flush: true);

      if (await file.exists()) {
        await file.delete();
      }

      await tempFile.copy(file.path);
      await tempFile.delete();
      await file.stat();
            
      debugPrint('Successfully saved character to file: $characterName at ${file.path}');
    } catch (e) {
      if (tempPath != null) {
          final tempFile = File(tempPath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
        rethrow;
    }
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
    try {
      // Initialize storage if not already done
      await ensureInitialized();
      
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
      if (_isIOSRelease) {
        rethrow;
      }

      _useMemoryStorage = true;

      // Still remove from memory cache even if file deletion fails
      _memoryCache.removeWhere((c) => c.id == characterId);
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
    if (_useMemoryStorage) {
      debugPrint('\n=== Character Storage Debug Report ===');
      debugPrint('Using memory storage');
      debugPrint('Memory cache size: ${_memoryCache.length}');
      debugPrint('=====================================\n');
      return;
    }
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
