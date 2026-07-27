import 'package:flutter/material.dart';

import '../models/diary_group_model.dart';
import 'base_storage_service.dart';
import 'cloud_sync_service.dart';

/// Storage service for diary groups
/// Extends BaseStorageService to provide file-based storage with memory caching
class DiaryGroupStorageService extends BaseStorageService<DiaryGroup> {
  static final DiaryGroupStorageService _instance = DiaryGroupStorageService._internal();
  
  factory DiaryGroupStorageService() => _instance;
  
  DiaryGroupStorageService._internal() : super('diary_groups');

  @override
  String getId(DiaryGroup entity) => entity.id;

  @override
  String getDisplayName(DiaryGroup entity) => entity.name;

  @override
  String getEntityName() => 'Diary group';

  @override
  String getFilePrefix() => 'diary_group';

  @override
  Map<String, dynamic> toJson(DiaryGroup entity) => entity.toJson();

  @override
  DiaryGroup fromJson(Map<String, dynamic> json) => DiaryGroup.fromJson(json);

  @override
  void sortEntities(List<DiaryGroup> entities) {
    // Sort by updated date, most recent first
    entities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  String? getSubDirectory(DiaryGroup entity) {
    // Store groups in character-specific subdirectories
    final sanitizedId = entity.characterId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return 'character_$sanitizedId';
  }

  @override
  bool matchesFilter(DiaryGroup entity, String filter) {
    // Filter by character ID
    return entity.characterId == filter;
  }

  @override
  Future<void> scheduleSync(CloudSyncService syncService) async {
    // Diary group sync can be scheduled here if needed
    // For now, groups are synced as part of character data
    debugPrint('Diary group sync scheduled');
  }

  @override
  Future<void> deleteFromCloud(String id, CloudSyncService syncService) async {
    // Diary group deletion from cloud is handled by the cloud sync service
    // No specific implementation needed here as groups are synced as a collection
  }
}
