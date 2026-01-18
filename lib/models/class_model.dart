// lib/models/class_model.dart
import 'package:flutter/foundation.dart';
import 'base_model.dart';

class ClassFeature {
  final String name;
  final String description;
  final int level;

  const ClassFeature({
    required this.name,
    required this.description,
    required this.level,
  });

  factory ClassFeature.fromJson(Map<String, dynamic> json) {
    return ClassFeature(
      name: json['name'] as String,
      description: json['description'] as String,
      level: json['level'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'level': level,
    };
  }
}

class DndClass extends BaseModel {
  final String id;
  final String name;
  final String source;
  final String hitDie;
  final List<String> savingThrows;
  final List<ClassFeature> features;
  final DateTime updatedAt;

  const DndClass({
    required this.id,
    required this.name,
    required this.source,
    required this.hitDie,
    required this.savingThrows,
    required this.features,
    required this.updatedAt,
  });

  factory DndClass.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    
    return DndClass(
      id: _getValue<String>(stats, 'id'),
      name: _getValue<String>(stats, 'name'),
      source: _getValue<String>(stats, 'source', defaultValue: 'phb'),
      hitDie: _getValue<String>(stats, 'hit_die', defaultValue: 'd8'),
      savingThrows: _getSavingThrows(stats),
      features: _getFeatures(stats),
      updatedAt: DateTime.parse(_getValue<String>(stats, 'updated_at')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'system': '5e',
      'resource_id': 'class',
      'stats': {
        'id': id,
        'name': {'value': name},
        'source': {'value': source},
        'hit_die': {'value': hitDie},
        'saving_throws': {
          'value': savingThrows,
        },
        'features': {
          'value': features.map((f) => f.toJson()).toList(),
        },
        'updated_at': {'value': updatedAt.toIso8601String()},
      },
    };
  }

  static List<String> _getSavingThrows(Map<String, dynamic> stats) {
    final savingThrows = <String>[];
    final saves = stats.entries.where((e) => e.key.endsWith('_saving_throw_proficiency'));

    for (var save in saves) {
      if (_getValue<bool>(stats, save.key, defaultValue: false)) {
        final ability = save.key.split('_').first;
        savingThrows.add(ability);
      }
    }

    return savingThrows;
  }

  static List<ClassFeature> _getFeatures(Map<String, dynamic> stats) {
    final features = <ClassFeature>[];
    final featuresList = stats['features']?['value'] as List<dynamic>?;

    if (featuresList != null) {
      for (var feature in featuresList) {
        try {
          if (feature is Map<String, dynamic>) {
            final name = feature['stats']?['name']?['value'] as String?;
            final description = feature['stats']?['descriptions']?['value']?[0]?['stats']?['description']?['value'] as String?;
            
            if (name != null && description != null) {
              features.add(ClassFeature(
                name: name,
                description: description,
                level: 1, // Default level, can be extracted from the feature if available
              ));
            }
          }
        } catch (e) {
          debugPrint('Error parsing feature: $e');
        }
      }
    }

    return features;
  }

  static T _getValue<T>(Map<String, dynamic> map, String key, {T? defaultValue}) {
    try {
      if (!map.containsKey(key)) {
        if (defaultValue != null) return defaultValue;
        throw ArgumentError('Missing required field: $key');
      }

      final value = map[key];
      
      if (value is Map && value.containsKey('value')) {
        return value['value'] as T;
      }
      
      return value as T;
    } catch (e) {
      if (defaultValue != null) return defaultValue;
      rethrow;
    }
  }
}