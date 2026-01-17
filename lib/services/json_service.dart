import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class JsonService {
  /// Loads a JSON file from the assets folder and parses it into a list of items
  static Future<List<T>> loadFromAssets<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/$path');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading JSON from $path: $e');
      rethrow;
    }
  }

  /// Saves a list of items to a JSON file
  static Future<void> saveToFile<T>(
    String path, 
    List<T> items, {
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    // Note: This is a placeholder. On mobile, you'd typically use a package 
    // like path_provider and write to the app's documents directory.
    // For web, you'd need a different approach.
    throw UnimplementedError('Saving to files is not implemented yet');
  }
}
