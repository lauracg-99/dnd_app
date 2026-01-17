import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/spell_model.dart';

class SpellService {
  static const String _spellsPath = 'assets/data/spells/';
  
  /// Loads all spell files from the spells directory
  static Future<List<Spell>> loadAllSpells() async {
    try {
      // Get all spell files from the assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // Filter spell files (spell_*.rpg.json)
      final spellFiles = manifestMap.keys.where(
        (key) => key.startsWith(_spellsPath) && 
                key.endsWith('.rpg.json') &&
                key.contains('spell_')
      ).toList();
      
      // Load and parse each spell file
      final List<Spell> spells = [];
      for (final file in spellFiles) {
        try {
          //debugPrint('Loading spell from: $file');
          final spell = await _loadSpellFromFile(file);
          spells.add(spell);
          //debugPrint('Successfully loaded spell: ${spell.name}');
        } catch (e) {
          debugPrint('Error loading spell from $file: $e');
          if (e is FormatException) {
            debugPrint('FormatException details: ${e.source}');
          }
        }
      }
      
      // Sort spells by level and then by name
      spells.sort((a, b) {
        final levelCompare = a.levelNumber.compareTo(b.levelNumber);
        if (levelCompare != 0) return levelCompare;
        return a.name.compareTo(b.name);
      });
      
      return spells;
    } catch (e) {
      debugPrint('Error loading spells: $e');
      rethrow;
    }
  }
  
  /// Loads a single spell from a file
  static Future<Spell> _loadSpellFromFile(String filePath) async {
    try {
      final jsonString = await rootBundle.loadString(filePath);
      final jsonData = json.decode(jsonString);
      
      
      return Spell.fromJson(jsonData);
    } catch (e, stackTrace) {
      debugPrint('Error loading spell from $filePath: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Searches spells by name or description
  static List<Spell> searchSpells(List<Spell> spells, String query) {
    if (query.isEmpty) return spells;
    
    final lowerQuery = query.toLowerCase();
    return spells.where((spell) {
      return spell.name.toLowerCase().contains(lowerQuery) ||
             spell.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  /// Filters spells by level
  static List<Spell> filterByLevel(List<Spell> spells, int? level) {
    if (level == null) return spells;
    return spells.where((spell) => spell.levelNumber == level).toList();
  }
  
  /// Filters spells by class
  static List<Spell> filterByClass(List<Spell> spells, String className) {
    if (className.isEmpty) return spells;
    return spells.where((spell) => 
      spell.classes.any((c) => c.toLowerCase() == className.toLowerCase())
    ).toList();
  }
  
  /// Filters spells by school
  static List<Spell> filterBySchool(List<Spell> spells, String school) {
    if (school.isEmpty) return spells;
    return spells.where((spell) => 
      spell.school.toLowerCase() == 'spell_school_${school.toLowerCase()}'
    ).toList();
  }

  /// Debug method to find spells with missing or invalid schools
  static Future<void> debugCheckSpellSchools() async {
    try {
      final spells = await loadAllSpells();
      final validSchools = {
        'abjuration', 'conjuration', 'divination', 'enchantment',
        'evocation', 'illusion', 'necromancy', 'transmutation'
      };
      
      int missingSchool = 0;
      int invalidSchool = 0;
      
      debugPrint('\n=== Spell School Debug Report ===');
      
      for (final spell in spells) {
        final school = spell.school.toLowerCase();
        
        // Check for missing school
        if (school.isEmpty || school == 'unknown') {
          debugPrint('Missing school: ${spell.name} (ID: ${spell.id})');
          missingSchool++;
          continue;
        }
        
        // Check for invalid school
        final schoolName = school.replaceFirst('spell_school_', '');
        if (!validSchools.contains(schoolName)) {
          debugPrint('Invalid school "$school" for spell: ${spell.name} (ID: ${spell.id})');
          invalidSchool++;
        }
      }
      
      debugPrint('\n=== Summary ===');
      debugPrint('Total spells checked: ${spells.length}');
      debugPrint('Spells with missing schools: $missingSchool');
      debugPrint('Spells with invalid schools: $invalidSchool');
      debugPrint('==============================\n');
      
    } catch (e) {
      debugPrint('Error checking spell schools: $e');
    }
  }
}
