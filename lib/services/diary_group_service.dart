import 'package:flutter/foundation.dart';
import '../models/diary_group_model.dart';
import 'diary_group_storage_service.dart';

/// Service for managing diary groups
/// Provides CRUD operations for diary groups with storage integration
class DiaryGroupService {
  static final _storage = DiaryGroupStorageService();

  /// Initialize storage system
  static Future<void> initializeStorage() async {
    await _storage.initializeStorage();
  }

  /// Save a diary group to local storage
  static Future<void> saveDiaryGroup(DiaryGroup diaryGroup) async {
    await _storage.save(diaryGroup);
  }

  /// Load all diary groups for a specific character
  static Future<List<DiaryGroup>> loadDiaryGroupsForCharacter(
    String characterId,
  ) async {
    return await _storage.loadAll(filter: characterId);
  }

  /// Load all diary groups (no filter)
  static Future<List<DiaryGroup>> loadAllDiaryGroups() async {
    return await _storage.loadAll();
  }

  /// Create a new diary group
  static Future<DiaryGroup> createDiaryGroup({
    required String characterId,
    required String name,
  }) async {
    final now = DateTime.now();
    final groupId =
        '${characterId}_${name.toLowerCase().replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}';

    final diaryGroup = DiaryGroup(
      id: groupId,
      characterId: characterId,
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    await saveDiaryGroup(diaryGroup);
    return diaryGroup;
  }

  /// Update an existing diary group
  static Future<DiaryGroup> updateDiaryGroup(DiaryGroup diaryGroup) async {
    final updatedGroup = diaryGroup.withUpdatedTimestamp();
    await saveDiaryGroup(updatedGroup);
    return updatedGroup;
  }

  /// Delete a diary group
  static Future<void> deleteDiaryGroup(
    String characterId,
    String groupId,
  ) async {
    final sanitizedCharacterId = characterId.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]'),
      '_',
    );
    await _storage.delete(groupId, subDir: 'character_$sanitizedCharacterId');
  }

  /// Clear the memory cache (useful for testing or forcing refresh)
  static void clearMemoryCache() {
    _storage.clearMemoryCache();
  }

  /// Search diary groups by name
  static List<DiaryGroup> searchDiaryGroups(
    List<DiaryGroup> diaryGroups,
    String query,
  ) {
    if (query.isEmpty) return diaryGroups;

    final lowerQuery = query.toLowerCase();
    return diaryGroups.where((group) {
      return group.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Debug method to check diary group storage
  static Future<void> debugCheckDiaryGroupStorage() async {
    try {
      final dir = await _storage.getDirectory();
      final files = await dir.list(recursive: true).toList();

      debugPrint('\n=== Diary Group Storage Debug Report ===');
      debugPrint('Diary groups directory: ${dir.path}');
      debugPrint('Directory exists: ${await dir.exists()}');
      debugPrint('Total files/directories: ${files.length}');

      for (final file in files) {
        if (file.path.endsWith('.json')) {
          debugPrint('Diary group file: ${file.path}');
        }
      }

      debugPrint('=========================================\n');
    } catch (e) {
      debugPrint('Error checking diary group storage: $e');
    }
  }
}
