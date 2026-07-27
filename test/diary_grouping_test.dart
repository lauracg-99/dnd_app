import 'package:flutter_test/flutter_test.dart';
import 'package:dnd_app/models/diary_model.dart';
import 'package:dnd_app/models/diary_group_model.dart';

void main() {
  group('DiaryEntry Group ID Tests', () {
    test('DiaryEntry with groupId should serialize correctly', () {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: 'test_id',
        characterId: 'char_123',
        title: 'Test Entry',
        content: 'Test content',
        groupId: 'group_456',
        createdAt: now,
        updatedAt: now,
      );

      final json = entry.toJson();
      
      expect(json['resource_id'], 'diary_entry');
      expect(json['data']['group_id']['value'], 'group_456');
    });

    test('DiaryEntry without groupId should serialize with empty string', () {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: 'test_id',
        characterId: 'char_123',
        title: 'Test Entry',
        content: 'Test content',
        groupId: null,
        createdAt: now,
        updatedAt: now,
      );

      final json = entry.toJson();
      
      expect(json['data']['group_id']['value'], '');
    });

    test('DiaryEntry should deserialize groupId correctly', () {
      final now = DateTime.now();
      final json = {
        'resource_id': 'diary_entry',
        'data': {
          'id': {'value': 'test_id'},
          'character_id': {'value': 'char_123'},
          'title': {'value': 'Test Entry'},
          'content': {'value': 'Test content'},
          'group_id': {'value': 'group_456'},
          'created_at': {'value': now.toIso8601String()},
          'updated_at': {'value': now.toIso8601String()},
        },
      };

      final entry = DiaryEntry.fromJson(json);
      
      expect(entry.groupId, 'group_456');
    });

    test('DiaryEntry should deserialize null groupId when empty string', () {
      final now = DateTime.now();
      final json = {
        'resource_id': 'diary_entry',
        'data': {
          'id': {'value': 'test_id'},
          'character_id': {'value': 'char_123'},
          'title': {'value': 'Test Entry'},
          'content': {'value': 'Test content'},
          'group_id': {'value': ''},
          'created_at': {'value': now.toIso8601String()},
          'updated_at': {'value': now.toIso8601String()},
        },
      };

      final entry = DiaryEntry.fromJson(json);
      
      expect(entry.groupId, null);
    });

    test('DiaryEntry should deserialize null groupId when field missing', () {
      final now = DateTime.now();
      final json = {
        'resource_id': 'diary_entry',
        'data': {
          'id': {'value': 'test_id'},
          'character_id': {'value': 'char_123'},
          'title': {'value': 'Test Entry'},
          'content': {'value': 'Test content'},
          'created_at': {'value': now.toIso8601String()},
          'updated_at': {'value': now.toIso8601String()},
        },
      };

      final entry = DiaryEntry.fromJson(json);
      
      expect(entry.groupId, null);
    });

    test('DiaryEntry copyWith should update groupId', () {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: 'test_id',
        characterId: 'char_123',
        title: 'Test Entry',
        content: 'Test content',
        groupId: 'group_456',
        createdAt: now,
        updatedAt: now,
      );

      final updated = entry.copyWith(groupId: 'group_789');
      
      expect(updated.groupId, 'group_789');
      expect(updated.id, entry.id);
      expect(updated.title, entry.title);
    });

    test('DiaryEntry copyWith should preserve groupId when not provided', () {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: 'test_id',
        characterId: 'char_123',
        title: 'Test Entry',
        content: 'Test content',
        groupId: 'group_456',
        createdAt: now,
        updatedAt: now,
      );

      final updated = entry.copyWith(title: 'Updated Title');
      
      expect(updated.groupId, 'group_456');
      expect(updated.title, 'Updated Title');
    });
  });

  group('DiaryGroup Model Tests', () {
    test('DiaryGroup should serialize correctly', () {
      final now = DateTime.now();
      final group = DiaryGroup(
        id: 'group_123',
        characterId: 'char_456',
        name: 'Session 1',
        createdAt: now,
        updatedAt: now,
      );

      final json = group.toJson();
      
      expect(json['resource_id'], 'diary_group');
      expect(json['data']['id']['value'], 'group_123');
      expect(json['data']['character_id']['value'], 'char_456');
      expect(json['data']['name']['value'], 'Session 1');
    });

    test('DiaryGroup should deserialize correctly', () {
      final now = DateTime.now();
      final json = {
        'resource_id': 'diary_group',
        'data': {
          'id': {'value': 'group_123'},
          'character_id': {'value': 'char_456'},
          'name': {'value': 'Session 1'},
          'created_at': {'value': now.toIso8601String()},
          'updated_at': {'value': now.toIso8601String()},
        },
      };

      final group = DiaryGroup.fromJson(json);
      
      expect(group.id, 'group_123');
      expect(group.characterId, 'char_456');
      expect(group.name, 'Session 1');
    });

    test('DiaryGroup copyWith should update fields', () {
      final now = DateTime.now();
      final group = DiaryGroup(
        id: 'group_123',
        characterId: 'char_456',
        name: 'Session 1',
        createdAt: now,
        updatedAt: now,
      );

      final updated = group.copyWith(name: 'Session 2');
      
      expect(updated.name, 'Session 2');
      expect(updated.id, group.id);
      expect(updated.characterId, group.characterId);
    });

    test('DiaryGroup withUpdatedTimestamp should update updatedAt', () {
      final now = DateTime.now();
      final group = DiaryGroup(
        id: 'group_123',
        characterId: 'char_456',
        name: 'Session 1',
        createdAt: now,
        updatedAt: now,
      );

      // Wait a bit to ensure timestamp difference
      final updated = group.withUpdatedTimestamp();
      
      expect(updated.updatedAt.isAfter(now), true);
      expect(updated.id, group.id);
      expect(updated.name, group.name);
    });
  });

  group('Backward Compatibility Tests', () {
    test('Old diary entries without group_id should load with null groupId', () {
      final now = DateTime.now();
      // Simulate old JSON format without group_id field
      final oldJson = {
        'resource_id': 'diary_entry',
        'data': {
          'id': {'value': 'test_id'},
          'character_id': {'value': 'char_123'},
          'title': {'value': 'Test Entry'},
          'content': {'value': 'Test content'},
          'created_at': {'value': now.toIso8601String()},
          'updated_at': {'value': now.toIso8601String()},
        },
      };

      final entry = DiaryEntry.fromJson(oldJson);
      
      expect(entry.groupId, null);
      expect(entry.title, 'Test Entry');
      expect(entry.content, 'Test content');
    });

    test('New diary entries with group_id should load correctly', () {
      final now = DateTime.now();
      // Simulate new JSON format with group_id field
      final newJson = {
        'resource_id': 'diary_entry',
        'data': {
          'id': {'value': 'test_id'},
          'character_id': {'value': 'char_123'},
          'title': {'value': 'Test Entry'},
          'content': {'value': 'Test content'},
          'group_id': {'value': 'group_456'},
          'created_at': {'value': now.toIso8601String()},
          'updated_at': {'value': now.toIso8601String()},
        },
      };

      final entry = DiaryEntry.fromJson(newJson);
      
      expect(entry.groupId, 'group_456');
      expect(entry.title, 'Test Entry');
    });

    test('Old entries can be updated with groupId using copyWith', () {
      final now = DateTime.now();
      final oldEntry = DiaryEntry(
        id: 'test_id',
        characterId: 'char_123',
        title: 'Test Entry',
        content: 'Test content',
        groupId: null,
        createdAt: now,
        updatedAt: now,
      );

      final updatedEntry = oldEntry.copyWith(groupId: 'group_789');
      
      expect(updatedEntry.groupId, 'group_789');
      expect(updatedEntry.title, oldEntry.title);
      expect(updatedEntry.content, oldEntry.content);
    });
  });
}
