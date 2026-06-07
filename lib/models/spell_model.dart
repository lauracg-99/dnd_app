import 'package:flutter/foundation.dart';
import 'base_model.dart';

class Spell extends BaseModel {
  final String id;
  final String name;
  final String source;
  final String level;
  final String school;
  final bool ritual;
  final String castingTime;
  final String range;
  final String duration;
  final bool verbal;
  final bool somatic;
  final bool material;
  final String? components;
  final String description;
  final String? higherLevelDescription;
  final List<String> classes;
  final List<dynamic> dice; // Raw nested dice JSON from the spell resource
  final DateTime updatedAt;

  const Spell({
    required this.id,
    required this.name,
    this.source = 'unknown',
    this.level = 'spell_level_0', // Default to cantrip (level 0)
    this.school = 'unknown', // Default to 'unknown' if not specified
    this.ritual = false, // Made optional with default value
    required this.castingTime,
    required this.range,
    required this.duration,
    this.verbal = false,
    this.somatic = false,
    this.material = false,
    this.components,
    required this.description,
    this.higherLevelDescription,
    required this.classes,
    required this.dice,
    required this.updatedAt,
  });

  /// Get the level as a number (e.g., "spell_level_8" -> 8)
  int get levelNumber {
    final levelStr = level.replaceAll('spell_level_', '');
    return levelStr == 'cantrip' ? 0 : int.tryParse(levelStr) ?? 0;
  }

  /// Get the school name without the prefix
  String get schoolName => school.replaceAll('spell_school_', '');

  /// Extract damage dice from the raw nested dice JSON.
  List<SpellDamageDice> get damageDice => _parseSpellDamageDice();

  /// Get unique damage types from the spell's damage dice
  List<String> get damageTypes {
    final damageTypesList = <String>[];

    for (final levelledDice in dice) {
      if (levelledDice is! Map<String, dynamic>) continue;

      final damageDiceList =
          levelledDice['stats']?['damage_dice']?['value'] as List<dynamic>? ??
          [];

      for (final damageDice in damageDiceList) {
        if (damageDice is! Map<String, dynamic>) continue;

        final damageType =
            damageDice['stats']?['damage_type']?['value'] as String?;
        if (damageType != null && damageType.isNotEmpty) {
          damageTypesList.add(damageType);
        }
      }
    }

    return damageTypesList.toSet().toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'resource_id': 'spell',
      'stats': {
        'id': id,
        'name': {'value': name},
        'source': {'value': source},
        'level': {'value': level},
        'school': {'value': school},
        'ritual': {'value': ritual},
        'casting_time': {'value': castingTime},
        'range': {'value': range},
        'duration': {'value': duration},
        'verbal': {'value': verbal},
        'somatic': {'value': somatic},
        'material': {'value': material},
        if (components != null) 'components': {'value': components},
        'description': {'value': description},
        if (higherLevelDescription != null)
          'higher_level_description': {'value': higherLevelDescription},
        'classes': {'value': classes},
        'dice': {'value': dice},
        'updated_at': {'value': updatedAt.toIso8601String()},
      },
    };
  }

  factory Spell.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;

    return Spell(
      id: _getValue<String>(stats, 'id'),
      name: _getValue<String>(stats, 'name'),
      source: _getValue<String>(stats, 'source', defaultValue: 'unknown'),
      level: _getValue<String>(stats, 'level', defaultValue: 'spell_level_0'),
      school: _getValue<String>(stats, 'school', defaultValue: 'unknown'),
      ritual: _getValue<bool>(stats, 'ritual', defaultValue: false),
      castingTime: _getValue<String>(stats, 'casting_time'),
      range: _getValue<String>(stats, 'range'),
      duration: _getValue<String>(stats, 'duration'),
      verbal: _getValue<bool>(stats, 'verbal', defaultValue: false),
      somatic: _getValue<bool>(stats, 'somatic', defaultValue: false),
      material: _getValue<bool>(stats, 'material', defaultValue: false),
      components: _getValue<String?>(stats, 'components', defaultValue: null),
      description: _getValue<String>(stats, 'description'),
      higherLevelDescription: _getValue<String?>(
        stats,
        'higher_level_description',
        defaultValue: '',
      ),
      classes: List<String>.from(_getValue<List<dynamic>>(stats, 'classes')),
      dice: _getValue<List<dynamic>>(stats, 'dice', defaultValue: const []),
      updatedAt: DateTime.parse(_getValue<String>(stats, 'updated_at')),
    );
  }

  List<SpellDamageDice> _parseSpellDamageDice() {
    final List<SpellDamageDice> parsed = [];
    final uniqueDamageTypes = damageTypes;

    for (final levelledEntry in dice) {
      if (levelledEntry is! Map<String, dynamic>) continue;
      final levelledStats = levelledEntry['stats'] as Map<String, dynamic>?;
      final level = levelledStats?['level']?['value'] as int?;
      final damageDiceList =
          levelledStats?['damage_dice']?['value'] as List<dynamic>? ?? [];

      for (final damageEntry in damageDiceList) {
        if (damageEntry is! Map<String, dynamic>) continue;
        final damageStats = damageEntry['stats'] as Map<String, dynamic>?;
        final damageType =
            damageStats?['damage_type']?['value'] as String? ?? 'unknown';
        final dices = damageStats?['dices']?['value'] as List<dynamic>? ?? [];

        for (final diceEntry in dices) {
          if (diceEntry is! Map<String, dynamic>) continue;
          final diceStats = diceEntry['stats'] as Map<String, dynamic>?;
          final amount = diceStats?['dice_amount']?['value'] as int?;
          final type = diceStats?['dice_type']?['value'] as String?;

          if (amount != null && type != null) {
            parsed.add(
              SpellDamageDice(
                diceAmount: amount,
                diceType: type,
                damageType: damageType,
                level: level,
                damageTypes: uniqueDamageTypes,
              ),
            );
          }
        }
      }
    }

    return parsed;
  }

  static T _getValue<T>(
    Map<String, dynamic> map,
    String key, {
    T? defaultValue,
  }) {
    try {
      // Special handling for components field
      if (key == 'components') {
        if (!map.containsKey(key)) return defaultValue as T;
        final value = map[key];
        if (value == null) return defaultValue as T;
        if (value is Map && value.containsKey('value'))
          return value['value'] as T;
        return value as T;
      }

      // For all other fields
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
        if (nestedValue == null && defaultValue != null) return defaultValue;
        return nestedValue as T;
      }

      return value as T;
    } catch (e) {
      // For components, return null instead of throwing
      if (key == 'components') return defaultValue as T;

      if (defaultValue != null) return defaultValue;
      debugPrint('Error parsing field $key: $e');
      rethrow;
    }
  }
}

class SpellDamageDice {
  final int diceAmount;
  final String diceType;
  final String damageType;
  final int? level;
  final List<String> damageTypes;

  SpellDamageDice({
    required this.diceAmount,
    required this.diceType,
    required this.damageType,
    this.level,
    required this.damageTypes,
  });
}
