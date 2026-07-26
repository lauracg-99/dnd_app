import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_auth_service.dart';
import 'character_service.dart';
import 'diary_service.dart';
import 'device_service.dart';
import '../models/character_model.dart';
import '../models/diary_model.dart';

/// Service for handling cloud synchronization with Firebase
class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final DeviceService _deviceService = DeviceService();

  // Expose auth service for other services to check authentication status
  FirebaseAuthService get authService => _authService;

  // Debounce timers to prevent excessive Firebase calls
  Timer? _charactersSyncTimer;
  Timer? _diariesSyncTimer;

  // Real-time listeners for cross-device sync
  StreamSubscription<QuerySnapshot>? _charactersListener;
  StreamSubscription<QuerySnapshot>? _diariesListener;

  // Cache for detecting actual data changes (ignoring metadata)
  final Map<String, Map<String, dynamic>> _lastKnownCharacters = {};
  final Map<String, Map<String, dynamic>> _lastKnownDiaries = {};

  // Flags to track if initial snapshot has been processed
  bool _charactersInitialSnapshotProcessed = false;
  bool _diariesInitialSnapshotProcessed = false;

  // Sync status tracking
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  // Current sync status for new subscribers
  SyncStatus _currentSyncStatus = SyncStatus.disconnected;
  SyncStatus get currentSyncStatus => _currentSyncStatus;

  // Constants
  static const Duration _syncDebounceDelay = Duration(seconds: 5);
  static const String _charactersCollection = 'characters';
  static const String _diariesCollection = 'diaries';
  static const String _devicesCollection = 'devices';

  /// Initialize the cloud sync service
  Future<void> initialize() async {
    if (kDebugMode) {
      print('=== CloudSyncService.initialize() ===');
    }

    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      if (kDebugMode) {
        print('Auth state changed: user=${user?.uid ?? 'null'}');
      }

      if (user != null) {
        if (kDebugMode) {
          print('User logged in, initializing cloud sync');
        }
        // User logged in, we can start syncing
        _updateSyncStatus(SyncStatus.connected);
        _startRealtimeListeners();
      } else {
        if (kDebugMode) {
          print('User logged out, stopping cloud sync');
        }
        // User logged out, stop sync timers and listeners
        _cancelAllSyncTimers();
        _stopRealtimeListeners();
        _updateSyncStatus(SyncStatus.disconnected);
      }
    });

    // Check if user is already authenticated (handles case where auth happened before initialization)
    if (_authService.isAuthenticated) {
      if (kDebugMode) {
        print('User already authenticated, starting sync immediately');
        print('Current user: ${_authService.currentUser?.uid}');
      }
      _updateSyncStatus(SyncStatus.connected);
      _startRealtimeListeners();
    }

    if (kDebugMode) {
      print('Auth state listener set up');
    }
  }

  /// Update sync status and notify listeners
  void _updateSyncStatus(SyncStatus status) {
    _currentSyncStatus = status;
    _syncStatusController.add(status);
    if (kDebugMode) {
      print('Sync status updated to: $status');
    }
  }

  /// Upload all local data to Firebase (for new account creation)
  Future<SyncResult> uploadAllLocalData() async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }

    try {
      _updateSyncStatus(SyncStatus.syncing);

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _updateSyncStatus(SyncStatus.error);
        return SyncResult.failure('User not authenticated');
      }
      final userId = currentUser.uid;

      // Upload characters
      final characters = await CharacterService.loadAllCharacters();
      final characterMaps = characters.map((c) => c.toJson()).toList();
      await _uploadCharacters(userId, characterMaps);

      // Upload diaries - we need to get all diaries for all characters
      final diaries = <Map<String, dynamic>>[];
      final charactersList = await CharacterService.loadAllCharacters();
      for (final character in charactersList) {
        final characterDiaries =
            await DiaryService.loadDiaryEntriesForCharacter(character.id);
        diaries.addAll(characterDiaries.map((d) => d.toJson()));
      }
      await _uploadDiaries(userId, diaries);

      _updateSyncStatus(SyncStatus.connected);

      if (kDebugMode) {
        print('Successfully uploaded all local data to Firebase');
      }

      return SyncResult.success('All data uploaded successfully');
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
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
      _updateSyncStatus(SyncStatus.syncing);

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _updateSyncStatus(SyncStatus.error);
        return SyncResult.failure('User not authenticated');
      }
      final userId = currentUser.uid;

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

      _updateSyncStatus(SyncStatus.connected);

      if (kDebugMode) {
        print('Successfully downloaded all data from Firebase');
      }

      return SyncResult.success('All data downloaded successfully');
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      if (kDebugMode) {
        print('Error downloading data: $e');
      }
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
    required Future<void> Function(
      String userId,
      List<Map<String, dynamic>> data,
    )
    uploadData,
    required String entityName,
  }) async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }

    try {
      _updateSyncStatus(SyncStatus.syncing);

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _updateSyncStatus(SyncStatus.error);
        return SyncResult.failure('User not authenticated');
      }
      final userId = currentUser.uid;
      if (kDebugMode) {
        print('=== Starting $entityName sync for user: $userId ===');
      }

      final dataMaps = await loadData();
      if (kDebugMode) {
        print('Loaded ${dataMaps.length} $entityName from local storage');
      }

      await uploadData(userId, dataMaps);

      _updateSyncStatus(SyncStatus.connected);

      if (kDebugMode) {
        print('Successfully synced ${dataMaps.length} $entityName to Firebase');
      }

      return SyncResult.success('$entityName synced successfully');
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      if (kDebugMode) {
        print('Error syncing $entityName: $e');
      }
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
          final characterDiaries =
              await DiaryService.loadDiaryEntriesForCharacter(character.id);
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return false;
      }
      final userId = currentUser.uid;
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
      return cloudCharacterIds.any(
        (cloudId) => !localCharacterIds.contains(cloudId),
      );
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
  Future<void> _uploadCharacters(
    String userId,
    List<Map<String, dynamic>> characters,
  ) async {
    debugPrint('=== Starting character upload to Firebase ===');
    debugPrint('Number of characters to upload: ${characters.length}');

    for (int i = 0; i < characters.length; i++) {
      final characterName =
          characters[i]['stats']?['name']?['value'] ?? 'Unknown';
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
    debugPrint(
      'Found ${existingDocs.docs.length} existing documents to delete',
    );
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    // Add new characters
    debugPrint('Adding new characters to Firebase...');
    for (final character in characters) {
      final characterId =
          character['stats']?['id']?['value']?.toString() ??
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
  Future<void> _uploadDiaries(
    String userId,
    List<Map<String, dynamic>> diaries,
  ) async {
    if (kDebugMode) {
      print('=== Starting diary upload to Firebase ===');
      print('Number of diaries to upload: ${diaries.length}');
    }

    for (int i = 0; i < diaries.length; i++) {
      final diaryTitle = diaries[i]['data']?['title']?['value'] ?? 'Unknown';
      final diaryId = diaries[i]['data']?['id']?['value'] ?? 'Unknown';
      if (kDebugMode) {
        print('Diary ${i + 1}: $diaryTitle (ID: $diaryId)');
      }
    }

    final batch = _firestore.batch();
    final diariesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(_diariesCollection);

    // Clear existing diaries
    final existingDocs = await diariesRef.get();
    if (kDebugMode) {
      print('Clearing existing diaries from Firebase...');
      print(
        'Found ${existingDocs.docs.length} existing diary documents to delete',
      );
    }
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    // Add new diaries
    if (kDebugMode) {
      print('Adding new diaries to Firebase...');
    }
    for (final diary in diaries) {
      final diaryId =
          diary['data']?['id']?['value']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final diaryTitle = diary['data']?['title']?['value'] ?? 'Unknown';
      if (kDebugMode) {
        print('Adding diary: $diaryTitle with ID: $diaryId');
      }
      final docRef = diariesRef.doc(diaryId);
      batch.set(docRef, {
        'data': diary,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (kDebugMode) {
      print('Committing diary batch operation...');
    }
    await batch.commit();
    if (kDebugMode) {
      print('=== Diary upload completed successfully ===');
    }
  }

  /// Download characters from Firebase
  Future<List<Map<String, dynamic>>> _downloadCharacters(String userId) async {
    final querySnapshot =
        await _firestore
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
    final querySnapshot =
        await _firestore
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
    final querySnapshot =
        await _firestore
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
    final querySnapshot =
        await _firestore
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
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return false;
      }
      final userId = currentUser.uid;

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

      return charactersSnapshot.docs.isNotEmpty ||
          diariesSnapshot.docs.isNotEmpty;
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
      _updateSyncStatus(SyncStatus.syncing);

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        _updateSyncStatus(SyncStatus.error);
        return SyncResult.failure('User not authenticated');
      }
      final userId = currentUser.uid;

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

      _updateSyncStatus(SyncStatus.connected);

      if (kDebugMode) {
        print('Successfully deleted all cloud data for user: $userId');
      }

      return SyncResult.success('All cloud data deleted successfully');
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
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

  /// Remove device from tracking (for example, when user logs out from a device)
  Future<SyncResult> removeDevice(String deviceId) async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        return SyncResult.failure('User not authenticated');
      }
      final userId = currentUser.uid;

      // Remove device from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_devicesCollection)
          .doc(deviceId)
          .delete();

      if (kDebugMode) {
        print('Device removed from tracking: $deviceId');
      }

      return SyncResult.success('Device removed successfully');
    } catch (e) {
      if (kDebugMode) {
        print('Error removing device: $e');
      }
      return SyncResult.failure('Failed to remove device: $e');
    }
  }

  /// Start real-time listeners for cross-device synchronization
  void _startRealtimeListeners() {
    if (kDebugMode) {
      print('=== _startRealtimeListeners() ===');
      print('Is authenticated: ${_authService.isAuthenticated}');
    }

    if (!_authService.isAuthenticated) {
      if (kDebugMode) {
        print('Cannot start listeners: User not authenticated');
      }
      return;
    }

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      if (kDebugMode) {
        print('Cannot start listeners: currentUser became null');
      }
      return;
    }
    final userId = currentUser.uid;

    if (kDebugMode) {
      print('Starting real-time listeners for user: $userId');
    }

    // Start characters listener
    if (kDebugMode) {
      print('Setting up characters listener...');
    }

    _charactersListener = _firestore
        .collection('users')
        .doc(userId)
        .collection(_charactersCollection)
        .snapshots()
        .listen(
          (snapshot) {
            if (kDebugMode) {
              print('!!! CHARACTERS SNAPSHOT RECEIVED !!!');
              print(
                'Characters snapshot received: ${snapshot.docs.length} documents',
              );
              print('Doc changes: ${snapshot.docChanges.length}');
            }
            _handleCharactersSnapshot(snapshot);
          },
          onError: (error) {
            if (kDebugMode) {
              print('!!! CHARACTERS LISTENER ERROR !!!');
              print('Error in characters listener: $error');
            }
          },
        );

    if (kDebugMode) {
      print('Characters listener set up successfully');
    }

    // Start diaries listener
    if (kDebugMode) {
      print('Setting up diaries listener...');
    }

    _diariesListener = _firestore
        .collection('users')
        .doc(userId)
        .collection(_diariesCollection)
        .snapshots()
        .listen(
          (snapshot) {
            if (kDebugMode) {
              print('!!! DIARIES SNAPSHOT RECEIVED !!!');
              print(
                'Diaries snapshot received: ${snapshot.docs.length} documents',
              );
              print('Doc changes: ${snapshot.docChanges.length}');
            }
            _handleDiariesSnapshot(snapshot);
          },
          onError: (error) {
            if (kDebugMode) {
              print('!!! DIARIES LISTENER ERROR !!!');
              print('Error in diaries listener: $error');
            }
          },
        );

    if (kDebugMode) {
      print('Diaries listener set up successfully');
      print('Started real-time listeners for cross-device sync');
    }
  }

  /// Stop real-time listeners
  void _stopRealtimeListeners() {
    _charactersListener?.cancel();
    _charactersListener = null;
    _diariesListener?.cancel();
    _diariesListener = null;

    // Clear caches when stopping listeners
    _lastKnownCharacters.clear();
    _lastKnownDiaries.clear();

    // Reset initial snapshot flags
    _charactersInitialSnapshotProcessed = false;
    _diariesInitialSnapshotProcessed = false;

    if (kDebugMode) {
      print('Stopped real-time listeners and cleared caches');
    }
  }

  /// Handle characters snapshot changes
  Future<void> _handleCharactersSnapshot(QuerySnapshot snapshot) async {
    if (kDebugMode) {
      print('=== CHARACTER SNAPSHOT HANDLER ===');
      print('Snapshot docChanges length: ${snapshot.docChanges.length}');
      print('Snapshot docs length: ${snapshot.docs.length}');
      print('Initial snapshot processed: $_charactersInitialSnapshotProcessed');
    }

    if (snapshot.docChanges.isEmpty) {
      if (kDebugMode) {
        print('No doc changes, returning early');
      }
      return;
    }

    try {
      bool hasActualDataChanges = false;

      // Check each document change to see if actual data changed (not just metadata)
      for (final change in snapshot.docChanges) {
        final docId = change.doc.id;
        final currentData = change.doc.data() as Map<String, dynamic>;
        final characterData = currentData['data'] as Map<String, dynamic>?;

        if (characterData == null) {
          if (kDebugMode) {
            print('Document $docId has no data field, skipping');
          }
          continue;
        }

        // Compare with cached data
        final lastKnownData = _lastKnownCharacters[docId];
        if (lastKnownData == null) {
          // First time seeing this document
          if (kDebugMode) {
            print('New character detected: $docId');
          }
          // Only count as change if this is NOT the initial snapshot
          if (_charactersInitialSnapshotProcessed) {
            hasActualDataChanges = true;
          }
          _lastKnownCharacters[docId] = characterData;
        } else {
          // Compare the actual data (ignoring metadata like updatedAt)
          if (!_mapsEqual(lastKnownData, characterData)) {
            if (kDebugMode) {
              print('Character data changed: $docId');
              print('Previous: $lastKnownData');
              print('Current: $characterData');
            }
            hasActualDataChanges = true;
            _lastKnownCharacters[docId] = characterData;
          } else {
            if (kDebugMode) {
              print(
                'Character $docId metadata changed but data is the same, ignoring',
              );
            }
          }
        }
      }

      // Mark initial snapshot as processed
      if (!_charactersInitialSnapshotProcessed) {
        _charactersInitialSnapshotProcessed = true;
        if (kDebugMode) {
          print('Initial characters snapshot processed, cache populated');
        }
        // Don't trigger status change on initial snapshot
        return;
      }

      // Only trigger status change if actual data changed
      if (hasActualDataChanges) {
        if (kDebugMode) {
          print(
            'Detected actual character changes in Firestore, setting changesAvailable status',
          );
        }

        // Set status to indicate changes are available for manual sync
        _updateSyncStatus(SyncStatus.changesAvailable);

        if (kDebugMode) {
          print('Status set to changesAvailable - user can manually sync now');
        }
      } else {
        if (kDebugMode) {
          print('No actual character data changes detected, ignoring snapshot');
        }
        _updateSyncStatus(SyncStatus.connected);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling characters snapshot: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    }
  }

  /// Handle diaries snapshot changes
  Future<void> _handleDiariesSnapshot(QuerySnapshot snapshot) async {
    if (kDebugMode) {
      print('=== DIARY SNAPSHOT HANDLER ===');
      print('Snapshot docChanges length: ${snapshot.docChanges.length}');
      print('Snapshot docs length: ${snapshot.docs.length}');
      print('Initial snapshot processed: $_diariesInitialSnapshotProcessed');
    }

    if (snapshot.docChanges.isEmpty) {
      if (kDebugMode) {
        print('No diary doc changes, returning early');
      }
      return;
    }

    try {
      bool hasActualDataChanges = false;

      // Check each document change to see if actual data changed (not just metadata)
      for (final change in snapshot.docChanges) {
        final docId = change.doc.id;
        final currentData = change.doc.data() as Map<String, dynamic>;
        final diaryData = currentData['data'] as Map<String, dynamic>?;

        if (diaryData == null) {
          if (kDebugMode) {
            print('Document $docId has no data field, skipping');
          }
          continue;
        }

        // Compare with cached data
        final lastKnownData = _lastKnownDiaries[docId];
        if (lastKnownData == null) {
          // First time seeing this document
          if (kDebugMode) {
            print('New diary detected: $docId');
          }
          // Only count as change if this is NOT the initial snapshot
          if (_diariesInitialSnapshotProcessed) {
            hasActualDataChanges = true;
          }
          _lastKnownDiaries[docId] = diaryData;
        } else {
          // Compare the actual data (ignoring metadata like updatedAt)
          if (!_mapsEqual(lastKnownData, diaryData)) {
            if (kDebugMode) {
              print('Diary data changed: $docId');
              print('Previous: $lastKnownData');
              print('Current: $diaryData');
            }
            hasActualDataChanges = true;
            _lastKnownDiaries[docId] = diaryData;
          } else {
            if (kDebugMode) {
              print(
                'Diary $docId metadata changed but data is the same, ignoring',
              );
            }
          }
        }
      }

      // Mark initial snapshot as processed
      if (!_diariesInitialSnapshotProcessed) {
        _diariesInitialSnapshotProcessed = true;
        if (kDebugMode) {
          print('Initial diaries snapshot processed, cache populated');
        }
        // Don't trigger status change on initial snapshot
        return;
      }

      // Only trigger status change if actual data changed
      if (hasActualDataChanges) {
        if (kDebugMode) {
          print(
            'Detected actual diary changes in Firestore, setting changesAvailable status',
          );
        }

        // Set status to indicate changes are available for manual sync
        _updateSyncStatus(SyncStatus.changesAvailable);

        if (kDebugMode) {
          print('Status set to changesAvailable - user can manually sync now');
        }
      } else {
        if (kDebugMode) {
          print('No actual diary data changes detected, ignoring snapshot');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling diaries snapshot: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    }
  }

  /// Deep comparison of two maps to detect actual data changes
  bool _mapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) {
      return false;
    }

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) {
        return false;
      }

      final value1 = map1[key];
      final value2 = map2[key];

      if (value1 is Map<String, dynamic> && value2 is Map<String, dynamic>) {
        if (!_mapsEqual(value1, value2)) {
          return false;
        }
      } else if (value1 is List && value2 is List) {
        if (!_listsEqual(value1, value2)) {
          return false;
        }
      } else if (value1 != value2) {
        return false;
      }
    }

    return true;
  }

  /// Deep comparison of two lists
  bool _listsEqual(List list1, List list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      final value1 = list1[i];
      final value2 = list2[i];

      if (value1 is Map<String, dynamic> && value2 is Map<String, dynamic>) {
        if (!_mapsEqual(value1, value2)) {
          return false;
        }
      } else if (value1 is List && value2 is List) {
        if (!_listsEqual(value1, value2)) {
          return false;
        }
      } else if (value1 != value2) {
        return false;
      }
    }

    return true;
  }

  /// Manually sync changes when user taps cloud button in changesAvailable state
  Future<SyncResult> manualSyncFromCloud() async {
    if (!_authService.isAuthenticated) {
      return SyncResult.failure('User not authenticated');
    }

    try {
      _updateSyncStatus(SyncStatus.syncing);

      if (kDebugMode) {
        print('Manual sync from cloud triggered by user');
      }

      // Download all data from cloud
      final result = await downloadAllData();

      // Clear caches after manual sync so next comparison is against new data
      _lastKnownCharacters.clear();
      _lastKnownDiaries.clear();

      if (kDebugMode) {
        print('Cleared caches after manual sync');
      }

      // Reset to connected status after manual sync
      _updateSyncStatus(SyncStatus.connected);

      return result;
    } catch (e) {
      _updateSyncStatus(SyncStatus.error);
      if (kDebugMode) {
        print('Error during manual sync: $e');
      }
      return SyncResult.failure('Manual sync failed: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    _cancelAllSyncTimers();
    _stopRealtimeListeners();
    _syncStatusController.close();
  }
}

/// Sync type enumeration
enum SyncType { characters, diaries }

/// Sync status enumeration
enum SyncStatus {
  disconnected,
  connected,
  syncing,
  changesAvailable, // New status: changes detected, ready for manual sync
  error,
}

/// Result of sync operation
class SyncResult {
  final bool success;
  final String? errorMessage;
  final String? successMessage;

  SyncResult.success(this.successMessage) : success = true, errorMessage = null;
  SyncResult.failure(this.errorMessage)
    : success = false,
      successMessage = null;

  @override
  String toString() {
    if (success) {
      return 'SyncResult.success(message: $successMessage)';
    } else {
      return 'SyncResult.failure(error: $errorMessage)';
    }
  }
}
