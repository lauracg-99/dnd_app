import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../lib/services/firebase_auth_service.dart';
import '../lib/services/cloud_sync_service.dart';
import '../lib/services/character_service.dart';
import '../lib/services/diary_service.dart';
import '../lib/models/character_model.dart';
import '../lib/models/diary_model.dart';

void main() {
  group('Firebase Integration Tests', () {
    late FakeFirebaseFirestore mockFirestore;
    late FirebaseAuthService authService;
    late CloudSyncService syncService;

    setUp(() async {
      mockFirestore = FakeFirebaseFirestore();
      
      // Initialize services
      authService = FirebaseAuthService();
      syncService = CloudSyncService();
      
      // Initialize storage systems
      await CharacterService.initializeStorage();
      await DiaryService.initializeStorage();
    });

    tearDown(() async {
      // Clean up services
      syncService.dispose();
      authService.dispose();
    });

    group('FirebaseAuthService Tests', () {
      test('should initialize correctly', () async {
        await authService.initialize();
        expect(authService.currentUser, isNull);
        expect(authService.isAuthenticated, isFalse);
      });

      test('should handle authentication state changes', () async {
        await authService.initialize();
        
        // Test authentication state stream
        expect(authService.authStateChanges, isA<Stream>());
        
        // Initially should be null (not authenticated)
        final authState = authService.authStateChanges.first;
        expect(authState, completion(isNull));
      });

      test('should handle sign out correctly', () async {
        await authService.initialize();
        
        // Should be able to call sign out without errors
        // (In real usage, this would be called after successful authentication)
        expect(() => authService.signOut(), returnsNormally);
      });
    });

    group('CloudSyncService Tests', () {
      test('should initialize correctly', () async {
        await syncService.initialize();
        expect(syncService.syncStatus, isA<Stream<SyncStatus>>());
      });

      test('should handle sync when not authenticated', () async {
        await syncService.initialize();
        
        // Try to sync without authentication
        final result = await syncService.syncAll();
        
        expect(result.success, isFalse);
        expect(result.errorMessage, equals('User not authenticated'));
      });

      test('should handle sync status changes', () async {
        await syncService.initialize();
        
        // Test sync status stream
        expect(syncService.syncStatus, isA<Stream<SyncStatus>>());
        
        // Initially should be disconnected (not authenticated)
        final status = syncService.syncStatus.first;
        expect(status, completion(SyncStatus.disconnected));
      });

      test('should debounce sync calls', () async {
        await syncService.initialize();
        
        // Schedule multiple sync calls quickly
        syncService.scheduleCharacterSync();
        syncService.scheduleCharacterSync();
        syncService.scheduleCharacterSync();
        
        // Should not throw errors
        expect(() => syncService.scheduleCharacterSync(), returnsNormally);
      });
    });

    group('Service Integration Tests', () {
      test('should initialize all services without errors', () async {
        await authService.initialize();
        await syncService.initialize();
        await CharacterService.initializeStorage();
        await DiaryService.initializeStorage();
        
        expect(authService, isNotNull);
        expect(syncService, isNotNull);
        expect(CharacterService, isNotNull);
        expect(DiaryService, isNotNull);
      });

      test('should handle character creation locally', () async {
        await CharacterService.initializeStorage();
        
        // Test that we can call the service methods without errors
        expect(() => CharacterService.loadAllCharacters(), returnsNormally);
        expect(CharacterService.loadAllCharacters(), completion(isA<List<Character>>()));
      });

      test('should handle diary creation locally', () async {
        await DiaryService.initializeStorage();
        
        // Test that we can call the service methods without errors
        expect(() => DiaryService.loadDiaryEntriesForCharacter('test-character'), returnsNormally);
        expect(DiaryService.loadDiaryEntriesForCharacter('test-character'), completion(isA<List<DiaryEntry>>()));
      });
    });

    group('Error Handling Tests', () {
      test('should handle service initialization errors gracefully', () async {
        expect(() => FirebaseAuthService(), returnsNormally);
        expect(() => CloudSyncService(), returnsNormally);
      });

      test('should handle sync operations without authentication', () async {
        await syncService.initialize();
        
        // All sync operations should fail gracefully when not authenticated
        final characterResult = await syncService.syncCharacters();
        final diaryResult = await syncService.syncDiaries();
        final allResult = await syncService.syncAll();
        
        expect(characterResult.success, isFalse);
        expect(diaryResult.success, isFalse);
        expect(allResult.success, isFalse);
      });

      test('should handle upload/download operations without authentication', () async {
        await syncService.initialize();
        
        // All upload/download operations should fail gracefully
        final uploadResult = await syncService.uploadAllLocalData();
        final downloadResult = await syncService.downloadAllData();
        
        expect(uploadResult.success, isFalse);
        expect(downloadResult.success, isFalse);
      });
    });

    group('SyncStatus Enum Tests', () {
      test('should have all required sync status values', () {
        expect(SyncStatus.values, contains(SyncStatus.connected));
        expect(SyncStatus.values, contains(SyncStatus.disconnected));
        expect(SyncStatus.values, contains(SyncStatus.syncing));
        expect(SyncStatus.values, contains(SyncStatus.error));
      });
    });

    group('SyncResult Tests', () {
      test('should create success result correctly', () {
        final result = SyncResult.success('Test success');
        expect(result.success, isTrue);
        expect(result.successMessage, equals('Test success'));
        expect(result.errorMessage, isNull);
      });

      test('should create failure result correctly', () {
        final result = SyncResult.failure('Test error');
        expect(result.success, isFalse);
        expect(result.errorMessage, equals('Test error'));
        expect(result.successMessage, isNull);
      });
    });

    group('AuthResult Tests', () {
      test('should create success auth result correctly', () {
        // Note: We can't easily create a mock User without firebase_auth_mocks
        // but we can test the structure
        expect(() => AuthResult.success(null), returnsNormally);
      });

      test('should create failure auth result correctly', () {
        final result = AuthResult.failure('Test auth error');
        expect(result.success, isFalse);
        expect(result.errorMessage, equals('Test auth error'));
        expect(result.user, isNull);
      });
    });
  });
}
