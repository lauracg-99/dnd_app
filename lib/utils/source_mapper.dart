/// Utility class for mapping D&D source abbreviations to full book names
class SourceMapper {
  /// Maps source abbreviations to full book names
  static const Map<String, String> _sourceMap = {
    'phb': 'Player\'s Handbook',
    'xge': 'Xanathar\'s Guide to Everything',
    'tce': 'Tasha\'s Cauldron of Everything',
    'scag': 'Sword Coast Adventurer\'s Guide',
    'egw': 'Explorer\'s Guide to Wildemount',
    'vrgr': 'Van Richten\'s Guide to Ravenloft',
    'ftd': 'Fizban\'s Treasury of Dragons',
    'mpmm': 'Mordenkainen\'s Monsters of the Multiverse',
    'scc': 'Strixhaven: A Curriculum of Chaos',
    'bmt': 'Book of Many Things',
    'bgg': 'Bigby Presents: Glory of the Giants',
    'mom': 'Mythic Odysseys of Theros',
    'erlw': 'Eberron: Rising from the Last War',
    'eb': 'Eberron Campaign Setting',
    'dsdq': 'Dungeons of Drakkenheim: The Quest for the Crown',
    'sato': 'Storm King\'s Thunder',
    'ua': 'Unearthed Arcana',
    'homebrew': 'Homebrew',
    'unknown': 'Unknown',
  };

  /// Converts a source abbreviation to the full book name
  /// If the source is not found, returns the original abbreviation
  static String getFullBookName(String source) {
    final normalizedSource = source.toLowerCase().trim();
    return _sourceMap[normalizedSource] ?? source;
  }

  /// Gets all available source abbreviations
  static List<String> getAllSourceAbbreviations() {
    return _sourceMap.keys.toList();
  }

  /// Gets all full book names
  static List<String> getAllBookNames() {
    return _sourceMap.values.toList();
  }

  /// Checks if a source abbreviation is known
  static bool isKnownSource(String source) {
    return _sourceMap.containsKey(source.toLowerCase().trim());
  }

  /// Gets the abbreviation for a full book name (reverse lookup)
  /// Returns the original string if not found
  static String getAbbreviation(String bookName) {
    for (final entry in _sourceMap.entries) {
      if (entry.value.toLowerCase() == bookName.toLowerCase()) {
        return entry.key;
      }
    }
    return bookName;
  }
}
