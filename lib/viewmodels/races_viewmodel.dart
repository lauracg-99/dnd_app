import 'package:flutter/foundation.dart';
import '../models/race_model.dart';
import '../services/race_service.dart';

class RacesViewModel extends ChangeNotifier {
  List<Race> _races = [];
  bool _isLoading = false;
  String? _error;

  List<Race> get races => _races;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _races = await RaceService.loadRaces();
    } catch (e) {
      _error = 'Failed to load races: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Race> searchRaces(String query) {
    if (query.isEmpty) return _races;
    return _races
        .where((race) =>
            race.name.toLowerCase().contains(query.toLowerCase()) ||
            race.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
