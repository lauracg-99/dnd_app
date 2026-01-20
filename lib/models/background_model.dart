class Background {
  final String id;
  final String name;
  final String source;
  final int goldPieces;
  final List<BackgroundFeature> features;
  final List<SelectableEquipment> selectableEquipments;
  final List<LanguageProficiency> languageProficiencies;
  final List<SkillProficiency> skillProficiencies;
  final List<ToolProficiency> toolProficiencies;

  Background({
    required this.id,
    required this.name,
    required this.source,
    required this.goldPieces,
    this.features = const [],
    this.selectableEquipments = const [],
    this.languageProficiencies = const [],
    this.skillProficiencies = const [],
    this.toolProficiencies = const [],
  });

  factory Background.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final name = stats['name']?['value'] as String? ?? 'Unnamed Background';
    final source = stats['source']?['value'] as String? ?? 'Unknown';
    final goldPieces = stats['gold_pieces']?['value'] as int? ?? 0;

    // Extract features
    final List<BackgroundFeature> features = [];
    final featuresData = stats['features']?['value'] as List?;
    if (featuresData != null) {
      for (final featureData in featuresData) {
        final featureStats = featureData['stats'] as Map<String, dynamic>?;
        if (featureStats != null) {
          features.add(BackgroundFeature.fromJson(featureStats));
        }
      }
    }

    // Extract selectable equipments
    final List<SelectableEquipment> selectableEquipments = [];
    final equipmentsData = stats['selectable_equipments']?['value'] as List?;
    if (equipmentsData != null) {
      for (final equipmentData in equipmentsData) {
        final equipmentStats = equipmentData['stats'] as Map<String, dynamic>?;
        if (equipmentStats != null) {
          selectableEquipments.add(SelectableEquipment.fromJson(equipmentStats));
        }
      }
    }

    // Extract language proficiencies
    final List<LanguageProficiency> languageProficiencies = [];
    final languagesData = stats['language_proficiencies']?['value'] as List?;
    if (languagesData != null) {
      for (final languageData in languagesData) {
        final languageStats = languageData['stats'] as Map<String, dynamic>?;
        if (languageStats != null) {
          languageProficiencies.add(LanguageProficiency.fromJson(languageStats));
        }
      }
    }

    // Extract skill proficiencies
    final List<SkillProficiency> skillProficiencies = [];
    final skillsData = stats['skill_proficiencies']?['value'] as List?;
    if (skillsData != null) {
      for (final skillData in skillsData) {
        final skillStats = skillData['stats'] as Map<String, dynamic>?;
        if (skillStats != null) {
          skillProficiencies.add(SkillProficiency.fromJson(skillStats));
        }
      }
    }

    // Extract tool proficiencies
    final List<ToolProficiency> toolProficiencies = [];
    final toolsData = stats['tool_proficiencies']?['value'] as List?;
    if (toolsData != null) {
      for (final toolData in toolsData) {
        final toolStats = toolData['stats'] as Map<String, dynamic>?;
        if (toolStats != null) {
          toolProficiencies.add(ToolProficiency.fromJson(toolStats));
        }
      }
    }

    return Background(
      id: json['id'] as String? ?? '',
      name: name,
      source: source,
      goldPieces: goldPieces,
      features: features,
      selectableEquipments: selectableEquipments,
      languageProficiencies: languageProficiencies,
      skillProficiencies: skillProficiencies,
      toolProficiencies: toolProficiencies,
    );
  }

  String get featuresDescription {
    if (features.isEmpty) return '';
    return features.map((feature) => feature.description).join('\n\n');
  }

  String get equipmentDescription {
    if (selectableEquipments.isEmpty) return '';
    
    final buffer = StringBuffer();
    for (final equipment in selectableEquipments) {
      buffer.writeln(equipment.description);
    }
    return buffer.toString().trim();
  }

  String get proficienciesDescription {
    final buffer = StringBuffer();
    
    if (skillProficiencies.isNotEmpty) {
      buffer.writeln('Skill Proficiencies:');
      for (final skill in skillProficiencies) {
        buffer.writeln('  ${skill.description}');
      }
    }
    
    if (languageProficiencies.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.writeln('Language Proficiencies:');
      for (final language in languageProficiencies) {
        buffer.writeln('  ${language.description}');
      }
    }
    
    if (toolProficiencies.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.writeln('Tool Proficiencies:');
      for (final tool in toolProficiencies) {
        buffer.writeln('  ${tool.description}');
      }
    }
    
    return buffer.toString().trim();
  }
}

class BackgroundFeature {
  final String id;
  final String name;
  final String description;

  BackgroundFeature({
    required this.id,
    required this.name,
    required this.description,
  });

  factory BackgroundFeature.fromJson(Map<String, dynamic> json) {
    final name = json['name']?['value'] as String? ?? 'Unnamed Feature';
    
    String description = '';
    final descriptions = json['descriptions']?['value'] as List?;
    if (descriptions != null && descriptions.isNotEmpty) {
      description = descriptions.first['stats']?['description']?['value'] as String? ?? '';
    }

    return BackgroundFeature(
      id: json['id'] as String? ?? '',
      name: name,
      description: description,
    );
  }
}

class SelectableEquipment {
  final String id;
  final List<ItemOption> options;

  SelectableEquipment({
    required this.id,
    this.options = const [],
  });

  factory SelectableEquipment.fromJson(Map<String, dynamic> json) {
    final List<ItemOption> options = [];
    final optionsData = json['options']?['value'] as List?;
    if (optionsData != null) {
      for (final optionData in optionsData) {
        final optionStats = optionData['stats'] as Map<String, dynamic>?;
        if (optionStats != null) {
          options.add(ItemOption.fromJson(optionStats));
        }
      }
    }

    return SelectableEquipment(
      id: json['id'] as String? ?? '',
      options: options,
    );
  }

  String get description {
    if (options.isEmpty) return '';
    return options.map((option) => option.description).join(' or ');
  }
}

class ItemOption {
  final String id;
  final String name;
  final int? amount;

  ItemOption({
    required this.id,
    required this.name,
    this.amount,
  });

  factory ItemOption.fromJson(Map<String, dynamic> json) {
    final amount = json['amount']?['value'] as int?;
    final itemData = json['item']?['value']?['stats'] as Map<String, dynamic>?;
    final name = itemData?['name']?['value'] as String? ?? 'Unknown Item';

    return ItemOption(
      id: json['id'] as String? ?? '',
      name: name,
      amount: amount,
    );
  }

  String get description {
    if (amount != null && amount! > 1) {
      return '$amount $name';
    }
    return name;
  }
}

class LanguageProficiency {
  final String id;
  final String options;

  LanguageProficiency({
    required this.id,
    required this.options,
  });

  factory LanguageProficiency.fromJson(Map<String, dynamic> json) {
    final options = json['options']?['value'] as String? ?? 'Choose language';

    return LanguageProficiency(
      id: json['id'] as String? ?? '',
      options: options,
    );
  }

  String get description => options;
}

class SkillProficiency {
  final String id;
  final List<String> options;

  SkillProficiency({
    required this.id,
    this.options = const [],
  });

  factory SkillProficiency.fromJson(Map<String, dynamic> json) {
    final optionsData = json['options']?['value'] as List?;
    final options = optionsData?.map((e) => e.toString()).toList() ?? [];

    return SkillProficiency(
      id: json['id'] as String? ?? '',
      options: options,
    );
  }

  String get description {
    if (options.isEmpty) return 'Choose skill';
    if (options.length == 1) return options.first;
    return options.join(', ');
  }
}

class ToolProficiency {
  final String id;
  final String options;

  ToolProficiency({
    required this.id,
    required this.options,
  });

  factory ToolProficiency.fromJson(Map<String, dynamic> json) {
    final options = json['options']?['value'] as String? ?? 'Choose tool';

    return ToolProficiency(
      id: json['id'] as String? ?? '',
      options: options,
    );
  }

  String get description => options;
}
