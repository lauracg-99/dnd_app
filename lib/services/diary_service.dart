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
  /// Optionally filter by groupId to get entries for a specific group
  static Future<List<DiaryEntry>> loadDiaryEntriesForCharacter(
    String characterId, {
    String? groupId, // Optional group filter
  }) async {
    final entries = await _storage.loadAll(filter: characterId);

    // Filter by groupId if provided
    if (groupId != null) {
      return entries.where((entry) => entry.groupId == groupId).toList();
    }

    return entries;
  }

  /// Load all diary entries (no filter)
  static Future<List<DiaryEntry>> loadAllDiaryEntries() async {
    return await _storage.loadAll();
  }

  /// Create a new diary entry
  static Future<DiaryEntry> createDiaryEntry({
    required String characterId,
    required String title,
    String content = '',
    String? groupId, // Optional group ID for organizing entries
  }) async {
    final now = DateTime.now();
    final diaryId =
        '${characterId}_${title.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}';

    final diaryEntry = DiaryEntry(
      id: diaryId,
      characterId: characterId,
      title: title,
      content: content,
      groupId: groupId, // Set group ID if provided
      createdAt: now,
      updatedAt: now,
    );

    await saveDiaryEntry(diaryEntry);
    return diaryEntry;
  }

  /// Update an existing diary entry
  static Future<DiaryEntry> updateDiaryEntry(DiaryEntry diaryEntry) async {
    final updatedEntry = diaryEntry.withUpdatedTimestamp();
    await saveDiaryEntry(updatedEntry);
    return updatedEntry;
  }

  /// Delete a diary entry
  static Future<void> deleteDiaryEntry(
    String characterId,
    String diaryId,
  ) async {
    final sanitizedCharacterId = characterId.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]'),
      '_',
    );
    await _storage.delete(diaryId, subDir: 'character_$sanitizedCharacterId');
  }

  /// Clear the memory cache (useful for testing or forcing refresh)
  static void clearMemoryCache() {
    _storage.clearMemoryCache();
  }

  /// Search diary entries by title or content
  static List<DiaryEntry> searchDiaryEntries(
    List<DiaryEntry> diaryEntries,
    String query,
  ) {
    if (query.isEmpty) return diaryEntries;

    final lowerQuery = query.toLowerCase();
    return diaryEntries.where((entry) {
      return entry.title.toLowerCase().contains(lowerQuery) ||
          entry.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Export one diary entry to JSON string (for sharing/backup)
  static String exportDiaryEntry(DiaryEntry diaryEntry) {
    return json.encode(diaryEntry.toJson());
  }

  /// Export multiple diary entries to JSON string.
  /// Group associations are intentionally omitted when the entries are imported elsewhere.
  static String exportDiaryEntries(List<DiaryEntry> diaryEntries) {
    final payload =
        diaryEntries
            .map((entry) => entry.copyWith(clearGroupId: true).toJson())
            .toList();
    return json.encode(payload);
  }

  /// Import diary entry from JSON string
  static Future<DiaryEntry> importDiaryEntry(
    String jsonString,
    String characterId,
  ) async {
    try {
      final decoded = json.decode(jsonString);
      final jsonData =
          decoded is List ? decoded.first : decoded as Map<String, dynamic>;
      final diaryEntry = DiaryEntry.fromJson(jsonData as Map<String, dynamic>);

      // Generate a new ID to avoid conflicts and set the character ID
      final now = DateTime.now();
      final newId =
          '${characterId}_${diaryEntry.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}_${now.millisecondsSinceEpoch}';
      final importedEntry = diaryEntry.copyWith(
        id: newId,
        characterId: characterId,
        groupId: null,
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

  /// Import several diary entries to a specific character.
  /// This intentionally clears any stored group assignment to avoid taking
  /// the source character's group structure into the target one.
  static Future<List<DiaryEntry>> importDiaryEntries(
    String jsonString,
    String characterId,
  ) async {
    try {
      final decoded = json.decode(jsonString);
      final payload = decoded is List ? decoded : [decoded];

      final importedEntries = <DiaryEntry>[];
      for (var i = 0; i < payload.length; i++) {
        final item = payload[i];
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final sourceEntry = DiaryEntry.fromJson(item);
        final now = DateTime.now();
        final safeTitle = sourceEntry.title.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]+'),
          '_',
        );
        final newId =
            '${characterId}_${safeTitle}_${now.millisecondsSinceEpoch}_$i';

        final importedEntry = sourceEntry.copyWith(
          id: newId,
          characterId: characterId,
          groupId: null,
          createdAt: now,
          updatedAt: now,
        );

        await saveDiaryEntry(importedEntry);
        importedEntries.add(importedEntry);
      }

      return importedEntries;
    } catch (e) {
      debugPrint('Error importing diary entries: $e');
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
