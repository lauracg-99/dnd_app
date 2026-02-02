import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/character_model.dart';
import 'base_storage_service.dart';
import 'cloud_sync_service.dart';

class CharacterStorageService extends BaseStorageService<Character> {
  static final CharacterStorageService _instance = CharacterStorageService._internal();
  
  factory CharacterStorageService() => _instance;
  
  CharacterStorageService._internal() : super('characters');

  @override
  String getId(Character entity) => entity.id;

  @override
  String getDisplayName(Character entity) => entity.name;

  @override
  String getEntityName() => 'Character';

  @override
  String getFilePrefix() => 'character';

  @override
  Map<String, dynamic> toJson(Character entity) => entity.toJson();

  @override
  Character fromJson(Map<String, dynamic> json) => Character.fromJson(json);

  @override
  Character updateTimestamp(Character entity) {
    return entity.copyWith(updatedAt: DateTime.now());
  }

  @override
  void sortEntities(List<Character> entities) {
    entities.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<void> scheduleSync(CloudSyncService syncService) async {
    syncService.scheduleCharacterSync();
  }

  @override
  Future<void> deleteFromCloud(String id, CloudSyncService syncService) async {
    if (!syncService.authService.isAuthenticated) {
      return;
    }

    final userId = syncService.authService.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    final characterRef = firestore
        .collection('users')
        .doc(userId)
        .collection('characters')
        .doc(id);

    await characterRef.delete();
  }
}
