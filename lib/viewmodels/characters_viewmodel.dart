import 'package:flutter/foundation.dart';
import '../models/character_model.dart';
import '../services/character_service.dart';

class CharactersViewModel extends ChangeNotifier {
  List<Character> _allCharacters = [];
  List<Character> _filteredCharacters = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedClass = '';

  List<Character> get characters => _filteredCharacters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedClass => _selectedClass;

  /// Available options for filtering
  List<String> get availableClasses => [
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

  /// Load all characters
  Future<void> loadCharacters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allCharacters = await CharacterService.loadAllCharacters();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load characters: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new character
  Future<void> createCharacter({
    required String name,
    String characterClass = 'Fighter',
    String? subclass,
    String? race,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCharacter = await CharacterService.createCharacter(
        name: name,
        characterClass: characterClass,
        subclass: subclass,
        race: race,
      );
      
      _allCharacters.add(newCharacter);
      _applyFilters();
    } catch (e) {
      _error = 'Failed to create character: $e';
      debugPrint('Character creation error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing character
  Future<void> updateCharacter(Character character) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CharacterService.saveCharacter(character);
      
      // Update character in the list
      final index = _allCharacters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        _allCharacters[index] = character;
        _applyFilters();
      }
    } catch (e) {
      _error = 'Failed to update character: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a character
  Future<void> deleteCharacter(String characterId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CharacterService.deleteCharacter(characterId);
      
      // Remove character from the list
      _allCharacters.removeWhere((c) => c.id == characterId);
      _applyFilters();
    } catch (e) {
      _error = 'Failed to delete character: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set search query and update filtered characters
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Set selected class and update filtered characters
  void setSelectedClass(String className) {
    _selectedClass = className;
    _applyFilters();
  }

  /// Apply all active filters
  void _applyFilters() {
    var result = _allCharacters;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = CharacterService.searchCharacters(result, _searchQuery);
    }

    // Apply class filter
    if (_selectedClass.isNotEmpty) {
      result = CharacterService.filterByClass(result, _selectedClass);
    }

    _filteredCharacters = result;
    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _searchQuery = '';
    _selectedClass = '';
    _applyFilters();
  }

  /// Get all unique classes from all characters
  Set<String> getAllAvailableClasses() {
    return CharacterService.getAllAvailableClasses(_allCharacters);
  }

  /// Export character to JSON string
  String exportCharacter(Character character) {
    return CharacterService.exportCharacter(character);
  }

  /// Import character from JSON string
  Future<void> importCharacter(String jsonString) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final importedCharacter = await CharacterService.importCharacter(jsonString);
      _allCharacters.add(importedCharacter);
      _applyFilters();
    } catch (e) {
      _error = 'Failed to import character: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Debug method to check character storage
  Future<void> debugCheckCharacterStorage() async {
    await CharacterService.debugCheckCharacterStorage();
  }
}
