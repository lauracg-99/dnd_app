import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/diary_model.dart';
import 'diary_storage_service.dart';

class DiaryService {
  static final _storage = DiaryStorageService();
  
  /// Initialize storage system
  static Future<void> initializeStorage() async {
    await _storage.initializeStorage();
  }
  
  /// Save a diary entry to local storage
  static Future<void> saveDiaryEntry(DiaryEntry diaryEntry) async {
    await _storage.save(diaryEntry);
  }
  
  /// Load all diary entries for a specific character
  static Future<List<DiaryEntry>> loadDiaryEntriesForCharacter(String characterId) async {
    return await _storage.loadAll(filter: characterId);
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
    final sanitizedCharacterId = characterId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    await _storage.delete(diaryId, subDir: 'character_$sanitizedCharacterId');
  }
  
  /// Clear the memory cache (useful for testing or forcing refresh)
  static void clearMemoryCache() {
    _storage.clearMemoryCache();
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
      final dir = await _storage.getDirectory();
      final files = await dir.list(recursive: true).toList();
      
      debugPrint('\n=== Diary Storage Debug Report ===');
      debugPrint('Diaries directory: ${dir.path}');
      debugPrint('Directory exists: ${await dir.exists()}');
      debugPrint('Total files/directories: ${files.length}');
      
      for (final file in files) {
        if (file.path.endsWith('.json')) {
          debugPrint('Diary file: ${file.path}');
        }
      }
      
      debugPrint('=====================================\n');
      
    } catch (e) {
      debugPrint('Error checking diary storage: $e');
    }
  }
}
