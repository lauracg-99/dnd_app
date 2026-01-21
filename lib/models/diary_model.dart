import 'package:flutter/foundation.dart';
import 'base_model.dart';

class DiaryEntry extends BaseModel {
  final String id;
  final String characterId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiaryEntry({
    required this.id,
    required this.characterId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'resource_id': 'diary_entry',
      'data': {
        'id': {'value': id},
        'character_id': {'value': characterId},
        'title': {'value': title},
        'content': {'value': content},
        'created_at': {'value': createdAt.toIso8601String()},
        'updated_at': {'value': updatedAt.toIso8601String()},
      },
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return DiaryEntry(
      id: _getValue<String>(data, 'id'),
      characterId: _getValue<String>(data, 'character_id'),
      title: _getValue<String>(data, 'title'),
      content: _getValue<String>(data, 'content'),
      createdAt: DateTime.parse(_getValue<String>(data, 'created_at')),
      updatedAt: DateTime.parse(_getValue<String>(data, 'updated_at')),
    );
  }

  DiaryEntry copyWith({
    String? id,
    String? characterId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static T _getValue<T>(Map<String, dynamic> map, String key, {T? defaultValue}) {
    try {
      if (!map.containsKey(key)) {
        if (defaultValue != null) return defaultValue;
        throw ArgumentError('Missing required field: $key');
      }
      
      final value = map[key];
      
      if (value == null) {
        if (defaultValue != null) return defaultValue;
        throw ArgumentError('Field $key is null and no default value provided');
      }
      
      if (value is Map && value.containsKey('value')) {
        final nestedValue = value['value'];
        if (nestedValue == null || nestedValue == '') return defaultValue as T;
        return nestedValue as T;
      }
      
      return value as T;
    } catch (e) {
      if (defaultValue != null) return defaultValue;
      rethrow;
    }
  }

  static T? _getValueNullable<T>(Map<String, dynamic> map, String key, {T? defaultValue}) {
    try {
      if (!map.containsKey(key)) {
        return defaultValue;
      }
      
      final value = map[key];
      
      if (value == null) {
        return defaultValue;
      }
      
      if (value is Map && value.containsKey('value')) {
        final nestedValue = value['value'];
        if (nestedValue == null && defaultValue != null) return defaultValue;
        return nestedValue as T?;
      }
      
      return value as T?;
    } catch (e) {
      debugPrint('Error parsing field $key: $e');
      return defaultValue;
    }
  }
}
