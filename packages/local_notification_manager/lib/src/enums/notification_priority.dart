import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// The priority of a notification.
enum NotificationPriority {
  /// The minimum priority.
  min,

  /// The low priority.
  low,

  /// The normal priority.
  normal,

  /// The high priority.
  high,

  /// The maximum priority.
  max,
}

/// Extension for [NotificationPriority].
extension NotificationPriorityExtension on NotificationPriority {
  /// Get the corresponding [Priority].
  Priority get toLocalPriority => switch (this) {
        NotificationPriority.min => Priority.min,
        NotificationPriority.low => Priority.low,
        NotificationPriority.normal => Priority.defaultPriority,
        NotificationPriority.high => Priority.high,
        NotificationPriority.max => Priority.max,
      };
}
