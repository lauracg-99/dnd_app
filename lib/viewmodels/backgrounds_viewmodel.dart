import 'package:flutter/foundation.dart';
import '../models/background_model.dart';
import '../services/background_service.dart';

class BackgroundsViewModel extends ChangeNotifier {
  List<Background> _backgrounds = [];
  bool _isLoading = false;
  String? _error;

  List<Background> get backgrounds => _backgrounds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBackgrounds() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _backgrounds = await BackgroundService.loadBackgrounds();
    } catch (e) {
      _error = 'Failed to load backgrounds: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Background> searchBackgrounds(String query) {
    if (query.isEmpty) return _backgrounds;
    return _backgrounds
        .where((background) =>
            background.name.toLowerCase().contains(query.toLowerCase()) ||
            background.featuresDescription.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
