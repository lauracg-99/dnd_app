import '../models/diary_model.dart';
import 'base_storage_service.dart';
import 'cloud_sync_service.dart';

class DiaryStorageService extends BaseStorageService<DiaryEntry> {
  static final DiaryStorageService _instance = DiaryStorageService._internal();
  
  factory DiaryStorageService() => _instance;
  
  DiaryStorageService._internal() : super('diaries');

  @override
  String getId(DiaryEntry entity) => entity.id;

  @override
  String getDisplayName(DiaryEntry entity) => entity.title;

  @override
  String getEntityName() => 'Diary entry';

  @override
  String getFilePrefix() => 'diary';

  @override
  Map<String, dynamic> toJson(DiaryEntry entity) => entity.toJson();

  @override
  DiaryEntry fromJson(Map<String, dynamic> json) => DiaryEntry.fromJson(json);

  @override
  void sortEntities(List<DiaryEntry> entities) {
    entities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  String? getSubDirectory(DiaryEntry entity) {
    final sanitizedId = entity.characterId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return 'character_$sanitizedId';
  }

  @override
  bool matchesFilter(DiaryEntry entity, String filter) {
    return entity.characterId == filter;
  }

  @override
  Future<void> scheduleSync(CloudSyncService syncService) async {
    syncService.scheduleDiarySync();
  }

  @override
  Future<void> deleteFromCloud(String id, CloudSyncService syncService) async {
    // Diary deletion from cloud is handled by the cloud sync service
    // No specific implementation needed here as diaries are synced as a collection
  }
}
