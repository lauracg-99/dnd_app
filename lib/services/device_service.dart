import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device information model for tracking and synchronization
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String? systemVersion;
  final String? model;
  final DateTime lastSeen;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.systemVersion,
    this.model,
    required this.lastSeen,
  });

  /// Create DeviceInfo from JSON
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      deviceType: json['deviceType'] as String,
      systemVersion: json['systemVersion'] as String?,
      model: json['model'] as String?,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );
  }

  /// Convert DeviceInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'systemVersion': systemVersion,
      'model': model,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  /// Create a copy with updated lastSeen time
  DeviceInfo copyWithLastSeen() {
    return DeviceInfo(
      deviceId: deviceId,
      deviceName: deviceName,
      deviceType: deviceType,
      systemVersion: systemVersion,
      model: model,
      lastSeen: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'DeviceInfo(deviceId: $deviceId, deviceName: $deviceName, deviceType: $deviceType, lastSeen: $lastSeen)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;
}

/// Service for managing device information and tracking
class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  DeviceInfo? _currentDeviceInfo;
  
  // SharedPreferences key for storing device ID
  static const String _deviceIdKey = 'device_id';
  static const String _deviceInfoKey = 'device_info';

  /// Get the current device information
  Future<DeviceInfo> getCurrentDeviceInfo() async {
    if (_currentDeviceInfo != null) {
      return _currentDeviceInfo!.copyWithLastSeen();
    }

    try {
      final deviceId = await getOrCreateDeviceId();
      final deviceDetails = await _getDeviceDetails();
      
      _currentDeviceInfo = DeviceInfo(
        deviceId: deviceId,
        deviceName: deviceDetails['name'] ?? 'Unknown Device',
        deviceType: deviceDetails['type'] ?? 'Unknown',
        systemVersion: deviceDetails['systemVersion'],
        model: deviceDetails['model'],
        lastSeen: DateTime.now(),
      );

      // Cache the device info locally
      await _cacheDeviceInfo(_currentDeviceInfo!);
      
      if (kDebugMode) {
        print('Device info retrieved: $_currentDeviceInfo');
      }

      return _currentDeviceInfo!;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device info: $e');
      }
      // Return a fallback device info
      return DeviceInfo(
        deviceId: await getOrCreateDeviceId(),
        deviceName: 'Unknown Device',
        deviceType: 'Unknown',
        lastSeen: DateTime.now(),
      );
    }
  }

  /// Get or create a unique device ID (public for testing)
  Future<String> getOrCreateDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);

      if (deviceId == null || deviceId.isEmpty) {
        // Generate a new device ID
        deviceId = _generateDeviceId();
        await prefs.setString(_deviceIdKey, deviceId);
        
        if (kDebugMode) {
          print('Generated new device ID: $deviceId');
        }
      } else {
        if (kDebugMode) {
          print('Using existing device ID: $deviceId');
        }
      }

      return deviceId;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting/creating device ID: $e');
      }
      // Fallback to a timestamp-based ID
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Generate a unique device ID
  String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 1000000;
    return 'device_${timestamp}_$random';
  }

  /// Get device-specific details
  Future<Map<String, String>> _getDeviceDetails() async {
    if (kIsWeb) {
      return await _getWebDeviceDetails();
    } else if (Platform.isAndroid) {
      return await _getAndroidDeviceDetails();
    } else if (Platform.isIOS) {
      return await _getIOSDeviceDetails();
    } else {
      return _getGenericDeviceDetails();
    }
  }

  /// Get Android device details
  Future<Map<String, String>> _getAndroidDeviceDetails() async {
    try {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return {
        'name': '${androidInfo.brand} ${androidInfo.model}',
        'type': 'Android',
        'systemVersion': 'Android ${androidInfo.version.release}',
        'model': androidInfo.model,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting Android device details: $e');
      }
      return {'name': 'Android Device', 'type': 'Android'};
    }
  }

  /// Get iOS device details
  Future<Map<String, String>> _getIOSDeviceDetails() async {
    try {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return {
        'name': iosInfo.name ?? 'iOS Device',
        'type': 'iOS',
        'systemVersion': 'iOS ${iosInfo.systemVersion}',
        'model': iosInfo.model,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting iOS device details: $e');
      }
      return {'name': 'iOS Device', 'type': 'iOS'};
    }
  }

  /// Get web device details
  Future<Map<String, String>> _getWebDeviceDetails() async {
    try {
      final webInfo = await _deviceInfoPlugin.webBrowserInfo;
      return {
        'name': webInfo.browserName?.name ?? 'Web Browser',
        'type': 'Web',
        'systemVersion': webInfo.userAgent ?? 'Unknown',
        'model': webInfo.platform ?? 'Unknown Platform',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting web device details: $e');
      }
      return {'name': 'Web Browser', 'type': 'Web'};
    }
  }

  /// Get generic device details for other platforms
  Map<String, String> _getGenericDeviceDetails() {
    return {
      'name': 'Unknown Device',
      'type': Platform.operatingSystem,
      'systemVersion': Platform.operatingSystemVersion,
    };
  }

  /// Cache device info locally
  Future<void> _cacheDeviceInfo(DeviceInfo deviceInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceInfoKey, deviceInfo.toJson().toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error caching device info: $e');
      }
    }
  }

  /// Get cached device info
  Future<DeviceInfo?> getCachedDeviceInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceInfoJson = prefs.getString(_deviceInfoKey);
      
      if (deviceInfoJson != null && deviceInfoJson.isNotEmpty) {
        final Map<String, dynamic> deviceInfoMap = {};
        // Simple JSON parsing for the cached string
        final parts = deviceInfoJson.split(',');
        for (final part in parts) {
          final keyValue = part.split(':');
          if (keyValue.length == 2) {
            final key = keyValue[0].trim().replaceAll('{', '').replaceAll('"', '');
            final value = keyValue[1].trim().replaceAll('}', '').replaceAll('"', '');
            deviceInfoMap[key] = value;
          }
        }
        
        if (deviceInfoMap.isNotEmpty) {
          return DeviceInfo.fromJson(deviceInfoMap);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached device info: $e');
      }
    }
    return null;
  }

  /// Update the last seen timestamp for current device
  Future<void> updateLastSeen() async {
    if (_currentDeviceInfo != null) {
      _currentDeviceInfo = _currentDeviceInfo!.copyWithLastSeen();
      await _cacheDeviceInfo(_currentDeviceInfo!);
    }
  }

  /// Clear cached device information
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceInfoKey);
      _currentDeviceInfo = null;
      
      if (kDebugMode) {
        print('Device info cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing device info cache: $e');
      }
    }
  }

  /// Check if this is the first time the app is running on this device
  Future<bool> isFirstTimeOnDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !prefs.containsKey(_deviceIdKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking first time on device: $e');
      }
      return true;
    }
  }
}
