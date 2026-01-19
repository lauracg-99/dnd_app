import 'package:flutter/foundation.dart';
import 'base_model.dart';

class Character extends BaseModel {
  final String id;
  final String name;
  final String? customImagePath;
  final CharacterStats stats;
  final CharacterSavingThrows savingThrows;
  final CharacterSkillChecks skillChecks;
  final CharacterHealth health;
  final String characterClass;
  final String? subclass;
  final List<CharacterAttack> attacks;
  final CharacterSpellSlots spellSlots;
  final List<String> spells;
  final String quickGuide;
  final String backstory;
  final CharacterPillars pillars;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Character({
    required this.id,
    required this.name,
    this.customImagePath,
    required this.stats,
    required this.savingThrows,
    required this.skillChecks,
    required this.health,
    required this.characterClass,
    this.subclass,
    this.attacks = const [],
    required this.spellSlots,
    this.spells = const [],
    this.quickGuide = '',
    this.backstory = '',
    required this.pillars,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'resource_id': 'character',
      'stats': {
        'id': {'value': id},
        'name': {'value': name},
        if (customImagePath != null) 'custom_image_path': {'value': customImagePath},
        'stats': stats.toJson(),
        'saving_throws': savingThrows.toJson(),
        'skill_checks': skillChecks.toJson(),
        'health': health.toJson(),
        'class': {'value': characterClass},
        if (subclass != null) 'subclass': {'value': subclass},
        'attacks': attacks.map((attack) => attack.toJson()).toList(),
        'spell_slots': spellSlots.toJson(),
        'spells': {'value': spells},
        'quick_guide': {'value': quickGuide},
        'backstory': {'value': backstory},
        'pillars': pillars.toJson(),
        'created_at': {'value': createdAt.toIso8601String()},
        'updated_at': {'value': updatedAt.toIso8601String()},
      },
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    
    return Character(
      id: _getValue<String>(stats, 'id'),
      name: _getValue<String>(stats, 'name'),
      customImagePath: _getValue<String?>(stats, 'custom_image_path', defaultValue: null),
      stats: CharacterStats.fromJson(_getValue<Map<String, dynamic>>(stats, 'stats')),
      savingThrows: CharacterSavingThrows.fromJson(_getValue<Map<String, dynamic>>(stats, 'saving_throws')),
      skillChecks: CharacterSkillChecks.fromJson(_getValue<Map<String, dynamic>>(stats, 'skill_checks')),
      health: CharacterHealth.fromJson(_getValue<Map<String, dynamic>>(stats, 'health')),
      characterClass: _getValue<String>(stats, 'class'),
      subclass: _getValue<String?>(stats, 'subclass', defaultValue: null),
      attacks: _getValue<List<dynamic>>(stats, 'attacks', defaultValue: const [])
          .map((attack) => CharacterAttack.fromJson(attack as Map<String, dynamic>))
          .toList(),
      spellSlots: CharacterSpellSlots.fromJson(_getValue<Map<String, dynamic>>(stats, 'spell_slots')),
      spells: List<String>.from(_getValue<List<dynamic>>(stats, 'spells', defaultValue: const [])),
      quickGuide: _getValue<String>(stats, 'quick_guide', defaultValue: ''),
      backstory: _getValue<String>(stats, 'backstory', defaultValue: ''),
      pillars: CharacterPillars.fromJson(_getValue<Map<String, dynamic>>(stats, 'pillars')),
      createdAt: DateTime.parse(_getValue<String>(stats, 'created_at')),
      updatedAt: DateTime.parse(_getValue<String>(stats, 'updated_at')),
    );
  }

  static T _getValue<T>(Map<String, dynamic> map, String key, {T? defaultValue}) {
    try {
      // Special handling for custom_image_path field
      if (key == 'custom_image_path') {
        if (!map.containsKey(key)) return defaultValue as T;
        final value = map[key];
        if (value == null) return defaultValue as T;
        if (value is Map && value.containsKey('value')) {
          final nestedValue = value['value'];
          if (nestedValue == null || nestedValue == '') return defaultValue as T;
          return nestedValue as T;
        }
        if (value == '' || value == null) return defaultValue as T;
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
      if (defaultValue != null) return defaultValue;
      debugPrint('Error parsing field $key: $e');
      rethrow;
    }
  }

  Character copyWith({
    String? id,
    String? name,
    String? customImagePath,
    CharacterStats? stats,
    CharacterSavingThrows? savingThrows,
    CharacterSkillChecks? skillChecks,
    CharacterHealth? health,
    String? characterClass,
    String? subclass,
    List<CharacterAttack>? attacks,
    CharacterSpellSlots? spellSlots,
    List<String>? spells,
    String? quickGuide,
    String? backstory,
    CharacterPillars? pillars,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      customImagePath: customImagePath ?? this.customImagePath,
      stats: stats ?? this.stats,
      savingThrows: savingThrows ?? this.savingThrows,
      skillChecks: skillChecks ?? this.skillChecks,
      health: health ?? this.health,
      characterClass: characterClass ?? this.characterClass,
      subclass: subclass ?? this.subclass,
      attacks: attacks ?? this.attacks,
      spellSlots: spellSlots ?? this.spellSlots,
      spells: spells ?? this.spells,
      quickGuide: quickGuide ?? this.quickGuide,
      backstory: backstory ?? this.backstory,
      pillars: pillars ?? this.pillars,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CharacterStats {
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final int proficiencyBonus;
  final int armorClass;
  final int speed;

  const CharacterStats({
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    this.proficiencyBonus = 2,
    this.armorClass = 10,
    this.speed = 30,
  });

  Map<String, dynamic> toJson() => {
    'strength': {'value': strength},
    'dexterity': {'value': dexterity},
    'constitution': {'value': constitution},
    'intelligence': {'value': intelligence},
    'wisdom': {'value': wisdom},
    'charisma': {'value': charisma},
    'proficiency_bonus': {'value': proficiencyBonus},
    'armor_class': {'value': armorClass},
    'speed': {'value': speed},
  };

  factory CharacterStats.fromJson(Map<String, dynamic> json) {
    return CharacterStats(
      strength: Character._getValue<int>(json, 'strength'),
      dexterity: Character._getValue<int>(json, 'dexterity'),
      constitution: Character._getValue<int>(json, 'constitution'),
      intelligence: Character._getValue<int>(json, 'intelligence'),
      wisdom: Character._getValue<int>(json, 'wisdom'),
      charisma: Character._getValue<int>(json, 'charisma'),
      proficiencyBonus: Character._getValue<int>(json, 'proficiency_bonus', defaultValue: 2),
      armorClass: Character._getValue<int>(json, 'armor_class', defaultValue: 10),
      speed: Character._getValue<int>(json, 'speed', defaultValue: 30),
    );
  }

  int getModifier(int score) => ((score - 10) / 2).floor();
}

class CharacterSavingThrows {
  final bool strengthProficiency;
  final bool dexterityProficiency;
  final bool constitutionProficiency;
  final bool intelligenceProficiency;
  final bool wisdomProficiency;
  final bool charismaProficiency;

  const CharacterSavingThrows({
    this.strengthProficiency = false,
    this.dexterityProficiency = false,
    this.constitutionProficiency = false,
    this.intelligenceProficiency = false,
    this.wisdomProficiency = false,
    this.charismaProficiency = false,
  });

  Map<String, dynamic> toJson() => {
    'strength_proficiency': {'value': strengthProficiency},
    'dexterity_proficiency': {'value': dexterityProficiency},
    'constitution_proficiency': {'value': constitutionProficiency},
    'intelligence_proficiency': {'value': intelligenceProficiency},
    'wisdom_proficiency': {'value': wisdomProficiency},
    'charisma_proficiency': {'value': charismaProficiency},
  };

  factory CharacterSavingThrows.fromJson(Map<String, dynamic> json) {
    return CharacterSavingThrows(
      strengthProficiency: Character._getValue<bool>(json, 'strength_proficiency', defaultValue: false),
      dexterityProficiency: Character._getValue<bool>(json, 'dexterity_proficiency', defaultValue: false),
      constitutionProficiency: Character._getValue<bool>(json, 'constitution_proficiency', defaultValue: false),
      intelligenceProficiency: Character._getValue<bool>(json, 'intelligence_proficiency', defaultValue: false),
      wisdomProficiency: Character._getValue<bool>(json, 'wisdom_proficiency', defaultValue: false),
      charismaProficiency: Character._getValue<bool>(json, 'charisma_proficiency', defaultValue: false),
    );
  }
}

class CharacterSkillChecks {
  final bool acrobaticsProficiency;
  final bool animalHandlingProficiency;
  final bool arcanaProficiency;
  final bool athleticsProficiency;
  final bool deceptionProficiency;
  final bool historyProficiency;
  final bool insightProficiency;
  final bool intimidationProficiency;
  final bool investigationProficiency;
  final bool medicineProficiency;
  final bool natureProficiency;
  final bool perceptionProficiency;
  final bool performanceProficiency;
  final bool persuasionProficiency;
  final bool religionProficiency;
  final bool sleightOfHandProficiency;
  final bool stealthProficiency;
  final bool survivalProficiency;

  const CharacterSkillChecks({
    this.acrobaticsProficiency = false,
    this.animalHandlingProficiency = false,
    this.arcanaProficiency = false,
    this.athleticsProficiency = false,
    this.deceptionProficiency = false,
    this.historyProficiency = false,
    this.insightProficiency = false,
    this.intimidationProficiency = false,
    this.investigationProficiency = false,
    this.medicineProficiency = false,
    this.natureProficiency = false,
    this.perceptionProficiency = false,
    this.performanceProficiency = false,
    this.persuasionProficiency = false,
    this.religionProficiency = false,
    this.sleightOfHandProficiency = false,
    this.stealthProficiency = false,
    this.survivalProficiency = false,
  });

  Map<String, dynamic> toJson() => {
    'acrobatics_proficiency': {'value': acrobaticsProficiency},
    'animal_handling_proficiency': {'value': animalHandlingProficiency},
    'arcana_proficiency': {'value': arcanaProficiency},
    'athletics_proficiency': {'value': athleticsProficiency},
    'deception_proficiency': {'value': deceptionProficiency},
    'history_proficiency': {'value': historyProficiency},
    'insight_proficiency': {'value': insightProficiency},
    'intimidation_proficiency': {'value': intimidationProficiency},
    'investigation_proficiency': {'value': investigationProficiency},
    'medicine_proficiency': {'value': medicineProficiency},
    'nature_proficiency': {'value': natureProficiency},
    'perception_proficiency': {'value': perceptionProficiency},
    'performance_proficiency': {'value': performanceProficiency},
    'persuasion_proficiency': {'value': persuasionProficiency},
    'religion_proficiency': {'value': religionProficiency},
    'sleight_of_hand_proficiency': {'value': sleightOfHandProficiency},
    'stealth_proficiency': {'value': stealthProficiency},
    'survival_proficiency': {'value': survivalProficiency},
  };

  factory CharacterSkillChecks.fromJson(Map<String, dynamic> json) {
    return CharacterSkillChecks(
      acrobaticsProficiency: Character._getValue<bool>(json, 'acrobatics_proficiency', defaultValue: false),
      animalHandlingProficiency: Character._getValue<bool>(json, 'animal_handling_proficiency', defaultValue: false),
      arcanaProficiency: Character._getValue<bool>(json, 'arcana_proficiency', defaultValue: false),
      athleticsProficiency: Character._getValue<bool>(json, 'athletics_proficiency', defaultValue: false),
      deceptionProficiency: Character._getValue<bool>(json, 'deception_proficiency', defaultValue: false),
      historyProficiency: Character._getValue<bool>(json, 'history_proficiency', defaultValue: false),
      insightProficiency: Character._getValue<bool>(json, 'insight_proficiency', defaultValue: false),
      intimidationProficiency: Character._getValue<bool>(json, 'intimidation_proficiency', defaultValue: false),
      investigationProficiency: Character._getValue<bool>(json, 'investigation_proficiency', defaultValue: false),
      medicineProficiency: Character._getValue<bool>(json, 'medicine_proficiency', defaultValue: false),
      natureProficiency: Character._getValue<bool>(json, 'nature_proficiency', defaultValue: false),
      perceptionProficiency: Character._getValue<bool>(json, 'perception_proficiency', defaultValue: false),
      performanceProficiency: Character._getValue<bool>(json, 'performance_proficiency', defaultValue: false),
      persuasionProficiency: Character._getValue<bool>(json, 'persuasion_proficiency', defaultValue: false),
      religionProficiency: Character._getValue<bool>(json, 'religion_proficiency', defaultValue: false),
      sleightOfHandProficiency: Character._getValue<bool>(json, 'sleight_of_hand_proficiency', defaultValue: false),
      stealthProficiency: Character._getValue<bool>(json, 'stealth_proficiency', defaultValue: false),
      survivalProficiency: Character._getValue<bool>(json, 'survival_proficiency', defaultValue: false),
    );
  }
}

class CharacterHealth {
  final int maxHitPoints;
  final int currentHitPoints;
  final int temporaryHitPoints;
  final int hitDice;
  final String hitDiceType;

  const CharacterHealth({
    required this.maxHitPoints,
    this.currentHitPoints = 0,
    this.temporaryHitPoints = 0,
    this.hitDice = 1,
    this.hitDiceType = 'd8',
  });

  Map<String, dynamic> toJson() => {
    'max_hit_points': {'value': maxHitPoints},
    'current_hit_points': {'value': currentHitPoints},
    'temporary_hit_points': {'value': temporaryHitPoints},
    'hit_dice': {'value': hitDice},
    'hit_dice_type': {'value': hitDiceType},
  };

  factory CharacterHealth.fromJson(Map<String, dynamic> json) {
    return CharacterHealth(
      maxHitPoints: Character._getValue<int>(json, 'max_hit_points'),
      currentHitPoints: Character._getValue<int>(json, 'current_hit_points', defaultValue: 0),
      temporaryHitPoints: Character._getValue<int>(json, 'temporary_hit_points', defaultValue: 0),
      hitDice: Character._getValue<int>(json, 'hit_dice', defaultValue: 1),
      hitDiceType: Character._getValue<String>(json, 'hit_dice_type', defaultValue: 'd8'),
    );
  }
}

class CharacterAttack {
  final String id;
  final String name;
  final String attackBonus;
  final String damage;
  final String damageType;
  final String description;

  const CharacterAttack({
    required this.id,
    required this.name,
    required this.attackBonus,
    required this.damage,
    required this.damageType,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': {'value': name},
    'attack_bonus': {'value': attackBonus},
    'damage': {'value': damage},
    'damage_type': {'value': damageType},
    'description': {'value': description},
  };

  factory CharacterAttack.fromJson(Map<String, dynamic> json) {
    return CharacterAttack(
      id: json['id'] as String,
      name: Character._getValue<String>(json, 'name'),
      attackBonus: Character._getValue<String>(json, 'attack_bonus'),
      damage: Character._getValue<String>(json, 'damage'),
      damageType: Character._getValue<String>(json, 'damage_type'),
      description: Character._getValue<String>(json, 'description', defaultValue: ''),
    );
  }
}

class CharacterSpellSlots {
  final int level1Slots;
  final int level1Used;
  final int level2Slots;
  final int level2Used;
  final int level3Slots;
  final int level3Used;
  final int level4Slots;
  final int level4Used;
  final int level5Slots;
  final int level5Used;
  final int level6Slots;
  final int level6Used;
  final int level7Slots;
  final int level7Used;
  final int level8Slots;
  final int level8Used;
  final int level9Slots;
  final int level9Used;

  const CharacterSpellSlots({
    this.level1Slots = 0,
    this.level1Used = 0,
    this.level2Slots = 0,
    this.level2Used = 0,
    this.level3Slots = 0,
    this.level3Used = 0,
    this.level4Slots = 0,
    this.level4Used = 0,
    this.level5Slots = 0,
    this.level5Used = 0,
    this.level6Slots = 0,
    this.level6Used = 0,
    this.level7Slots = 0,
    this.level7Used = 0,
    this.level8Slots = 0,
    this.level8Used = 0,
    this.level9Slots = 0,
    this.level9Used = 0,
  });

  Map<String, dynamic> toJson() => {
    'level1_slots': {'value': level1Slots},
    'level1_used': {'value': level1Used},
    'level2_slots': {'value': level2Slots},
    'level2_used': {'value': level2Used},
    'level3_slots': {'value': level3Slots},
    'level3_used': {'value': level3Used},
    'level4_slots': {'value': level4Slots},
    'level4_used': {'value': level4Used},
    'level5_slots': {'value': level5Slots},
    'level5_used': {'value': level5Used},
    'level6_slots': {'value': level6Slots},
    'level6_used': {'value': level6Used},
    'level7_slots': {'value': level7Slots},
    'level7_used': {'value': level7Used},
    'level8_slots': {'value': level8Slots},
    'level8_used': {'value': level8Used},
    'level9_slots': {'value': level9Slots},
    'level9_used': {'value': level9Used},
  };

  factory CharacterSpellSlots.fromJson(Map<String, dynamic> json) {
    return CharacterSpellSlots(
      level1Slots: Character._getValue<int>(json, 'level1_slots', defaultValue: 0),
      level1Used: Character._getValue<int>(json, 'level1_used', defaultValue: 0),
      level2Slots: Character._getValue<int>(json, 'level2_slots', defaultValue: 0),
      level2Used: Character._getValue<int>(json, 'level2_used', defaultValue: 0),
      level3Slots: Character._getValue<int>(json, 'level3_slots', defaultValue: 0),
      level3Used: Character._getValue<int>(json, 'level3_used', defaultValue: 0),
      level4Slots: Character._getValue<int>(json, 'level4_slots', defaultValue: 0),
      level4Used: Character._getValue<int>(json, 'level4_used', defaultValue: 0),
      level5Slots: Character._getValue<int>(json, 'level5_slots', defaultValue: 0),
      level5Used: Character._getValue<int>(json, 'level5_used', defaultValue: 0),
      level6Slots: Character._getValue<int>(json, 'level6_slots', defaultValue: 0),
      level6Used: Character._getValue<int>(json, 'level6_used', defaultValue: 0),
      level7Slots: Character._getValue<int>(json, 'level7_slots', defaultValue: 0),
      level7Used: Character._getValue<int>(json, 'level7_used', defaultValue: 0),
      level8Slots: Character._getValue<int>(json, 'level8_slots', defaultValue: 0),
      level8Used: Character._getValue<int>(json, 'level8_used', defaultValue: 0),
      level9Slots: Character._getValue<int>(json, 'level9_slots', defaultValue: 0),
      level9Used: Character._getValue<int>(json, 'level9_used', defaultValue: 0),
    );
  }
}

class CharacterPillars {
  final String gimmick;
  final String quirk;
  final String wants;
  final String needs;
  final String conflict;

  const CharacterPillars({
    this.gimmick = '',
    this.quirk = '',
    this.wants = '',
    this.needs = '',
    this.conflict = '',
  });

  Map<String, dynamic> toJson() => {
    'gimmick': {'value': gimmick},
    'quirk': {'value': quirk},
    'wants': {'value': wants},
    'needs': {'value': needs},
    'conflict': {'value': conflict},
  };

  factory CharacterPillars.fromJson(Map<String, dynamic> json) {
    return CharacterPillars(
      gimmick: Character._getValue<String>(json, 'gimmick', defaultValue: ''),
      quirk: Character._getValue<String>(json, 'quirk', defaultValue: ''),
      wants: Character._getValue<String>(json, 'wants', defaultValue: ''),
      needs: Character._getValue<String>(json, 'needs', defaultValue: ''),
      conflict: Character._getValue<String>(json, 'conflict', defaultValue: ''),
    );
  }
}
