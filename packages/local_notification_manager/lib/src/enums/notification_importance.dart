import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// The importance of a notification.
enum NotificationImportance {
  /// The minimum importance.
  min,

  /// The low importance.
  low,

  /// The normal importance.
  normal,

  /// The high importance.
  high,

  /// The maximum importance.
  max,
}

/// Extension for [NotificationImportance].
extension NotificationImportanceExtension on NotificationImportance {
  /// Get the corresponding [Importance].
  Importance get toLocalImportance => switch (this) {
        NotificationImportance.min => Importance.min,
        NotificationImportance.low => Importance.low,
        NotificationImportance.normal => Importance.defaultImportance,
        NotificationImportance.high => Importance.high,
        NotificationImportance.max => Importance.max,
      };

  /// Get the corresponding [LinuxNotificationUrgency].
  LinuxNotificationUrgency get toLocalLinuxUrgency => switch (this) {
        NotificationImportance.min => LinuxNotificationUrgency.low,
        NotificationImportance.low => LinuxNotificationUrgency.low,
        NotificationImportance.normal => LinuxNotificationUrgency.normal,
        NotificationImportance.high => LinuxNotificationUrgency.critical,
        NotificationImportance.max => LinuxNotificationUrgency.critical,
      };
}
