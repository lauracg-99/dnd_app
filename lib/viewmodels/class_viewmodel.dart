// lib/viewmodels/class_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';
import '../utils/source_mapper.dart';

class ClassesViewModel extends ChangeNotifier {
  List<DndClass> _allClasses = [];
  List<DndClass> _filteredClasses = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedSource = '';

  List<DndClass> get classes => _filteredClasses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedSource => _selectedSource;

  /// Available source books with full names
  final List<String> availableSources = [
    'Player\'s Handbook',
    'Xanathar\'s Guide to Everything',
    'Tasha\'s Cauldron of Everything',
    'Sword Coast Adventurer\'s Guide',
    'Explorer\'s Guide to Wildemount',
    'Van Richten\'s Guide to Ravenloft',
    'Fizban\'s Treasury of Dragons',
    'Mordenkainen\'s Monsters of the Multiverse',
    'Strixhaven: A Curriculum of Chaos',
    'Eberron: Rising from the Last War',
    'Eberron Campaign Setting',
    'Dungeons of Drakkenheim: The Quest for the Crown',
    'Storm King\'s Thunder',
  ];

  /// Load all classes
  Future<void> loadClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allClasses = await ClassService.loadAllClasses();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Convert full book name to abbreviation for filtering
  String _getAbbreviationForFilter(String fullName) {
    return SourceMapper.getAbbreviation(fullName);
  }

  /// Set search query and update filtered classes
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Set selected source and update filtered classes
  void setSelectedSource(String source) {
    _selectedSource = source;
    _applyFilters();
  }

  /// Apply all active filters
  void _applyFilters() {
    var result = _allClasses;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = ClassService.searchClasses(result, _searchQuery);
    }

    // Apply source filter
    if (_selectedSource.isNotEmpty) {
      final abbreviation = _getAbbreviationForFilter(_selectedSource);
      result = ClassService.filterBySource(result, abbreviation);
    }

    _filteredClasses = result;
    notifyListeners();
  }

  /// Reset all filters
  void resetFilters() {
    _searchQuery = '';
    _selectedSource = '';
    _applyFilters();
  }

  /// Get all unique sources from all classes
  Set<String> getAllAvailableSources() {
    return _allClasses.map((c) => c.source).toSet();
  }

  /// Get features for a specific class level
  List<ClassFeature> getFeaturesForLevel(DndClass dndClass, int level) {
    return dndClass.features.where((f) => f.level <= level).toList();
  }
}