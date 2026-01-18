class Feat {
  final String id;
  final String name;
  final String? prerequisite;
  final String description;
  final String source;
  final List<dynamic> effects;

  Feat({
    required this.id,
    required this.name,
    this.prerequisite,
    required this.description,
    required this.source,
    this.effects = const [],
  });

  factory Feat.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final name = stats['name']?['value'] as String? ?? 'Unnamed Feat';
    final source = stats['source']?['value'] as String? ?? 'Unknown';
    
    // Extract description from the JSON structure
    String description = '';
    final descriptions = stats['descriptions']?['value'] as List?;
    if (descriptions != null && descriptions.isNotEmpty) {
      description = descriptions.first['stats']?['description']?['value'] as String? ?? '';
    }

    // Extract effects if they exist
    final effects = stats['effects']?['value'] as List<dynamic>? ?? [];

    return Feat(
      id: json['id'] as String? ?? '',
      name: name,
      description: description,
      source: source,
      effects: effects,
    );
  }

  String get formattedEffects {
    final buffer = StringBuffer();
    for (final effect in effects) {
      final effectData = effect['stats']?['effect']?['value']?['stats'];
      if (effectData != null) {
        if (effectData['name']?['value'] != null) {
          buffer.writeln('• ${effectData['name']['value']}');
        }
        if (effectData['description']?['value'] != null) {
          buffer.writeln('  ${effectData['description']['value']}');
        }
      }
    }
    return buffer.toString();
  }
}