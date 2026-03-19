import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/weapon_model.dart';

class WeaponService {
  static Future<List<Weapon>> loadWeapons() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

      final weaponFiles = manifest
          .listAssets()
          .where((key) =>
              key.startsWith('assets/data/weapons/') &&
              key.endsWith('.rpg.json'))
          .toList();

      final List<Weapon> weapons = [];
      
      for (final file in weaponFiles) {
        try {
          final jsonString = await rootBundle.loadString(file);
          final jsonData = json.decode(jsonString);
          weapons.add(Weapon.fromJson(jsonData));
        } catch (e) {
          print('Error loading weapon file $file: $e');
        }
      }

      // Sort weapons alphabetically by name
      weapons.sort((a, b) => a.name.compareTo(b.name));
      return weapons;
    } catch (e) {
      print('Error loading weapons: $e');
      return [];
    }
  }
}
