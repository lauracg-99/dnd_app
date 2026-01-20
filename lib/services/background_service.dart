import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/background_model.dart';

class BackgroundService {
  static Future<List<Background>> loadBackgrounds() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

      final backgroundFiles = manifest
          .listAssets()
          .where((key) =>
              key.startsWith('assets/data/backgrounds/') &&
              key.endsWith('.rpg.json'))
          .toList();
      final List<Background> backgrounds = [];
      
      for (final file in backgroundFiles) {
        try {
          final jsonString = await rootBundle.loadString(file);
          final jsonData = json.decode(jsonString);
          backgrounds.add(Background.fromJson(jsonData));
        } catch (e) {
          print('Error loading background file $file: $e');
        }
      }

      // Sort backgrounds alphabetically by name
      backgrounds.sort((a, b) => a.name.compareTo(b.name));
      return backgrounds;
    } catch (e) {
      print('Error loading backgrounds: $e');
      return [];
    }
  }
}
