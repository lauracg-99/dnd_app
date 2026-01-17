import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/json_service.dart';

class ItemsViewModel extends ChangeNotifier {
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load items from JSON file
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await JsonService.loadFromAssets<Item>(
        'items.json',
        fromJson: (json) => Item.fromJson(json),
      );
    } catch (e) {
      _error = 'Failed to load items: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter items by a specific type
  List<Item> filterByType(String type) {
    return _items.where((item) => 
      item.additionalData?['type']?.toLowerCase() == type.toLowerCase()
    ).toList();
  }

  /// Search items by name or description
  List<Item> search(String query) {
    if (query.isEmpty) return _items;
    
    final lowerQuery = query.toLowerCase();
    return _items.where((item) => 
      item.name.toLowerCase().contains(lowerQuery) ||
      item.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}
