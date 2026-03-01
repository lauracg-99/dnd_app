/// User model for storing user-specific data including device information
class UserData {
  final String userId;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> registeredDeviceIds;
  final String? lastSyncDeviceId;
  final DateTime? lastSyncAt;
  final Map<String, dynamic> preferences;

  const UserData({
    required this.userId,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.lastLoginAt,
    this.registeredDeviceIds = const [],
    this.lastSyncDeviceId,
    this.lastSyncAt,
    this.preferences = const {},
  });

  /// Create UserData from JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      registeredDeviceIds: (json['registeredDeviceIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      lastSyncDeviceId: json['lastSyncDeviceId'] as String?,
      lastSyncAt: json['lastSyncAt'] != null 
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Convert UserData to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'registeredDeviceIds': registeredDeviceIds,
      'lastSyncDeviceId': lastSyncDeviceId,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'preferences': preferences,
    };
  }

  /// Create a copy with updated fields
  UserData copyWith({
    String? userId,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? registeredDeviceIds,
    String? lastSyncDeviceId,
    DateTime? lastSyncAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      registeredDeviceIds: registeredDeviceIds ?? this.registeredDeviceIds,
      lastSyncDeviceId: lastSyncDeviceId ?? this.lastSyncDeviceId,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Add a device ID to the registered devices list
  UserData addDeviceId(String deviceId) {
    final updatedDeviceIds = List<String>.from(registeredDeviceIds);
    if (!updatedDeviceIds.contains(deviceId)) {
      updatedDeviceIds.add(deviceId);
    }
    return copyWith(registeredDeviceIds: updatedDeviceIds);
  }

  /// Remove a device ID from the registered devices list
  UserData removeDeviceId(String deviceId) {
    final updatedDeviceIds = List<String>.from(registeredDeviceIds);
    updatedDeviceIds.remove(deviceId);
    return copyWith(registeredDeviceIds: updatedDeviceIds);
  }

  /// Update last sync information
  UserData updateLastSync(String deviceId) {
    return copyWith(
      lastSyncDeviceId: deviceId,
      lastSyncAt: DateTime.now(),
    );
  }

  /// Update last login time
  UserData updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  /// Check if a device is registered
  bool isDeviceRegistered(String deviceId) {
    return registeredDeviceIds.contains(deviceId);
  }

  /// Get the number of registered devices
  int get deviceCount => registeredDeviceIds.length;

  @override
  String toString() {
    return 'UserData(userId: $userId, email: $email, deviceCount: $deviceCount, lastSyncAt: $lastSyncAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserData && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
