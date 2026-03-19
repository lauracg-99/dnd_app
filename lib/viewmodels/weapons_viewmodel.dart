import 'package:flutter/foundation.dart';
import '../models/weapon_model.dart';
import '../services/weapon_service.dart';

class WeaponsViewModel extends ChangeNotifier {
  List<Weapon> _allWeapons = [];
  List<Weapon> _filteredWeapons = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedType = 'All';

  List<Weapon> get weapons => _filteredWeapons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;

  Future<void> loadWeapons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allWeapons = await WeaponService.loadWeapons();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load weapons: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSelectedType(String type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredWeapons = _allWeapons.where((weapon) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          weapon.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          weapon.type.toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply type filter
      final matchesType = _selectedType == 'All' || weapon.type == _selectedType;

      return matchesSearch && matchesType;
    }).toList();

    // Sort alphabetically by name
    _filteredWeapons.sort((a, b) => a.name.compareTo(b.name));
  }

  List<String> getAvailableTypes() {
    final types = _allWeapons.map((weapon) => weapon.type).toSet().toList();
    types.sort();
    return ['All', ...types];
  }

  List<String> getAvailableFormattedTypes() {
    final types = _allWeapons.map((weapon) => weapon.formattedType).toSet().toList();
    types.sort();
    return ['All', ...types];
  }

  String getFormattedTypeForFilter(String formattedType) {
    if (formattedType == 'All') return 'All';
    
    // Find the raw type that matches this formatted type
    for (final weapon in _allWeapons) {
      if (weapon.formattedType == formattedType) {
        return weapon.type;
      }
    }
    return formattedType;
  }

  // Legacy methods for compatibility with CharactersWeaponsTab
  List<Weapon> searchWeapons(String query) {
    if (query.isEmpty) return _allWeapons;
    return _allWeapons
        .where((weapon) =>
            weapon.name.toLowerCase().contains(query.toLowerCase()) ||
            weapon.type.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Weapon> filterByType(String type) {
    if (type.isEmpty || type == 'All') return _allWeapons;
    return _allWeapons.where((weapon) => weapon.type == type).toList();
  }
}
