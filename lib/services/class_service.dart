// lib/services/class_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/class_model.dart';

class ClassService {
  static const String _classesPath = 'assets/data/classes/';

  /// Loads all class files from the classes directory
  static Future<List<DndClass>> loadAllClasses() async {
    try {
      // Get all class files from the assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter class files (class_*.rpg.json)
      final classFiles =
          manifestMap.keys
              .where(
                (key) =>
                    key.startsWith(_classesPath) &&
                    key.endsWith('.rpg.json') &&
                    key.contains('class_'),
              )
              .toList();

      //  debugPrint('Found ${classFiles.length} class files to load');

      // Load and parse each class file
      final List<DndClass> classes = [];
      for (final file in classFiles) {
        try {
          final classData = await _loadClassFromFile(file);
          classes.add(classData);
          // debugPrint('Successfully loaded class: ${classData.name}');
        } catch (e) {
          debugPrint('Error loading class from $file: $e');
          if (e is FormatException) {
            //   debugPrint('FormatException details: ${e.source}');
          }
        }
      }

      // Sort classes alphabetically by name
      classes.sort((a, b) => a.name.compareTo(b.name));

      //  debugPrint('Successfully loaded ${classes.length} classes');
      return classes;
    } catch (e, stackTrace) {
      //  debugPrint('Error in loadAllClasses: $e');
      //  debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Loads a single class from a file
  static Future<DndClass> _loadClassFromFile(String filePath) async {
    try {
      //  debugPrint('Loading class from: $filePath');
      final jsonString = await rootBundle.loadString(filePath);
      final jsonData = json.decode(jsonString);
      //   debugPrint('Parsing JSON data for: $filePath');
      final dndClass = DndClass.fromJson(jsonData);
      //   debugPrint('Successfully parsed class: ${dndClass.name}');
      return dndClass;
    } catch (e, stackTrace) {
      // debugPrint('Error loading class from $filePath: $e');
      //   debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Searches classes by name or description
  static List<DndClass> searchClasses(List<DndClass> classes, String query) {
    if (query.isEmpty) return classes;

    final lowerQuery = query.toLowerCase();
    return classes.where((cls) {
      return cls.name.toLowerCase().contains(lowerQuery) ||
          cls.features.any(
            (f) =>
                f.name.toLowerCase().contains(lowerQuery) ||
                f.description.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

  /// Filters classes by source book
  static List<DndClass> filterBySource(List<DndClass> classes, String source) {
    if (source.isEmpty) return classes;
    return classes
        .where((cls) => cls.source.toLowerCase() == source.toLowerCase())
        .toList();
  }
}
