/// Helper class for D&D character class-related utilities
class CharacterClassHelper {
  /// Returns the list of available subclasses for a given character class
  /// Returns an empty list if the class is not recognized
  static List<String> getSubclassesForClass(String className) {
    switch (className.toLowerCase()) {
      case 'fighter':
        return [
          'Battle Master',
          'Champion',
          'Eldritch Knight',
          'Psi Warrior',
          'Rune Knight',
          'Samurai',
          'Cavalier',
          'Gunslinger',
          'Banneret',
        ];
      case 'wizard':
        return [
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
        ];
      case 'cleric':
        return [
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
        ];
      case 'rogue':
        return [
          'Thief',
          'Assassin',
          'Arcane Trickster',
          'Inquisitive',
          'Mastermind',
          'Scout',
          'Soulknife',
          'Swashbuckler',
          'Phantom',
        ];
      case 'ranger':
        return [
          'Hunter',
          'Beast Master',
          'Gloom Stalker',
          'Horizon Walker',
          'Monster Slayer',
          'Fey Wanderer',
          'Druidic Warrior',
          'Swarmkeeper',
        ];
      case 'paladin':
        return [
          'Devotion',
          'Ancients',
          'Vengeance',
          'Oathbreaker',
          'Glory',
          'Crown',
          'Watchers',
        ];
      case 'barbarian':
        return [
          'Path of the Berserker',
          'Path of the Totem Warrior',
          'Path of the Zealot',
          'Path of the Wild Magic',
          'Path of the Storm Herald',
          'Path of the Ancestral Guardian',
          'Path of the Battlerager',
          'Path of the Beast',
          'Path of the Wild Soul',
        ];
      case 'bard':
        return [
          'College of Lore',
          'College of Valor',
          'College of Glamour',
          'College of Swords',
          'College of Whispers',
          'College of Creation',
          'College of Eloquence',
          'College of Spirits',
        ];
      case 'druid':
        return [
          'Circle of the Land',
          'Circle of the Moon',
          'Circle of the Shepherd',
          'Circle of Spores',
          'Circle of Stars',
          'Circle of Wildfire',
          'Circle of Dreams',
          'Circle of the Coast',
        ];
      case 'monk':
        return [
          'Way of the Open Hand',
          'Way of Shadow',
          'Way of the Four Elements',
          'Way of the Long Death',
          'Way of Mercy',
          'Way of the Drunken Master',
          'Way of the Kensei',
          'Way of the Astral Self',
        ];
      case 'sorcerer':
        return [
          'Draconic Bloodline',
          'Wild Magic',
          'Divine Soul',
          'Shadow Magic',
          'Storm Sorcery',
          'Clockwork Soul',
          'Aberrant Mind',
        ];
      case 'warlock':
        return [
          'The Fiend',
          'The Great Old One',
          'The Celestial',
          'The Hexblade',
          'The Archfey',
          'The Undying',
          'The Genie',
          'The Fathomless',
          'The Undead',
        ];
      case 'artificer':
        return ['Alchemist', 'Armorer', 'Artillerist', 'Battle Smith'];
      default:
        return [];
    }
  }
}
