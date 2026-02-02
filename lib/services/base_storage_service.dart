import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'cloud_sync_service.dart';
import '../models/timestamped_entity.dart';
import '../utils/logger.dart';

/// Base storage service that provides common functionality for file and memory storage
/// T: The type of entity being stored (must have toJson/fromJson and implement TimestampedEntity)
abstract class BaseStorageService<T extends TimestampedEntity> {
  final String _dirName;
  final List<T> _memoryCache = [];
  bool _useMemoryStorage = false;
  bool _initialized = false;
  late final ModuleLogger _logger;

  BaseStorageService(this._dirName) {
    _logger = AppLogger.forModule('Storage:$_dirName');
  }

  bool get _isIOSRelease => !kIsWeb && Platform.isIOS && kReleaseMode;

  /// Initialize storage system
  Future<void> initializeStorage() async {
    if (kIsWeb) {
      _useMemoryStorage = true;
      _initialized = true;
      _logger.info('Web platform detected, using memory-only storage');
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _useMemoryStorage = false;
      _initialized = true;
      _logger.info('File storage initialized');
    } catch (e) {
      _useMemoryStorage = true;
      _initialized = true;
      _logger.warning('Failed to initialize file storage, using memory: $e');
    }
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await initializeStorage();
  }

  /// Get the main directory for this storage type
  Future<Directory> getDirectory() async {
    await ensureInitialized();

    if (_useMemoryStorage) {
      throw StateError('Filesystem access while using memory storage');
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/$_dirName');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
        _logger.debug('Created directory: ${dir.path}');
      }

      return dir;
    } catch (e) {
      _useMemoryStorage = true;
      _logger.error('Failed to access documents directory', error: e);
      throw Exception('Failed to access documents directory for $_dirName');
    }
  }

  /// Get file for a specific entity
  Future<File> getFile(String id, {String? subDir}) async {
    final dir = subDir != null 
        ? Directory('${(await getDirectory()).path}/$subDir')
        : await getDirectory();
    
    if (subDir != null && !await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final sanitizedId = id.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return File('${dir.path}/${getFilePrefix()}_$sanitizedId.json');
  }

  /// Save an entity to storage
  Future<void> save(T entity) async {
    await ensureInitialized();
    try {
      final updatedEntity = entity.withUpdatedTimestamp() as T;
      final id = getId(updatedEntity);

      if (_useMemoryStorage) {
        _saveToMemory(updatedEntity);
        _logger.debug('Saved ${getEntityName()} to memory: ${getDisplayName(updatedEntity)}');
      } else {
        final jsonString = json.encode(toJson(updatedEntity));
        final file = await getFile(id, subDir: getSubDirectory(updatedEntity));
        
        await writeFileWithValidation(file, jsonString, getDisplayName(updatedEntity));
        
        _saveToMemory(updatedEntity);
      }

      _logger.debug('${getEntityName()} saved to cache: ${getDisplayName(updatedEntity)}');

      await scheduleSyncIfAuthenticated();
    } catch (e) {
      _logger.error('Error saving ${getEntityName()} ${getDisplayName(entity)}', error: e);

      if (_isIOSRelease) {
        rethrow;
      }
      if (_useMemoryStorage) {
        rethrow;
      }

      _useMemoryStorage = true;
      await save(entity);
    }
  }

  /// Load all entities from storage
  Future<List<T>> loadAll({String? filter}) async {
    try {
      await ensureInitialized();

      List<T> entities = [];

      if (_useMemoryStorage) {
        entities = filter != null 
            ? _memoryCache.where((e) => matchesFilter(e, filter)).toList()
            : List.from(_memoryCache);
        _logger.debug('Loaded ${entities.length} ${getEntityName()}s from memory');
      } else {
        if (filter == null) {
          _memoryCache.clear();
        }
        
        final dir = await getDirectory();

        if (!await dir.exists()) {
          _logger.debug('Directory does not exist, returning empty list');
          return [];
        }

        List<File> files = [];
        try {
          await for (final entity in dir.list(recursive: true)) {
            if (entity is File && 
                entity.path.endsWith('.json') &&
                entity.path.contains('${getFilePrefix()}_')) {
              files.add(entity);
            }
          }
        } catch (e) {
          if (_isIOSRelease) {
            rethrow;
          }
          _useMemoryStorage = true;
          return filter != null
              ? _memoryCache.where((e) => matchesFilter(e, filter)).toList()
              : List.from(_memoryCache);
        }

        for (final file in files) {
          try {
            _logger.debug('Loading ${getEntityName()} from: ${file.path}');
            final entity = await loadFromFile(file);
            if (filter == null || matchesFilter(entity, filter)) {
              entities.add(entity);
              _logger.debug('Loaded ${getEntityName()}: ${getDisplayName(entity)}');
            }
          } catch (e) {
            _logger.error('Error loading ${getEntityName()} from ${file.path}', error: e);
          }
        }

        if (filter != null) {
          _memoryCache.removeWhere((e) => matchesFilter(e, filter));
          _memoryCache.addAll(entities);
        } else {
          _memoryCache.clear();
          _memoryCache.addAll(entities);
        }
      }

      sortEntities(entities);

      _logger.info('Loaded ${entities.length} ${getEntityName()}s from storage');
      return entities;
    } catch (e) {
      _logger.error('Error loading ${getEntityName()}s', error: e);

      if (_isIOSRelease) {
        rethrow;
      }

      _useMemoryStorage = true;
      return filter != null
          ? _memoryCache.where((e) => matchesFilter(e, filter)).toList()
          : List.from(_memoryCache);
    }
  }

  /// Delete an entity from storage
  Future<void> delete(String id, {String? subDir}) async {
    try {
      await ensureInitialized();

      if (_useMemoryStorage) {
        _memoryCache.removeWhere((e) => getId(e) == id);
        _logger.debug('Deleted ${getEntityName()} from memory: $id');
      } else {
        final file = await getFile(id, subDir: subDir);

        if (await file.exists()) {
          await file.delete();
          _logger.debug('Deleted ${getEntityName()} file: ${file.path}');
        } else {
          _logger.warning('${getEntityName()} file not found for ID: $id');
        }

        _memoryCache.removeWhere((e) => getId(e) == id);
      }

      _logger.debug('${getEntityName()} removed from cache: $id');

      await deleteFromCloudIfAuthenticated(id);
    } catch (e) {
      _logger.error('Error deleting ${getEntityName()} $id', error: e);

      if (_isIOSRelease) {
        rethrow;
      }

      _useMemoryStorage = true;
      _memoryCache.removeWhere((e) => getId(e) == id);
    }
  }

  /// Load entity from file with validation
  Future<T> loadFromFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final validatedJson = validateAndRecoverJson(jsonString, file.path);
      final jsonData = json.decode(validatedJson) as Map<String, dynamic>;

      return fromJson(jsonData);
    } catch (e, stackTrace) {
      _logger.error('Error loading ${getEntityName()} from ${file.path}', error: e, stackTrace: stackTrace);
      
      await createCorruptedFileBackup(file);
      
      rethrow;
    }
  }

  /// Write file with validation and atomic operation
  Future<void> writeFileWithValidation(
    File file,
    String jsonString,
    String displayName,
  ) async {
    String? tempPath;
    try {
      json.decode(jsonString);

      tempPath = '${file.path}.tmp.${DateTime.now().millisecondsSinceEpoch}';
      final tempFile = File(tempPath);

      await tempFile.writeAsString(jsonString, flush: true);

      if (await file.exists()) {
        await file.delete();
      }

      await tempFile.copy(file.path);
      await tempFile.delete();
      await file.stat();
            
      _logger.debug('Saved ${getEntityName()} to file: $displayName');
    } catch (e) {
      if (tempPath != null) {
        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
      rethrow;
    }
  }

  /// Validate and attempt to recover from JSON corruption
  String validateAndRecoverJson(String jsonString, String filePath) {
    try {
      json.decode(jsonString);
      return jsonString;
    } catch (e) {
      _logger.warning('JSON corruption detected in $filePath, attempting recovery...');

      String recoveredJson = jsonString;

      int attempts = 3;
      while (attempts-- > 0 && recoveredJson.endsWith('}')) {
        try {
          json.decode(recoveredJson);
          break;
        } catch (e) {
          recoveredJson = recoveredJson.substring(0, recoveredJson.length - 1).trim();
        }
      }

      try {
        json.decode(recoveredJson);
        _logger.success('Successfully recovered JSON from corruption');
        return recoveredJson;
      } catch (e) {
        _logger.error('JSON recovery failed', error: e);
        rethrow;
      }
    }
  }

  /// Create backup of corrupted file for debugging
  Future<void> createCorruptedFileBackup(File originalFile) async {
    try {
      final backupPath = '${originalFile.path}.corrupted.${DateTime.now().millisecondsSinceEpoch}';
      final backupFile = File(backupPath);
      await backupFile.writeAsString(
        await originalFile.readAsString(),
        flush: true,
      );

      _logger.info('Created backup of corrupted file: $backupPath');
    } catch (e) {
      _logger.error('Failed to create backup of corrupted file', error: e);
    }
  }

  /// Save to memory cache
  void _saveToMemory(T entity) {
    final index = _memoryCache.indexWhere((e) => getId(e) == getId(entity));
    if (index != -1) {
      _memoryCache[index] = entity;
    } else {
      _memoryCache.add(entity);
    }
  }

  /// Schedule cloud sync if user is authenticated
  Future<void> scheduleSyncIfAuthenticated() async {
    try {
      final syncService = CloudSyncService();
      if (syncService.authService.isAuthenticated) {
        await scheduleSync(syncService);
      }
    } catch (e) {
      _logger.error('Error scheduling ${getEntityName()} sync', error: e);
    }
  }

  /// Delete from cloud if user is authenticated
  Future<void> deleteFromCloudIfAuthenticated(String id) async {
    try {
      final syncService = CloudSyncService();
      if (syncService.authService.isAuthenticated) {
        await deleteFromCloud(id, syncService);
      }
    } catch (e) {
      _logger.error('Error deleting ${getEntityName()} from cloud', error: e);
    }
  }

  /// Clear memory cache
  void clearMemoryCache() {
    _memoryCache.clear();
    _logger.debug('Memory cache cleared');
  }

  // Abstract methods to be implemented by subclasses

  /// Get entity ID
  String getId(T entity);

  /// Get display name for logging
  String getDisplayName(T entity);

  /// Get entity name for logging
  String getEntityName();

  /// Get file prefix for file naming
  String getFilePrefix();

  /// Convert entity to JSON
  Map<String, dynamic> toJson(T entity);

  /// Convert JSON to entity
  T fromJson(Map<String, dynamic> json);

  /// Sort entities list
  void sortEntities(List<T> entities);

  /// Get subdirectory for entity (optional, return null for no subdirectory)
  String? getSubDirectory(T entity) => null;

  /// Check if entity matches filter (optional, for filtered loading)
  bool matchesFilter(T entity, String filter) => true;

  /// Schedule sync with cloud service
  Future<void> scheduleSync(CloudSyncService syncService);

  /// Delete from cloud storage
  Future<void> deleteFromCloud(String id, CloudSyncService syncService);
}
