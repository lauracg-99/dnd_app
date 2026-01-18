// lib/viewmodels/class_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';

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

  /// Available source books
  final List<String> availableSources = [
    'phb', 'xge', 'tce', 'scag', 'egw', 'vrgr', 'ftd', 'mpmm', 'scc'
  ];

  /// Load all classes
  Future<void> loadClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allClasses = await ClassService.loadAllClasses();
      _applyFilters();
    } catch (e, stackTrace) {
      _error = 'Failed to load classes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      result = ClassService.filterBySource(result, _selectedSource);
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