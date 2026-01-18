import 'package:flutter/foundation.dart';
import '../models/feat_model.dart';
import '../services/feat_service.dart';

class FeatsViewModel extends ChangeNotifier {
  List<Feat> _feats = [];
  bool _isLoading = false;
  String? _error;

  List<Feat> get feats => _feats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFeats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _feats = await FeatService.loadFeats();
    } catch (e) {
      _error = 'Failed to load feats: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Feat> searchFeats(String query) {
    if (query.isEmpty) return _feats;
    return _feats
        .where((feat) =>
            feat.name.toLowerCase().contains(query.toLowerCase()) ||
            (feat.description?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();
  }
}
