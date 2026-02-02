/// Mixin for entities that have timestamp fields (createdAt, updatedAt)
/// 
/// This mixin provides a contract for entities that need to track
/// creation and modification times. It also provides helper methods
/// for working with timestamps.
mixin TimestampedEntity {
  /// The date and time when this entity was created
  DateTime get createdAt;
  
  /// The date and time when this entity was last updated
  DateTime get updatedAt;
  
  /// Create a copy of this entity with an updated timestamp
  /// 
  /// This method should be implemented by classes using this mixin
  /// to return a new instance with the updatedAt field set to DateTime.now()
  TimestampedEntity withUpdatedTimestamp();
  
  /// Check if this entity was created recently (within the last hour)
  bool get isRecentlyCreated {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 1;
  }
  
  /// Check if this entity was updated recently (within the last hour)
  bool get isRecentlyUpdated {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inHours < 1;
  }
  
  /// Check if this entity has been modified since creation
  bool get hasBeenModified {
    return updatedAt.isAfter(createdAt);
  }
  
  /// Get a human-readable string for when this entity was last updated
  String get lastUpdatedDescription {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
  
  /// Get a human-readable string for when this entity was created
  String get createdAtDescription {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
}

/// Helper class for working with timestamped entities
class TimestampHelper {
  /// Create timestamps for a new entity
  static Map<String, DateTime> createTimestamps() {
    final now = DateTime.now();
    return {
      'createdAt': now,
      'updatedAt': now,
    };
  }
  
  /// Update the updatedAt timestamp while preserving createdAt
  static Map<String, DateTime> updateTimestamps(DateTime createdAt) {
    return {
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }
  
  /// Check if two timestamps indicate the entity has been modified
  static bool hasBeenModified(DateTime createdAt, DateTime updatedAt) {
    return updatedAt.isAfter(createdAt);
  }
}
