import 'base_model.dart';
import 'timestamped_entity.dart';

/// Model representing a diary group for organizing diary entries
/// Groups allow users to categorize entries (e.g., by session, campaign arc, etc.)
class DiaryGroup extends BaseModel with TimestampedEntity {
  final String id;
  final String characterId;
  final String name;
  
  @override
  final DateTime createdAt;
  
  @override
  final DateTime updatedAt;

  const DiaryGroup({
    required this.id,
    required this.characterId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'resource_id': 'diary_group',
      'data': {
        'id': {'value': id},
        'character_id': {'value': characterId},
        'name': {'value': name},
        'created_at': {'value': createdAt.toIso8601String()},
        'updated_at': {'value': updatedAt.toIso8601String()},
      },
    };
  }

  factory DiaryGroup.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return DiaryGroup(
      id: _getValue<String>(data, 'id'),
      characterId: _getValue<String>(data, 'character_id'),
      name: _getValue<String>(data, 'name'),
      createdAt: DateTime.parse(_getValue<String>(data, 'created_at')),
      updatedAt: DateTime.parse(_getValue<String>(data, 'updated_at')),
    );
  }

  @override
  DiaryGroup withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  DiaryGroup copyWith({
    String? id,
    String? characterId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryGroup(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      name: name ?? this.name,
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
}
