import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/feat_model.dart';

class FeatService {
  static Future<List<Feat>> loadFeats() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

      final featFiles = manifest
          .listAssets()
          .where((key) =>
              key.startsWith('assets/data/feats/') &&
              key.endsWith('.rpg.json'))
          .toList();

      final List<Feat> feats = [];
      
      for (final file in featFiles) {
        try {
          final jsonString = await rootBundle.loadString(file);
          final jsonData = json.decode(jsonString);
          feats.add(Feat.fromJson(jsonData));
        } catch (e) {
          print('Error loading feat file $file: $e');
        }
      }

      // Sort feats alphabetically by name
      feats.sort((a, b) => a.name.compareTo(b.name));
      return feats;
    } catch (e) {
      print('Error loading feats: $e');
      return [];
    }
  }
}