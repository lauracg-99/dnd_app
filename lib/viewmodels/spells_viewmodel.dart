import 'package:flutter/foundation.dart';
import '../models/spell_model.dart';
import '../services/spell_service.dart';

class SpellsViewModel extends ChangeNotifier {
  List<Spell> _allSpells = [];
  List<Spell> _filteredSpells = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int? _selectedLevel;
  String _selectedClass = '';
  String _selectedSchool = '';

  List<Spell> get spells => _filteredSpells;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int? get selectedLevel => _selectedLevel;
  String get selectedClass => _selectedClass;
  String get selectedSchool => _selectedSchool;

  /// Available options for filtering
  List<int> get availableLevels => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  List<String> get availableClasses => [
    'barbarian',
    'bard',
    'cleric',
    'druid',
    'fighter',
    'monk',
    'paladin',
    'ranger',
    'rogue',
    'sorcerer',
    'warlock',
    'wizard',
    'blood_hunter',
    'artificer',
  ];
  List<String> get availableSchools => [
    'abjuration',
    'conjuration',
    'divination',
    'enchantment',
    'evocation',
    'illusion',
    'necromancy',
    'transmutation',
  ];

  /// Load all spells
  Future<void> loadSpells() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allSpells = await SpellService.loadAllSpells();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load spells: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set search query and update filtered spells
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Set selected level and update filtered spells
  void setSelectedLevel(int? level) {
    _selectedLevel = level;
    _applyFilters();
  }

  /// Set selected class and update filtered spells
  void setSelectedClass(String className) {
    _selectedClass = className;
    _applyFilters();
  }

  /// Set selected school and update filtered spells
  void setSelectedSchool(String school) {
    _selectedSchool = school;
    _applyFilters();
  }

  /// Apply all active filters
  void _applyFilters() {
    var result = _allSpells;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = SpellService.searchSpells(result, _searchQuery);
    }

    // Apply level filter
    if (_selectedLevel != null) {
      result = SpellService.filterByLevel(result, _selectedLevel);
    }

    // Apply class filter
    if (_selectedClass.isNotEmpty) {
      result = SpellService.filterByClass(result, _selectedClass);
    }

    // Apply school filter
    if (_selectedSchool.isNotEmpty) {
      result = SpellService.filterBySchool(result, _selectedSchool);
    }

    _filteredSpells = result;
    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _searchQuery = '';
    _selectedLevel = null;
    _selectedClass = '';
    _selectedSchool = '';
    _applyFilters();
  }

  /// Get all unique classes from all spells
  Set<String> getAllAvailableClasses() {
    final classes = <String>{};
    for (final spell in _allSpells) {
      classes.addAll(spell.classes);
    }
    return classes;
  }
}
