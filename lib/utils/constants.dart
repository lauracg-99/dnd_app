/// D&D 5e constants and configuration values

/// Character level constraints
class CharacterLevelConstants {
  static const int minLevel = 1;
  static const int maxLevel = 20;
}

/// Available D&D 5e character classes
class DndClasses {
  static const List<String> all = [
    'Barbarian',
    'Bard',
    'Cleric',
    'Druid',
    'Fighter',
    'Monk',
    'Paladin',
    'Ranger',
    'Rogue',
    'Sorcerer',
    'Warlock',
    'Wizard',
    'Artificer',
    'Blood Hunter',
  ];

  static const String defaultClass = 'Fighter';
}

/// Subclasses for each D&D 5e class
class DndSubclasses {
  static const Map<String, List<String>> byClass = {
    'fighter': [
      'Battle Master',
      'Champion',
      'Eldritch Knight',
      'Psi Warrior',
      'Rune Knight',
      'Samurai',
      'Cavalier',
      'Gunslinger',
      'Banneret',
    ],
    'wizard': [
      'School of Abjuration',
      'School of Conjuration',
      'School of Divination',
      'School of Enchantment',
      'School of Evocation',
      'School of Illusion',
      'School of Necromancy',
      'School of Transmutation',
      'School of Bladesinging',
      'School of Chronurgy',
      'School of Graviturgy',
      'School of Scribes',
      'School of Order',
      'School of Invention',
      'School of War Magic',
    ],
    'cleric': [
      'Knowledge Domain',
      'Life Domain',
      'Light Domain',
      'Nature Domain',
      'Order Domain',
      'Peace Domain',
      'Trickery Domain',
      'War Domain',
      'Forge Domain',
      'Grave Domain',
      'Twilight Domain',
      'Arcana Domain',
    ],
    'rogue': [
      'Thief',
      'Assassin',
      'Arcane Trickster',
      'Inquisitive',
      'Mastermind',
      'Scout',
      'Soulknife',
      'Swashbuckler',
      'Phantom',
    ],
    'ranger': [
      'Hunter',
      'Beast Master',
      'Gloom Stalker',
      'Horizon Walker',
      'Monster Slayer',
      'Fey Wanderer',
      'Druidic Warrior',
      'Swarmkeeper',
    ],
    'paladin': [
      'Devotion',
      'Ancients',
      'Vengeance',
      'Crown',
      'Oathbreaker',
      'Glory',
      'Watchers',
    ],
    'barbarian': [
      'Path of the Berserker',
      'Path of the Totem Warrior',
      'Path of the Zealot',
      'Path of the Wild Magic',
      'Path of the Beast',
      'Path of the Storm Herald',
      'Path of the Battlerager',
    ],
    'bard': [
      'College of Lore',
      'College of Valor',
      'College of Glamour',
      'College of Swords',
      'College of Whispers',
      'College of Creation',
    ],
    'druid': [
      'Circle of the Land',
      'Circle of the Moon',
      'Circle of the Shepherd',
      'Circle of Spores',
      'Circle of Stars',
      'Circle of Wildfire',
    ],
    'monk': [
      'Way of the Open Hand',
      'Way of Shadow',
      'Way of the Four Elements',
      'Way of Mercy',
      'Way of the Drunken Master',
      'Way of the Astral Self',
    ],
    'sorcerer': [
      'Draconic Bloodline',
      'Wild Magic',
      'Divine Soul',
      'Shadow Magic',
      'Storm Sorcery',
      'Clockwork Soul',
      'Aberrant Mind',
    ],
    'warlock': [
      'The Fiend',
      'The Great Old One',
      'The Celestial',
      'The Hexblade',
      'The Fathomless',
      'The Genie',
    ],
    'artificer': [
      'Alchemist',
      'Armorer',
      'Artillerist',
      'Battle Smith',
    ],
  };

  /// Get subclasses for a specific class (case-insensitive)
  static List<String> getForClass(String className) {
    return byClass[className.toLowerCase()] ?? [];
  }
}
