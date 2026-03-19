class Weapon {
  final String id;
  final String name;
  final String source;
  final bool isCore;
  final int cost;
  final String costUnit;
  final double weight;
  final String type;
  final String rarity;
  final bool isFinesse;
  final bool isThrown;
  final String? thrownRange;
  final bool isLight;
  final List<DamageDice> damageDice;

  Weapon({
    required this.id,
    required this.name,
    required this.source,
    required this.isCore,
    required this.cost,
    required this.costUnit,
    required this.weight,
    required this.type,
    required this.rarity,
    required this.isFinesse,
    required this.isThrown,
    this.thrownRange,
    required this.isLight,
    required this.damageDice,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final name = stats['name']?['value'] as String? ?? 'Unnamed Weapon';
    final source = stats['source']?['value'] as String? ?? 'Unknown';
    final isCore = stats['is_core']?['value'] as bool? ?? false;
    
    // Extract cost information
    final costData = stats['cost']?['value']?['stats'];
    final cost = costData?['value']?['value'] as int? ?? 0;
    final costUnit = costData?['unit']?['value'] as String? ?? 'gold';
    
    // Extract weight information
    final weightData = stats['weight']?['value']?['stats'];
    final weightValue = weightData?['value']?['value'];
    final weight = weightValue is num ? weightValue.toDouble() : 0.0;
    
    final type = stats['type']?['value'] as String? ?? 'unknown';
    final rarity = stats['rarity']?['value'] as String? ?? 'none';
    final isFinesse = stats['is_finesse']?['value'] as bool? ?? false;
    final isThrown = stats['is_thrown']?['value'] as bool? ?? false;
    final thrownRange = stats['thrown_range']?['value'] as String?;
    final isLight = stats['is_light']?['value'] as bool? ?? false;
    
    // Extract damage dice information
    final damageDiceList = stats['damage_dice']?['value'] as List<dynamic>? ?? [];
    final List<DamageDice> damageDice = [];
    
    for (final damageData in damageDiceList) {
      final diceStats = damageData['stats'];
      if (diceStats != null) {
        final dices = diceStats['dices']?['value'] as List<dynamic>? ?? [];
        final diceAmount = dices.isNotEmpty ? (dices.first['stats']?['dice_amount']?['value'] as int? ?? 1) : 1;
        final diceType = dices.isNotEmpty ? (dices.first['stats']?['dice_type']?['value'] as String? ?? 'd6') : 'd6';
        final damageType = diceStats['damage_type']?['value'] as String? ?? 'unknown';
        
        damageDice.add(DamageDice(
          diceAmount: diceAmount,
          diceType: diceType,
          damageType: damageType,
        ));
      }
    }

    return Weapon(
      id: json['id'] as String? ?? '',
      name: name,
      source: source,
      isCore: isCore,
      cost: cost,
      costUnit: costUnit,
      weight: weight,
      type: type,
      rarity: rarity,
      isFinesse: isFinesse,
      isThrown: isThrown,
      thrownRange: thrownRange,
      isLight: isLight,
      damageDice: damageDice,
    );
  }

  String get formattedDamage {
    if (damageDice.isEmpty) return 'No damage';
    
    final buffer = StringBuffer();
    for (int i = 0; i < damageDice.length; i++) {
      if (i > 0) buffer.write(', ');
      final dice = damageDice[i];
      buffer.write('${dice.diceAmount}${dice.diceType} ${dice.damageType}');
    }
    return buffer.toString();
  }

  String get formattedProperties {
    final properties = <String>[];
    
    if (isFinesse) properties.add('Finesse');
    if (isLight) properties.add('Light');
    if (isThrown) {
      properties.add('Thrown');
      if (thrownRange != null) properties.add('Range $thrownRange');
    }
    
    if (properties.isEmpty) return 'No special properties';
    return properties.join(', ');
  }

  String get formattedType {
    // Convert underscore-separated names to readable format
    return type
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class DamageDice {
  final int diceAmount;
  final String diceType;
  final String damageType;

  DamageDice({
    required this.diceAmount,
    required this.diceType,
    required this.damageType,
  });
}
