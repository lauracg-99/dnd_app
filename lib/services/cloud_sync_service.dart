import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_auth_service.dart';
import 'character_service.dart';
import 'diary_service.dart';
import '../models/character_model.dart';
import '../models/diary_model.dart';
import '../utils/logger.dart';

/// Service for handling cloud synchronization with Firebase
class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();
  
  static final _logger = AppLogger.forModule('CloudSync');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  // Expose auth service for other services to check authentication status
  FirebaseAuthService get authService => _authService;
  
  // Debounce timers to prevent excessive Firebase calls
  Timer? _charactersSyncTimer;
  Timer? _diariesSyncTimer;
  
  // Sync status tracking
  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;
  
  // Constants
  static const Duration _syncDebounceDelay = Duration(seconds: 5);
  static const String _charactersCollection = 'characters';
  static const String _diariesCollection = 'diaries';
  
  /// Initialize the cloud sync service
  Future<void> initialize() async {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _logger.info('User logged in, initializing cloud sync');
        _syncStatusController.add(SyncStatus.connected);
      } else {
        _logger.info('User logged out, stopping cloud sync');
        _cancelAllSyncTimers();
        _syncStatusController.add(SyncStatus.disconnected);
      }
    });
  }
  
  /// Upload all local data to Firebase (for new account creation)
  Future<SyncResult> uploadAllLocalData() async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }
    
    try {
      _syncStatusController.add(SyncStatus.syncing);
      
      final userId = _authService.currentUser!.uid;
      
      // Upload characters
      final characters = await CharacterService.loadAllCharacters();
      final characterMaps = characters.map((c) => c.toJson()).toList();
      await _uploadCharacters(userId, characterMaps);
      
      // Upload diaries - we need to get all diaries for all characters
      final diaries = <Map<String, dynamic>>[];
      final charactersList = await CharacterService.loadAllCharacters();
      for (final character in charactersList) {
        final characterDiaries = await DiaryService.loadDiaryEntriesForCharacter(character.id);
        diaries.addAll(characterDiaries.map((d) => d.toJson()));
      }
      await _uploadDiaries(userId, diaries);
      
      _syncStatusController.add(SyncStatus.connected);
      
      _logger.success('Successfully uploaded all local data to Firebase');
      
      return SyncResult.success('All data uploaded successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      _logger.error('Error uploading local data', error: e);
      return SyncResult.failure('Failed to upload data: $e');
    }
  }
  
  /// Download all data from Firebase
  Future<SyncResult> downloadAllData() async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }
    
    try {
      _syncStatusController.add(SyncStatus.syncing);
      
      final userId = _authService.currentUser!.uid;
      
      // Download characters
      final characterMaps = await _downloadCharacters(userId);
      for (final characterMap in characterMaps) {
        // Convert Map to Character object
        final character = Character.fromJson(characterMap);
        await CharacterService.saveCharacter(character);
      }
      
      // Download diaries
      final diaryMaps = await _downloadDiaries(userId);
      for (final diaryMap in diaryMaps) {
        // Convert Map to DiaryEntry object
        final diary = DiaryEntry.fromJson(diaryMap);
        await DiaryService.saveDiaryEntry(diary);
      }
      
      _syncStatusController.add(SyncStatus.connected);
      
      _logger.success('Successfully downloaded all data from Firebase');
      
      return SyncResult.success('All data downloaded successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      _logger.error('Error downloading data', error: e);
      return SyncResult.failure('Failed to download data: $e');
    }
  }
  
  /// Schedule sync (debounced) - generic method
  void _scheduleSyncIfAuthenticated(SyncType type) {
    if (!_authService.isAuthenticated) return;
    
    switch (type) {
      case SyncType.characters:
        _charactersSyncTimer?.cancel();
        _charactersSyncTimer = Timer(_syncDebounceDelay, () {
          syncCharacters();
        });
        break;
      case SyncType.diaries:
        _diariesSyncTimer?.cancel();
        _diariesSyncTimer = Timer(_syncDebounceDelay, () {
          syncDiaries();
        });
        break;
    }
  }
  
  /// Schedule character sync (debounced)
  void scheduleCharacterSync() {
    _scheduleSyncIfAuthenticated(SyncType.characters);
  }
  
  /// Schedule diary sync (debounced)
  void scheduleDiarySync() {
    _scheduleSyncIfAuthenticated(SyncType.diaries);
  }
  
  /// Generic method to sync data to Firebase
  Future<SyncResult> _syncData({
    required SyncType type,
    required Future<List<Map<String, dynamic>>> Function() loadData,
    required Future<void> Function(String userId, List<Map<String, dynamic>> data) uploadData,
    required String entityName,
  }) async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }
    
    try {
      _syncStatusController.add(SyncStatus.syncing);
      
      final userId = _authService.currentUser!.uid;
      _logger.section('Starting $entityName sync for user: $userId');
      
      final dataMaps = await loadData();
      _logger.info('Loaded ${dataMaps.length} $entityName from local storage');
      
      await uploadData(userId, dataMaps);
      
      _syncStatusController.add(SyncStatus.connected);
      
      _logger.success('Successfully synced ${dataMaps.length} $entityName to Firebase');
      
      return SyncResult.success('$entityName synced successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      _logger.error('Error syncing $entityName', error: e);
      return SyncResult.failure('Failed to sync $entityName: $e');
    }
  }
  
  /// Force immediate sync of characters
  Future<SyncResult> syncCharacters() async {
    return _syncData(
      type: SyncType.characters,
      loadData: () async {
        final characters = await CharacterService.loadAllCharacters();
        return characters.map((c) => c.toJson()).toList();
      },
      uploadData: _uploadCharacters,
      entityName: 'characters',
    );
  }
  
  /// Force immediate sync of diaries
  Future<SyncResult> syncDiaries() async {
    return _syncData(
      type: SyncType.diaries,
      loadData: () async {
        final diaries = <Map<String, dynamic>>[];
        final charactersList = await CharacterService.loadAllCharacters();
        
        for (final character in charactersList) {
          final characterDiaries = await DiaryService.loadDiaryEntriesForCharacter(character.id);
          diaries.addAll(characterDiaries.map((d) => d.toJson()));
        }
        
        return diaries;
      },
      uploadData: _uploadDiaries,
      entityName: 'diaries',
    );
  }
  
  /// Check if there are characters in cloud that don't exist locally (deleted locally)
  Future<bool> hasLocallyDeletedCharacters() async {
    if (!_authService.isAuthenticated) {
      return false;
    }
    
    try {
      final userId = _authService.currentUser!.uid;
      final localCharacters = await CharacterService.loadAllCharacters();
      final localCharacterIds = localCharacters.map((c) => c.id).toSet();
      
      // Get cloud characters
      final cloudCharactersRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_charactersCollection);
      
      final cloudDocs = await cloudCharactersRef.get();
      final cloudCharacterIds = cloudDocs.docs.map((doc) => doc.id).toSet();
      
      // Check if there are cloud characters that don't exist locally
      return cloudCharacterIds.any((cloudId) => !localCharacterIds.contains(cloudId));
    } catch (e) {
      _logger.error('Error checking for deleted characters', error: e);
      return false;
    }
  }

  /// Force immediate sync of all data
  Future<SyncResult> syncAll() async {
    final characterResult = await syncCharacters();
    final diaryResult = await syncDiaries();
    
    if (characterResult.success && diaryResult.success) {
      return SyncResult.success('All data synced successfully');
    } else {
      final errors = <String>[];
      if (!characterResult.success) errors.add(characterResult.errorMessage!);
      if (!diaryResult.success) errors.add(diaryResult.errorMessage!);
      return SyncResult.failure(errors.join('; '));
    }
  }
  
  /// Upload characters to Firebase
  Future<void> _uploadCharacters(String userId, List<Map<String, dynamic>> characters) async {
    _logger.section('Starting character upload to Firebase');
    _logger.info('Number of characters to upload: ${characters.length}');
    
    for (int i = 0; i < characters.length; i++) {
      final characterName = characters[i]['stats']?['name']?['value'] ?? 'Unknown';
      final characterId = characters[i]['stats']?['id']?['value'] ?? 'Unknown';
      _logger.debug('Character ${i + 1}: $characterName (ID: $characterId)');
    }
    
    final batch = _firestore.batch();
    final charactersRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(_charactersCollection);
    
    // Clear existing characters
    _logger.debug('Clearing existing characters from Firebase...');
    final existingDocs = await charactersRef.get();
    _logger.debug('Found ${existingDocs.docs.length} existing documents to delete');
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }
    
    // Add new characters
    _logger.debug('Adding new characters to Firebase...');
    for (final character in characters) {
      final characterId = character['stats']?['id']?['value']?.toString() ?? 
          DateTime.now().millisecondsSinceEpoch.toString();
      final characterName = character['stats']?['name']?['value'] ?? 'Unknown';
      _logger.debug('Adding character: $characterName with ID: $characterId');
      final docRef = charactersRef.doc(characterId);
      batch.set(docRef, {
        'data': character,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    _logger.debug('Committing batch operation...');
    await batch.commit();
    _logger.success('Character upload completed successfully');
  }
  
  /// Upload diaries to Firebase
  Future<void> _uploadDiaries(String userId, List<Map<String, dynamic>> diaries) async {
    _logger.section('Starting diary upload to Firebase');
    _logger.info('Number of diaries to upload: ${diaries.length}');
    
    for (int i = 0; i < diaries.length; i++) {
      final diaryTitle = diaries[i]['data']?['title']?['value'] ?? 'Unknown';
      final diaryId = diaries[i]['data']?['id']?['value'] ?? 'Unknown';
      _logger.debug('Diary ${i + 1}: $diaryTitle (ID: $diaryId)');
    }
    
    final batch = _firestore.batch();
    final diariesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(_diariesCollection);
    
    // Clear existing diaries
    _logger.debug('Clearing existing diaries from Firebase...');
    final existingDocs = await diariesRef.get();
    _logger.debug('Found ${existingDocs.docs.length} existing diary documents to delete');
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }
    
    // Add new diaries
    _logger.debug('Adding new diaries to Firebase...');
    for (final diary in diaries) {
      final diaryId = diary['data']?['id']?['value']?.toString() ?? 
          DateTime.now().millisecondsSinceEpoch.toString();
      final diaryTitle = diary['data']?['title']?['value'] ?? 'Unknown';
      _logger.debug('Adding diary: $diaryTitle with ID: $diaryId');
      final docRef = diariesRef.doc(diaryId);
      batch.set(docRef, {
        'data': diary,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    _logger.debug('Committing diary batch operation...');
    await batch.commit();
    _logger.success('Diary upload completed successfully');
  }
  
  /// Download characters from Firebase
  Future<List<Map<String, dynamic>>> _downloadCharacters(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(_charactersCollection)
        .get();
    
    return querySnapshot.docs
        .map((doc) => doc['data'] as Map<String, dynamic>)
        .toList();
  }
  
  /// Download diaries from Firebase
  Future<List<Map<String, dynamic>>> _downloadDiaries(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(_diariesCollection)
        .get();
    
    return querySnapshot.docs
        .map((doc) => doc['data'] as Map<String, dynamic>)
        .toList();
  }
  
  /// Download characters from Firebase
  Future<List<Map<String, dynamic>>> downloadCharacters(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(_charactersCollection)
        .get();
    
    return querySnapshot.docs
        .map((doc) => doc['data'] as Map<String, dynamic>)
        .toList();
  }
  
  /// Download diaries from Firebase
  Future<List<Map<String, dynamic>>> downloadDiaries(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(_diariesCollection)
        .get();
    
    return querySnapshot.docs
        .map((doc) => doc['data'] as Map<String, dynamic>)
        .toList();
  }
  
  /// Check if user has existing cloud data
  Future<bool> hasExistingCloudData() async {
    if (!_authService.isAuthenticated) {
      return false;
    }
    
    try {
      final userId = _authService.currentUser!.uid;
      
      // Check if user has any characters
      final charactersRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_charactersCollection);
      
      final charactersSnapshot = await charactersRef.limit(1).get();
      
      // Check if user has any diaries
      final diariesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_diariesCollection);
      
      final diariesSnapshot = await diariesRef.limit(1).get();
      
      return charactersSnapshot.docs.isNotEmpty || diariesSnapshot.docs.isNotEmpty;
    } catch (e) {
      _logger.error('Error checking existing cloud data', error: e);
      return false;
    }
  }
  
  /// Delete all user data from Firebase cloud storage
  Future<SyncResult> deleteAllCloudData() async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }
    
    try {
      _syncStatusController.add(SyncStatus.syncing);
      
      final userId = _authService.currentUser!.uid;
      
      // Delete all characters
      final charactersRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_charactersCollection);
      
      final charactersSnapshot = await charactersRef.get();
      final batch = _firestore.batch();
      
      for (final doc in charactersSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete all diaries
      final diariesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection(_diariesCollection);
      
      final diariesSnapshot = await diariesRef.get();
      
      for (final doc in diariesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Execute batch delete
      await batch.commit();
      
      _syncStatusController.add(SyncStatus.connected);
      
      _logger.success('Successfully deleted all cloud data for user: $userId');
      
      return SyncResult.success('All cloud data deleted successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      _logger.error('Error deleting cloud data', error: e);
      return SyncResult.failure('Failed to delete cloud data: $e');
    }
  }
  
  /// Cancel all sync timers
  void _cancelAllSyncTimers() {
    _charactersSyncTimer?.cancel();
    _charactersSyncTimer = null;
    _diariesSyncTimer?.cancel();
    _diariesSyncTimer = null;
  }
  
  /// Dispose the service
  void dispose() {
    _cancelAllSyncTimers();
    _syncStatusController.close();
  }
}

/// Sync type enumeration
enum SyncType {
  characters,
  diaries,
}

/// Sync status enumeration
enum SyncStatus {
  disconnected,
  connected,
  syncing,
  error,
}

/// Result of sync operation
class SyncResult {
  final bool success;
  final String? errorMessage;
  final String? successMessage;
  
  SyncResult.success(this.successMessage) : success = true, errorMessage = null;
  SyncResult.failure(this.errorMessage) : success = false, successMessage = null;
  
  @override
  String toString() {
    if (success) {
      return 'SyncResult.success(message: $successMessage)';
    } else {
      return 'SyncResult.failure(error: $errorMessage)';
    }
  }
}
