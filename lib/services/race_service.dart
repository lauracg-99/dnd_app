import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/race_model.dart';

class RaceService {
  static Future<List<Race>> loadRaces() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final raceFiles = manifestMap.keys
          .where((key) => 
              key.startsWith('assets/data/races/') && 
              key.endsWith('.rpg.json'))
          .toList();

      final List<Race> races = [];
      
      for (final file in raceFiles) {
        try {
          final jsonString = await rootBundle.loadString(file);
          final jsonData = json.decode(jsonString);
          races.add(Race.fromJson(jsonData));
        } catch (e) {
          print('Error loading race file $file: $e');
        }
      }

      // Sort races alphabetically by name
      races.sort((a, b) => a.name.compareTo(b.name));
      return races;
    } catch (e) {
      print('Error loading races: $e');
      return [];
    }
  }
}
