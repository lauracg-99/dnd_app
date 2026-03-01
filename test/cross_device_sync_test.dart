import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../lib/services/device_service.dart';
import '../lib/services/cloud_sync_service.dart';

void main() {
  // Initialize Flutter bindings for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cross-Device Sync Tests', () {
    test('Device service can generate device ID', () async {
      // Set up mock method channel responses
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'SystemNavigator.platform') {
          return 'android'; // Mock platform
        }
        return null;
      });

      final deviceService = DeviceService();
      final deviceId = await deviceService.getOrCreateDeviceId();
      expect(deviceId, isNotNull);
      expect(deviceId, isNotEmpty);
    });
  });

  group('Sync Status Tests', () {
    test('SyncResult success creation', () {
      final result = SyncResult.success('Test success');
      expect(result.success, isTrue);
      expect(result.successMessage, equals('Test success'));
      expect(result.errorMessage, isNull);
    });

    test('SyncResult failure creation', () {
      final result = SyncResult.failure('Test error');
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Test error'));
      expect(result.successMessage, isNull);
    });

    test('SyncResult toString formatting', () {
      final successResult = SyncResult.success('Success message');
      final failureResult = SyncResult.failure('Error message');
      
      expect(successResult.toString(), contains('SyncResult.success'));
      expect(failureResult.toString(), contains('SyncResult.failure'));
    });
  });

  group('DeviceInfo Tests', () {
    test('DeviceInfo JSON serialization', () {
      final deviceInfo = DeviceInfo(
        deviceId: 'test_device_123',
        deviceName: 'Test Device',
        deviceType: 'Test Type',
        systemVersion: '1.0',
        model: 'Test Model',
        lastSeen: DateTime.now(),
      );

      final json = deviceInfo.toJson();
      expect(json['deviceId'], equals('test_device_123'));
      expect(json['deviceName'], equals('Test Device'));
      expect(json['deviceType'], equals('Test Type'));

      final deserialized = DeviceInfo.fromJson(json);
      expect(deserialized.deviceId, equals(deviceInfo.deviceId));
      expect(deserialized.deviceName, equals(deviceInfo.deviceName));
      expect(deserialized.deviceType, equals(deviceInfo.deviceType));
    });

    test('DeviceInfo copyWithLastSeen updates timestamp', () async {
      final originalTime = DateTime.now().subtract(const Duration(minutes: 5));
      final deviceInfo = DeviceInfo(
        deviceId: 'test_device',
        deviceName: 'Test',
        deviceType: 'Test',
        lastSeen: originalTime,
      );

      final updated = deviceInfo.copyWithLastSeen();
      expect(updated.lastSeen.isAfter(originalTime), isTrue);
      expect(updated.deviceId, equals(deviceInfo.deviceId));
    });

    test('DeviceInfo equality works correctly', () {
      final device1 = DeviceInfo(
        deviceId: 'same_id',
        deviceName: 'Device 1',
        deviceType: 'Type 1',
        lastSeen: DateTime.now(),
      );

      final device2 = DeviceInfo(
        deviceId: 'same_id',
        deviceName: 'Device 2',
        deviceType: 'Type 2',
        lastSeen: DateTime.now().add(const Duration(hours: 1)),
      );

      final device3 = DeviceInfo(
        deviceId: 'different_id',
        deviceName: 'Device 3',
        deviceType: 'Type 3',
        lastSeen: DateTime.now(),
      );

      expect(device1, equals(device2)); // Same device ID
      expect(device1, isNot(equals(device3))); // Different device ID
    });
  });
}
