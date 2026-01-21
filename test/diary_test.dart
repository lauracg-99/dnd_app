import 'package:flutter_test/flutter_test.dart';
import '../lib/models/diary_model.dart';
import '../lib/services/diary_service.dart';

void main() {
  group('DiaryEntry Model Tests', () {
    test('DiaryEntry should create with required fields', () {
      final now = DateTime.now();
      final diaryEntry = DiaryEntry(
        id: 'test_id',
        characterId: 'character_1',
        title: 'Test Entry',
        content: 'Test content',
        createdAt: now,
        updatedAt: now,
      );

      expect(diaryEntry.id, 'test_id');
      expect(diaryEntry.characterId, 'character_1');
      expect(diaryEntry.title, 'Test Entry');
      expect(diaryEntry.content, 'Test content');
      expect(diaryEntry.createdAt, now);
      expect(diaryEntry.updatedAt, now);
    });

    test('DiaryEntry copyWith should update specified fields', () {
      final now = DateTime.now();
      final originalEntry = DiaryEntry(
        id: 'test_id',
        characterId: 'character_1',
        title: 'Original Title',
        content: 'Original content',
        createdAt: now,
        updatedAt: now,
      );

      final updatedEntry = originalEntry.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
      );

      expect(updatedEntry.id, 'test_id');
      expect(updatedEntry.characterId, 'character_1');
      expect(updatedEntry.title, 'Updated Title');
      expect(updatedEntry.content, 'Updated content');
      expect(updatedEntry.createdAt, now);
      expect(updatedEntry.updatedAt, now);
    });

    test('DiaryEntry toJson should serialize correctly', () {
      final now = DateTime.now();
      final diaryEntry = DiaryEntry(
        id: 'test_id',
        characterId: 'character_1',
        title: 'Test Entry',
        content: 'Test content',
        createdAt: now,
        updatedAt: now,
      );

      final json = diaryEntry.toJson();

      expect(json['resource_id'], 'diary_entry');
      expect(json['data']['id']['value'], 'test_id');
      expect(json['data']['character_id']['value'], 'character_1');
      expect(json['data']['title']['value'], 'Test Entry');
      expect(json['data']['content']['value'], 'Test content');
      expect(json['data']['created_at']['value'], now.toIso8601String());
      expect(json['data']['updated_at']['value'], now.toIso8601String());
    });

    test('DiaryEntry fromJson should deserialize correctly', () {
      final now = DateTime.now();
      final json = {
        'resource_id': 'diary_entry',
        'data': {
          'id': {'value': 'test_id'},
          'character_id': {'value': 'character_1'},
          'title': {'value': 'Test Entry'},
          'content': {'value': 'Test content'},
          'created_at': {'value': now.toIso8601String()},
          'updated_at': {'value': now.toIso8601String()},
        },
      };

      final diaryEntry = DiaryEntry.fromJson(json);

      expect(diaryEntry.id, 'test_id');
      expect(diaryEntry.characterId, 'character_1');
      expect(diaryEntry.title, 'Test Entry');
      expect(diaryEntry.content, 'Test content');
      expect(diaryEntry.createdAt, now);
      expect(diaryEntry.updatedAt, now);
    });
  });

  group('DiaryService Tests', () {
    const testCharacterId = 'test_character_1';
    const testDiaryId = 'test_diary_1';

    setUp(() async {
      // Clear memory cache before each test
      DiaryService.clearMemoryCache();
      // Initialize storage for testing
      await DiaryService.initializeStorage();
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await DiaryService.deleteDiaryEntry(testCharacterId, testDiaryId);
      } catch (e) {
        // Ignore cleanup errors
      }
      DiaryService.clearMemoryCache();
    });

    test('createDiaryEntry should create new entry', () async {
      final diaryEntry = await DiaryService.createDiaryEntry(
        characterId: testCharacterId,
        title: 'Test Entry',
        content: 'Test content',
      );

      expect(diaryEntry.characterId, testCharacterId);
      expect(diaryEntry.title, 'Test Entry');
      expect(diaryEntry.content, 'Test content');
      expect(diaryEntry.id, isNotEmpty);
      expect(diaryEntry.createdAt, isNotNull);
      expect(diaryEntry.updatedAt, isNotNull);
    });

    test('saveDiaryEntry should update existing entry', () async {
      // Create initial entry
      final originalEntry = await DiaryService.createDiaryEntry(
        characterId: testCharacterId,
        title: 'Original Title',
        content: 'Original content',
      );

      // Update the entry
      final updatedEntry = originalEntry.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
      );

      await DiaryService.saveDiaryEntry(updatedEntry);

      // Load and verify the update
      final entries = await DiaryService.loadDiaryEntriesForCharacter(testCharacterId);
      final loadedEntry = entries.firstWhere((e) => e.id == originalEntry.id);

      expect(loadedEntry.title, 'Updated Title');
      expect(loadedEntry.content, 'Updated content');
      expect(loadedEntry.updatedAt.isAfter(originalEntry.updatedAt), isTrue);
    });

    test('loadDiaryEntriesForCharacter should return entries for specific character', () async {
      // Create entries for two different characters
      final entry1 = await DiaryService.createDiaryEntry(
        characterId: 'character_1',
        title: 'Entry 1',
        content: 'Content 1',
      );

      final entry2 = await DiaryService.createDiaryEntry(
        characterId: 'character_2',
        title: 'Entry 2',
        content: 'Content 2',
      );

      final entry3 = await DiaryService.createDiaryEntry(
        characterId: 'character_1',
        title: 'Entry 3',
        content: 'Content 3',
      );

      // Load entries for character_1
      final character1Entries = await DiaryService.loadDiaryEntriesForCharacter('character_1');
      
      // Should contain entry1 and entry3, but not entry2
      expect(character1Entries.length, 2);
      expect(character1Entries.any((e) => e.id == entry1.id), isTrue);
      expect(character1Entries.any((e) => e.id == entry3.id), isTrue);
      expect(character1Entries.any((e) => e.id == entry2.id), isFalse);

      // Load entries for character_2
      final character2Entries = await DiaryService.loadDiaryEntriesForCharacter('character_2');
      
      // Should contain only entry2
      expect(character2Entries.length, 1);
      expect(character2Entries.first.id, entry2.id);
    });

    test('deleteDiaryEntry should remove entry', () async {
      // Create an entry
      final entry = await DiaryService.createDiaryEntry(
        characterId: testCharacterId,
        title: 'To Delete',
        content: 'This will be deleted',
      );

      // Verify it exists
      var entries = await DiaryService.loadDiaryEntriesForCharacter(testCharacterId);
      expect(entries.any((e) => e.id == entry.id), isTrue);

      // Delete it
      await DiaryService.deleteDiaryEntry(testCharacterId, entry.id);

      // Verify it's gone
      entries = await DiaryService.loadDiaryEntriesForCharacter(testCharacterId);
      expect(entries.any((e) => e.id == entry.id), isFalse);
    });

    test('searchDiaryEntries should filter by title and content', () {
      final now = DateTime.now();
      final entries = [
        DiaryEntry(
          id: '1',
          characterId: 'char1',
          title: 'Adventure in the Forest',
          content: 'We fought goblins in the dark woods.',
          createdAt: now,
          updatedAt: now,
        ),
        DiaryEntry(
          id: '2',
          characterId: 'char1',
          title: 'Meeting the King',
          content: 'The king gave us a quest to find the artifact.',
          createdAt: now,
          updatedAt: now,
        ),
        DiaryEntry(
          id: '3',
          characterId: 'char1',
          title: 'Dragon Battle',
          content: 'The red dragon breathed fire on us.',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      // Search by title
      var results = DiaryService.searchDiaryEntries(entries, 'dragon');
      expect(results.length, 1);
      expect(results.first.title, 'Dragon Battle');

      // Search by content
      results = DiaryService.searchDiaryEntries(entries, 'goblins');
      expect(results.length, 1);
      expect(results.first.title, 'Adventure in the Forest');

      // Search with no results
      results = DiaryService.searchDiaryEntries(entries, 'unicorn');
      expect(results.length, 0);

      // Empty search should return all
      results = DiaryService.searchDiaryEntries(entries, '');
      expect(results.length, 3);
    });

    test('exportDiaryEntry should return JSON string', () async {
      final entry = await DiaryService.createDiaryEntry(
        characterId: testCharacterId,
        title: 'Export Test',
        content: 'Content to export',
      );

      final jsonString = DiaryService.exportDiaryEntry(entry);
      
      expect(jsonString, isA<String>());
      expect(jsonString.contains('Export Test'), isTrue);
      expect(jsonString.contains('Content to export'), isTrue);
    });

    test('importDiaryEntry should create new entry with new ID', () async {
      final originalEntry = await DiaryService.createDiaryEntry(
        characterId: testCharacterId,
        title: 'Original Entry',
        content: 'Original content',
      );

      final jsonString = DiaryService.exportDiaryEntry(originalEntry);
      
      final importedEntry = await DiaryService.importDiaryEntry(jsonString, testCharacterId);

      expect(importedEntry.title, originalEntry.title);
      expect(importedEntry.content, originalEntry.content);
      expect(importedEntry.characterId, testCharacterId);
      expect(importedEntry.id, isNot(equals(originalEntry.id))); // Should have new ID
      expect(importedEntry.createdAt, isNot(equals(originalEntry.createdAt))); // Should have new timestamp
    });
  });

  group('Diary Integration Tests', () {
    test('Complete diary workflow should work end-to-end', () async {
      const characterId = 'integration_test_character';
      
      // Clean up any existing data
      DiaryService.clearMemoryCache();
      await DiaryService.initializeStorage();

      try {
        // 1. Create multiple diary entries
        final entry1 = await DiaryService.createDiaryEntry(
          characterId: characterId,
          title: 'First Adventure',
          content: 'Our party set out from the village at dawn.',
        );

        final entry2 = await DiaryService.createDiaryEntry(
          characterId: characterId,
          title: 'The Dragon\'s Lair',
          content: 'We found the cave entrance behind the waterfall.',
        );

        // 2. Load all entries for the character
        final entries = await DiaryService.loadDiaryEntriesForCharacter(characterId);
        expect(entries.length, 2);

        // 3. Verify entries are sorted by updatedAt (most recent first)
        expect(entries.first.updatedAt.isAfter(entries.last.updatedAt), isTrue);

        // 4. Update an entry
        final updatedEntry1 = entry1.copyWith(
          content: 'Our party set out from the village at dawn. The weather was perfect.',
        );
        await DiaryService.saveDiaryEntry(updatedEntry1);

        // 5. Verify the update
        final updatedEntries = await DiaryService.loadDiaryEntriesForCharacter(characterId);
        final loadedEntry1 = updatedEntries.firstWhere((e) => e.id == entry1.id);
        expect(loadedEntry1.content, contains('weather was perfect'));

        // 6. Search functionality
        final searchResults = DiaryService.searchDiaryEntries(updatedEntries, 'dragon');
        expect(searchResults.length, 1);
        expect(searchResults.first.title, 'The Dragon\'s Lair');

        // 7. Delete an entry
        await DiaryService.deleteDiaryEntry(characterId, entry2.id);

        // 8. Verify deletion
        final finalEntries = await DiaryService.loadDiaryEntriesForCharacter(characterId);
        expect(finalEntries.length, 1);
        expect(finalEntries.first.id, entry1.id);

        // 9. Export and import test
        final exportString = DiaryService.exportDiaryEntry(finalEntries.first);
        final importedEntry = await DiaryService.importDiaryEntry(exportString, characterId);
        
        expect(importedEntry.title, finalEntries.first.title);
        expect(importedEntry.content, finalEntries.first.content);
        expect(importedEntry.id, isNot(equals(finalEntries.first.id)));

      } finally {
        // Clean up test data
        try {
          final entries = await DiaryService.loadDiaryEntriesForCharacter(characterId);
          for (final entry in entries) {
            await DiaryService.deleteDiaryEntry(characterId, entry.id);
          }
        } catch (e) {
          // Ignore cleanup errors
        }
        DiaryService.clearMemoryCache();
      }
    });
  });
}
