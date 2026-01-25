import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/diary_model.dart';

// Conditional import for path_provider
import 'package:path_provider/path_provider.dart' if (dart.library.io) 'package:path_provider/path_provider.dart';

// Import Firebase services
import 'cloud_sync_service.dart';

class DiaryService {
  static const String _diariesDirName = 'diaries';
  static List<DiaryEntry> _memoryCache = [];
  static bool _useMemoryStorage = false;
  
  /// Initialize storage system
  static Future<void> initializeStorage() async {
    try {
      if (kIsWeb) {
        _useMemoryStorage = true;
        debugPrint('Web platform detected, using memory-only storage for diaries');
        return;
      }
      
      // Test if file operations work
      final testDir = Directory.systemTemp;
      final testFile = File('${testDir.path}/test_diary_${DateTime.now().millisecondsSinceEpoch}.tmp');
      
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
        _useMemoryStorage = false;
        debugPrint('File system operations available, using file storage for diaries');
      } catch (e) {
        _useMemoryStorage = true;
        debugPrint('File system operations failed, using memory storage for diaries: $e');
      }
    } catch (e) {
      _useMemoryStorage = true;
      debugPrint('Diary storage initialization failed, using memory storage: $e');
    }
  }
  
  /// Get the directory where diary files are stored
  static Future<Directory> _getDiariesDirectory() async {
    if (_useMemoryStorage) {
      throw Exception('Memory storage in use for diaries');
    }
    
    try {
      // Try to get the application documents directory first (mobile/desktop)
      final appDir = await getApplicationDocumentsDirectory();
      final diariesDir = Directory('${appDir.path}/$_diariesDirName');
      
      // Create directory if it doesn't exist
      if (!await diariesDir.exists()) {
        await diariesDir.create(recursive: true);
        debugPrint('Created diaries directory: ${diariesDir.path}');
      }
      
      debugPrint('Using documents directory for diary storage: ${diariesDir.path}');
      return diariesDir;
    } catch (e) {
      debugPrint('Documents directory failed for diaries, falling back to temp: $e');
      // Fallback to temporary directory
      final tempDir = Directory.systemTemp;
      final diariesDir = Directory('${tempDir.path}/$_diariesDirName');
      
      try {
        if (!await diariesDir.exists()) {
          await diariesDir.create(recursive: true);
        }
        debugPrint('Using temp directory for diary storage: ${diariesDir.path}');
        return diariesDir;
      } catch (fallbackError) {
        debugPrint('Temp directory also failed for diaries: $fallbackError');
        // Switch to memory storage
        _useMemoryStorage = true;
        throw Exception('All directory options failed for diaries, switching to memory storage');
      }
    }
  }
  
  /// Get the directory for a specific character's diaries
  static Future<Directory> _getCharacterDiaryDirectory(String characterId) async {
    final diariesDir = await _getDiariesDirectory();
    // Sanitize character ID to avoid file system issues
    final sanitizedId = characterId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    final characterDir = Directory('${diariesDir.path}/character_$sanitizedId');
    
    if (!await characterDir.exists()) {
      await characterDir.create(recursive: true);
    }
    
    return characterDir;
  }
  
  /// Get the file path for a specific diary entry
  static Future<File> _getDiaryFile(String characterId, String diaryId) async {
    final characterDir = await _getCharacterDiaryDirectory(characterId);
    // Sanitize diary ID to avoid file system issues
    final sanitizedId = diaryId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return File('${characterDir.path}/diary_$sanitizedId.json');
  }
  
  /// Save a diary entry to local storage
  static Future<void> saveDiaryEntry(DiaryEntry diaryEntry) async {
    try {
      // Initialize storage if not already done
      if (!_useMemoryStorage && kIsWeb) {
        await initializeStorage();
      }
      
      // Update the updatedAt timestamp
      final updatedEntry = diaryEntry.copyWith(
        updatedAt: DateTime.now(),
      );
      
      if (_useMemoryStorage) {
        // Memory-based storage
        final index = _memoryCache.indexWhere((d) => d.id == updatedEntry.id);
        if (index != -1) {
          _memoryCache[index] = updatedEntry;
        } else {
          _memoryCache.add(updatedEntry);
        }
        debugPrint('Saved diary entry to memory storage: ${updatedEntry.title}');
      } else {
        // File-based storage
        final jsonString = json.encode(updatedEntry.toJson());
        final file = await _getDiaryFile(updatedEntry.characterId, updatedEntry.id);
        await file.writeAsString(jsonString);
        debugPrint('Successfully saved diary entry to file: ${updatedEntry.title} at ${file.path}');
        
        // Update memory cache
        final index = _memoryCache.indexWhere((d) => d.id == updatedEntry.id);
        if (index != -1) {
          _memoryCache[index] = updatedEntry;
        } else {
          _memoryCache.add(updatedEntry);
        }
      }
      
      debugPrint('Diary entry saved to memory cache: ${updatedEntry.title}');
      
      // Trigger cloud sync if user is authenticated
      try {
        final syncService = CloudSyncService();
        if (syncService.authService.isAuthenticated) {
          syncService.scheduleDiarySync();
        }
      } catch (e) {
        debugPrint('Error scheduling diary sync: $e');
      }
    } catch (e) {
      debugPrint('Error saving diary entry ${diaryEntry.title}: $e');
      
      // Fallback to memory storage
      if (!_useMemoryStorage) {
        debugPrint('Falling back to memory storage for diary entry due to error');
        _useMemoryStorage = true;
        await saveDiaryEntry(diaryEntry);
        return;
      }
      
      // Still update memory cache even if everything else fails
      final index = _memoryCache.indexWhere((d) => d.id == diaryEntry.id);
      if (index != -1) {
        _memoryCache[index] = diaryEntry;
      } else {
        _memoryCache.add(diaryEntry);
      }
      rethrow; // Re-throw to let the caller know there was an issue
    }
  }
  
  /// Load all diary entries for a specific character
  static Future<List<DiaryEntry>> loadDiaryEntriesForCharacter(String characterId) async {
    try {
      // Initialize storage if not already done
      if (!_useMemoryStorage && kIsWeb) {
        await initializeStorage();
      }
      
      List<DiaryEntry> diaryEntries = [];
      
      if (_useMemoryStorage) {
        // Memory-based storage
        diaryEntries = _memoryCache.where((d) => d.characterId == characterId).toList();
        debugPrint('Loaded ${diaryEntries.length} diary entries from memory storage for character: $characterId');
      } else {
        // File-based storage
        final characterDir = await _getCharacterDiaryDirectory(characterId);
        
        if (!await characterDir.exists()) {
          debugPrint('Character diary directory does not exist, returning empty list for character: $characterId');
          return [];
        }
        
        // Use a simpler approach to list files
        List<File> diaryFiles = [];
        try {
          await for (final entity in characterDir.list()) {
            if (entity is File && 
                entity.path.endsWith('.json') &&
                entity.path.contains('diary_')) {
              diaryFiles.add(entity);
            }
          }
        } catch (e) {
          debugPrint('Error listing diary files: $e');
          debugPrint('Falling back to memory storage for diaries');
          _useMemoryStorage = true;
          return _memoryCache.where((d) => d.characterId == characterId).toList();
        }
        
        for (final file in diaryFiles) {
          try {
            debugPrint('Loading diary entry from: ${file.path}');
            final diaryEntry = await _loadDiaryEntryFromFile(file);
            if (diaryEntry.characterId == characterId) {
              diaryEntries.add(diaryEntry);
              debugPrint('Successfully loaded diary entry: ${diaryEntry.title}');
            }
          } catch (e) {
            debugPrint('Error loading diary entry from ${file.path}: $e');
          }
        }
        
        // Update memory cache with loaded diary entries for this character
        _memoryCache.removeWhere((d) => d.characterId == characterId);
        _memoryCache.addAll(diaryEntries);
      }
      
      // Sort diary entries by updatedAt (most recent first)
      diaryEntries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      debugPrint('Loaded ${diaryEntries.length} diary entries for character: $characterId');
      return diaryEntries;
    } catch (e) {
      debugPrint('Error loading diary entries for character $characterId: $e');
      
      // Fallback to memory storage
      if (!_useMemoryStorage) {
        debugPrint('Falling back to memory storage for diary entries due to error');
        _useMemoryStorage = true;
        return _memoryCache.where((d) => d.characterId == characterId).toList();
      }
      
      // Return memory cache as final fallback
      return _memoryCache.where((d) => d.characterId == characterId).toList();
    }
  }
  
  /// Load a single diary entry from a file
  static Future<DiaryEntry> _loadDiaryEntryFromFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      return DiaryEntry.fromJson(jsonData);
    } catch (e, stackTrace) {
      debugPrint('Error loading diary entry from ${file.path}: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Create a new diary entry
  static Future<DiaryEntry> createDiaryEntry({
    required String characterId,
    required String title,
    String content = '',
  }) async {
    final now = DateTime.now();
    final diaryId = '${characterId}_${title.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}';
    
    final diaryEntry = DiaryEntry(
      id: diaryId,
      characterId: characterId,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    
    await saveDiaryEntry(diaryEntry);
    return diaryEntry;
  }
  
  /// Delete a diary entry
  static Future<void> deleteDiaryEntry(String characterId, String diaryId) async {
    try {
      // Initialize storage if not already done
      if (!_useMemoryStorage && kIsWeb) {
        await initializeStorage();
      }
      
      if (_useMemoryStorage) {
        // Memory-based deletion
        _memoryCache.removeWhere((d) => d.id == diaryId);
        debugPrint('Deleted diary entry from memory storage: $diaryId');
      } else {
        // File-based deletion
        final file = await _getDiaryFile(characterId, diaryId);
        
        // Delete file if it exists
        if (await file.exists()) {
          await file.delete();
          debugPrint('Successfully deleted diary entry file: ${file.path}');
        } else {
          debugPrint('Diary entry file not found for ID: $diaryId');
        }
        
        // Remove from memory cache
        _memoryCache.removeWhere((d) => d.id == diaryId);
      }
      
      debugPrint('Diary entry removed from memory cache: $diaryId');
    } catch (e) {
      debugPrint('Error deleting diary entry $diaryId: $e');
      
      // Fallback to memory storage
      if (!_useMemoryStorage) {
        debugPrint('Falling back to memory storage for diary entry deletion');
        _useMemoryStorage = true;
        await deleteDiaryEntry(characterId, diaryId);
        return;
      }
      
      // Still remove from memory cache even if file deletion fails
      _memoryCache.removeWhere((d) => d.id == diaryId);
      rethrow; // Re-throw to let the caller know there was an issue
    }
  }
  
  /// Clear the memory cache (useful for testing or forcing refresh)
  static void clearMemoryCache() {
    _memoryCache.clear();
    debugPrint('Diary memory cache cleared');
  }

  /// Search diary entries by title or content
  static List<DiaryEntry> searchDiaryEntries(List<DiaryEntry> diaryEntries, String query) {
    if (query.isEmpty) return diaryEntries;
    
    final lowerQuery = query.toLowerCase();
    return diaryEntries.where((entry) {
      return entry.title.toLowerCase().contains(lowerQuery) ||
             entry.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  /// Export diary entry to JSON string (for sharing/backup)
  static String exportDiaryEntry(DiaryEntry diaryEntry) {
    return json.encode(diaryEntry.toJson());
  }
  
  /// Import diary entry from JSON string
  static Future<DiaryEntry> importDiaryEntry(String jsonString, String characterId) async {
    try {
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final diaryEntry = DiaryEntry.fromJson(jsonData);
      
      // Generate a new ID to avoid conflicts and set the character ID
      final now = DateTime.now();
      final newId = '${characterId}_${diaryEntry.title.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}';
      final importedEntry = diaryEntry.copyWith(
        id: newId,
        characterId: characterId,
        createdAt: now,
        updatedAt: now,
      );
      
      await saveDiaryEntry(importedEntry);
      return importedEntry;
    } catch (e) {
      debugPrint('Error importing diary entry: $e');
      rethrow;
    }
  }
  
  /// Debug method to check diary storage
  static Future<void> debugCheckDiaryStorage() async {
    try {
      final dir = await _getDiariesDirectory();
      final files = await dir.list().toList();
      
      debugPrint('\n=== Diary Storage Debug Report ===');
      debugPrint('Diaries directory: ${dir.path}');
      debugPrint('Directory exists: ${await dir.exists()}');
      debugPrint('Total files/directories: ${files.length}');
      debugPrint('Memory cache size: ${_memoryCache.length}');
      
      for (final file in files) {
        if (file is Directory) {
          debugPrint('Character directory: ${file.path}');
          final characterFiles = await file.list().toList();
          for (final characterFile in characterFiles) {
            if (characterFile is File && characterFile.path.endsWith('.json')) {
              debugPrint('  Diary file: ${characterFile.path}');
            }
          }
        }
      }
      
      debugPrint('=====================================\n');
      
    } catch (e) {
      debugPrint('Error checking diary storage: $e');
    }
  }
}
