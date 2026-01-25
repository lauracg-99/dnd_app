import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_auth_service.dart';
import 'character_service.dart';
import 'diary_service.dart';
import '../models/character_model.dart';
import '../models/diary_model.dart';

/// Service for handling cloud synchronization with Firebase
class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

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
        if (kDebugMode) {
          print('User logged in, initializing cloud sync');
        }
        // User logged in, we can start syncing
        _syncStatusController.add(SyncStatus.connected);
      } else {
        if (kDebugMode) {
          print('User logged out, stopping cloud sync');
        }
        // User logged out, stop sync timers
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
      
      if (kDebugMode) {
        print('Successfully uploaded all local data to Firebase');
      }
      
      return SyncResult.success('All data uploaded successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      if (kDebugMode) {
        print('Error uploading local data: $e');
      }
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
      
      if (kDebugMode) {
        print('Successfully downloaded all data from Firebase');
      }
      
      return SyncResult.success('All data downloaded successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      if (kDebugMode) {
        print('Error downloading data: $e');
      }
      return SyncResult.failure('Failed to download data: $e');
    }
  }
  
  /// Schedule character sync (debounced)
  void scheduleCharacterSync() {
    if (!_authService.isAuthenticated) return;
    
    _charactersSyncTimer?.cancel();
    _charactersSyncTimer = Timer(_syncDebounceDelay, () {
      syncCharacters();
    });
  }
  
  /// Schedule diary sync (debounced)
  void scheduleDiarySync() {
    if (!_authService.isAuthenticated) return;
    
    _diariesSyncTimer?.cancel();
    _diariesSyncTimer = Timer(_syncDebounceDelay, () {
      syncDiaries();
    });
  }
  
  /// Force immediate sync of characters
  Future<SyncResult> syncCharacters() async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }
    
    try {
      _syncStatusController.add(SyncStatus.syncing);
      
      final userId = _authService.currentUser!.uid;
      print('=== Starting character sync for user: $userId ===');
      
      final characters = await CharacterService.loadAllCharacters();
      print('Loaded ${characters.length} characters from local storage');
      
      final characterMaps = characters.map((c) => c.toJson()).toList();
      print('Converted ${characterMaps.length} characters to JSON maps');
      
      await _uploadCharacters(userId, characterMaps);
      
      _syncStatusController.add(SyncStatus.connected);
      
      
      print('Successfully synced ${characters.length} characters to Firebase');
      
      
      return SyncResult.success('Characters synced successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      if (kDebugMode) {
        print('Error syncing characters: $e');
      }
      return SyncResult.failure('Failed to sync characters: $e');
    }
  }
  
  /// Force immediate sync of diaries
  Future<SyncResult> syncDiaries() async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }
    
    try {
      _syncStatusController.add(SyncStatus.syncing);
      
      final userId = _authService.currentUser!.uid;
      print('=== Starting diary sync for user: $userId ===');
      
      // Get all diaries for all characters
      final diaries = <Map<String, dynamic>>[];
      final charactersList = await CharacterService.loadAllCharacters();
      print('Loaded ${charactersList.length} characters for diary sync');
      
      for (final character in charactersList) {
        final characterDiaries = await DiaryService.loadDiaryEntriesForCharacter(character.id);
        print('Loaded ${characterDiaries.length} diary entries for character: ${character.name}');
        diaries.addAll(characterDiaries.map((d) => d.toJson()));
      }
      
      final diaryMaps = diaries.map((d) => d).toList();
      print('Total diaries to sync: ${diaryMaps.length}');
      
      await _uploadDiaries(userId, diaryMaps);
      
      _syncStatusController.add(SyncStatus.connected);
      
      if (kDebugMode) {
        print('Successfully synced ${diaryMaps.length} diaries to Firebase');
      }
      
      return SyncResult.success('Diaries synced successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      if (kDebugMode) {
        print('Error syncing diaries: $e');
      }
      return SyncResult.failure('Failed to sync diaries: $e');
    }
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
      if (kDebugMode) {
        print('Error checking for deleted characters: $e');
      }
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
    debugPrint('=== Starting character upload to Firebase ===');
    debugPrint('Number of characters to upload: ${characters.length}');
    
    for (int i = 0; i < characters.length; i++) {
      final characterName = characters[i]['stats']?['name']?['value'] ?? 'Unknown';
      final characterId = characters[i]['stats']?['id']?['value'] ?? 'Unknown';
      debugPrint('Character ${i + 1}: $characterName (ID: $characterId)');
    }
    
    final batch = _firestore.batch();
    final charactersRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(_charactersCollection);
    
    // Clear existing characters
    debugPrint('Clearing existing characters from Firebase...');
    final existingDocs = await charactersRef.get();
    debugPrint('Found ${existingDocs.docs.length} existing documents to delete');
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }
    
    // Add new characters
    debugPrint('Adding new characters to Firebase...');
    for (final character in characters) {
      final characterId = character['stats']?['id']?['value']?.toString() ?? 
          DateTime.now().millisecondsSinceEpoch.toString();
      final characterName = character['stats']?['name']?['value'] ?? 'Unknown';
      debugPrint('Adding character: $characterName with ID: $characterId');
      final docRef = charactersRef.doc(characterId);
      batch.set(docRef, {
        'data': character,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    debugPrint('Committing batch operation...');
    await batch.commit();
    debugPrint('=== Character upload completed successfully ===');
  }
  
  /// Upload diaries to Firebase
  Future<void> _uploadDiaries(String userId, List<Map<String, dynamic>> diaries) async {
    print('=== Starting diary upload to Firebase ===');
    print('Number of diaries to upload: ${diaries.length}');
    
    for (int i = 0; i < diaries.length; i++) {
      final diaryTitle = diaries[i]['data']?['title']?['value'] ?? 'Unknown';
      final diaryId = diaries[i]['data']?['id']?['value'] ?? 'Unknown';
      print('Diary ${i + 1}: $diaryTitle (ID: $diaryId)');
    }
    
    final batch = _firestore.batch();
    final diariesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(_diariesCollection);
    
    // Clear existing diaries
    print('Clearing existing diaries from Firebase...');
    final existingDocs = await diariesRef.get();
    print('Found ${existingDocs.docs.length} existing diary documents to delete');
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }
    
    // Add new diaries
    print('Adding new diaries to Firebase...');
    for (final diary in diaries) {
      final diaryId = diary['data']?['id']?['value']?.toString() ?? 
          DateTime.now().millisecondsSinceEpoch.toString();
      final diaryTitle = diary['data']?['title']?['value'] ?? 'Unknown';
      print('Adding diary: $diaryTitle with ID: $diaryId');
      final docRef = diariesRef.doc(diaryId);
      batch.set(docRef, {
        'data': diary,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    print('Committing diary batch operation...');
    await batch.commit();
    print('=== Diary upload completed successfully ===');
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
      if (kDebugMode) {
        print('Error checking existing cloud data: $e');
      }
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
      
      if (kDebugMode) {
        print('Successfully deleted all cloud data for user: $userId');
      }
      
      return SyncResult.success('All cloud data deleted successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      if (kDebugMode) {
        print('Error deleting cloud data: $e');
      }
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
