class Race {
  final String id;
  final String name;
  final String source;
  final int? flySpeed;
  final List<dynamic> abilityScoreIncreases;
  final List<dynamic> traits;
  final List<dynamic> unarmedStrike;
  final List<dynamic> languageProficiencies;
  final List<dynamic> skillProficiencies;
  final List<dynamic> armorProficiencies;
  final List<dynamic> weaponProficiencies;
  final List<dynamic> toolProficiencies;

  Race({
    required this.id,
    required this.name,
    required this.source,
    this.flySpeed,
    this.abilityScoreIncreases = const [],
    this.traits = const [],
    this.unarmedStrike = const [],
    this.languageProficiencies = const [],
    this.skillProficiencies = const [],
    this.armorProficiencies = const [],
    this.weaponProficiencies = const [],
    this.toolProficiencies = const [],
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final name = stats['name']?['value'] as String? ?? 'Unnamed Race';
    final source = stats['source']?['value'] as String? ?? 'Unknown';
    final flySpeed = stats['fly_speed']?['value'] as int?;
    
    // Extract ability score increases
    final abilityScoreIncreases = stats['ability_score_increases']?['value'] as List<dynamic>? ?? [];
    
    // Extract traits
    final traits = stats['traits']?['value'] as List<dynamic>? ?? [];
    
    // Extract unarmed strike
    final unarmedStrike = stats['unarmed_strike']?['value'] as List<dynamic>? ?? [];
    
    // Extract proficiencies
    final languageProficiencies = stats['language_proficiencies']?['value'] as List<dynamic>? ?? [];
    final skillProficiencies = stats['skill_proficiencies']?['value'] as List<dynamic>? ?? [];
    final armorProficiencies = stats['armor_proficiencies']?['value'] as List<dynamic>? ?? [];
    final weaponProficiencies = stats['weapon_proficiencies']?['value'] as List<dynamic>? ?? [];
    final toolProficiencies = stats['tool_proficiencies']?['value'] as List<dynamic>? ?? [];

    return Race(
      id: json['id'] as String? ?? '',
      name: name,
      source: source,
      flySpeed: flySpeed,
      abilityScoreIncreases: abilityScoreIncreases,
      traits: traits,
      unarmedStrike: unarmedStrike,
      languageProficiencies: languageProficiencies,
      skillProficiencies: skillProficiencies,
      armorProficiencies: armorProficiencies,
      weaponProficiencies: weaponProficiencies,
      toolProficiencies: toolProficiencies,
    );
  }

  String get formattedTraits {
    final buffer = StringBuffer();
    for (final trait in traits) {
      final traitData = trait['stats'];
      if (traitData != null) {
        if (traitData['name']?['value'] != null) {
          buffer.writeln('• ${traitData['name']['value']}');
        }
        final descriptions = traitData['descriptions']?['value'] as List?;
        if (descriptions != null && descriptions.isNotEmpty) {
          final description = descriptions.first['stats']?['description']?['value'] as String?;
          if (description != null) {
            buffer.writeln('  $description');
          }
        }
      }
    }
    return buffer.toString();
  }

  String get formattedAbilityScoreIncreases {
    final buffer = StringBuffer();
    for (final increase in abilityScoreIncreases) {
      final increaseData = increase['stats'];
      if (increaseData != null && increaseData['modifier_options']?['value'] != null) {
        final options = increaseData['modifier_options']['value'] as List;
        buffer.writeln('• Choose one: ${options.join(', ')}');
      }
    }
    return buffer.toString();
  }

  String get formattedProficiencies {
    final buffer = StringBuffer();
    
    if (languageProficiencies.isNotEmpty) {
      buffer.writeln('Languages:');
      for (final lang in languageProficiencies) {
        final langData = lang['stats'];
        if (langData != null && langData['options']?['value'] != null) {
          buffer.writeln('  • ${langData['options']['value']}');
        }
      }
    }
    
    if (skillProficiencies.isNotEmpty) {
      buffer.writeln('Skills:');
      for (final skill in skillProficiencies) {
        final skillData = skill['stats'];
        if (skillData != null && skillData['options']?['value'] != null) {
          buffer.writeln('  • ${skillData['options']['value']}');
        }
      }
    }
    
    return buffer.toString();
  }

  String get description {
    final buffer = StringBuffer();
    
    if (flySpeed != null) {
      buffer.writeln('Flying Speed: $flySpeed ft');
    }
    
    if (abilityScoreIncreases.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Ability Score Increases:');
      buffer.write(formattedAbilityScoreIncreases);
    }
    
    if (traits.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Traits:');
      buffer.write(formattedTraits);
    }
    
    if (languageProficiencies.isNotEmpty || skillProficiencies.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Proficiencies:');
      buffer.write(formattedProficiencies);
    }
    
    return buffer.toString().trim();
  }
}
