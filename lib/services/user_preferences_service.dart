import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

// Conditional import for path_provider
import 'package:path_provider/path_provider.dart' if (dart.library.io) 'package:path_provider/path_provider.dart';

class UserPreferencesService {
  static const String _preferencesFileName = 'user_preferences.json';
  static UserPreferences? _cachedPreferences;
  static bool _useMemoryStorage = false;
  
  /// Initialize storage system
  static Future<void> initializeStorage() async {
    try {
      if (kIsWeb) {
        _useMemoryStorage = true;
        debugPrint('Web platform detected, using memory-only storage for preferences');
        return;
      }
      
      // Test if file operations work
      final testDir = Directory.systemTemp;
      final testFile = File('${testDir.path}/test_prefs_${DateTime.now().millisecondsSinceEpoch}.tmp');
      
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
        _useMemoryStorage = false;
        debugPrint('File system operations available, using file storage for preferences');
      } catch (e) {
        _useMemoryStorage = true;
        debugPrint('File system operations failed, using memory storage for preferences: $e');
      }
    } catch (e) {
      _useMemoryStorage = true;
      debugPrint('Storage initialization failed, using memory storage for preferences: $e');
    }
  }
  
  /// Get the directory where preferences file is stored
  static Future<Directory> _getPreferencesDirectory() async {
    if (_useMemoryStorage) {
      throw Exception('Memory storage in use');
    }
    
    try {
      // Try to get the application documents directory first (mobile/desktop)
      final appDir = await getApplicationDocumentsDirectory();
      return appDir;
    } catch (e) {
      // Fallback to temporary directory
      debugPrint('Could not get documents directory, using temp directory: $e');
      return Directory.systemTemp;
    }
  }
  
  /// Get the preferences file path
  static Future<File> _getPreferencesFile() async {
    if (_useMemoryStorage) {
      throw Exception('Memory storage in use');
    }
    
    final dir = await _getPreferencesDirectory();
    return File('${dir.path}/$_preferencesFileName');
  }
  
  /// Load user preferences from storage
  static Future<UserPreferences> loadPreferences() async {
    if (_cachedPreferences != null) {
      return _cachedPreferences!;
    }
    
    try {
      if (_useMemoryStorage) {
        _cachedPreferences = UserPreferences.defaultPreferences();
        return _cachedPreferences!;
      }
      
      final file = await _getPreferencesFile();
      
      if (!await file.exists()) {
        _cachedPreferences = UserPreferences.defaultPreferences();
        await savePreferences(_cachedPreferences!);
        return _cachedPreferences!;
      }
      
      final content = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(content);
      
      _cachedPreferences = UserPreferences.fromJson(json);
      return _cachedPreferences!;
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      _cachedPreferences = UserPreferences.defaultPreferences();
      return _cachedPreferences!;
    }
  }
  
  /// Save user preferences to storage
  static Future<void> savePreferences(UserPreferences preferences) async {
    _cachedPreferences = preferences;
    
    try {
      if (_useMemoryStorage) {
        debugPrint('Preferences saved to memory: ${preferences.toJson()}');
        return;
      }
      
      final file = await _getPreferencesFile();
      final json = jsonEncode(preferences.toJson());
      
      // Write to temporary file first, then rename to prevent corruption
      final tempFile = File('${file.path}.tmp');
      await tempFile.writeAsString(json);
      await tempFile.rename(file.path);
      
      debugPrint('Preferences saved to file: ${file.path}');
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      rethrow;
    }
  }
  
  /// Clear cached preferences
  static void clearCache() {
    _cachedPreferences = null;
  }
}

/// User preferences model
class UserPreferences {
  final List<String> characterTabOrder;
  final Map<String, dynamic> otherSettings;
  
  const UserPreferences({
    required this.characterTabOrder,
    required this.otherSettings,
  });
  
  /// Default preferences
  factory UserPreferences.defaultPreferences() {
    return UserPreferences(
      characterTabOrder: [
        'character',
        'quick_guide',
        'stats',
        'skills',
        'attacks',
        'spell_slots',
        'spells',
        'feats',
        'class_slots',
        'appearance',
        'notes',
      ],
      otherSettings: {},
    );
  }
  
  /// Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      characterTabOrder: List<String>.from(json['characterTabOrder'] ?? UserPreferences.defaultPreferences().characterTabOrder),
      otherSettings: Map<String, dynamic>.from(json['otherSettings'] ?? {}),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'characterTabOrder': characterTabOrder,
      'otherSettings': otherSettings,
    };
  }
  
  /// Create copy with updated values
  UserPreferences copyWith({
    List<String>? characterTabOrder,
    Map<String, dynamic>? otherSettings,
  }) {
    return UserPreferences(
      characterTabOrder: characterTabOrder ?? this.characterTabOrder,
      otherSettings: otherSettings ?? this.otherSettings,
    );
  }
}
