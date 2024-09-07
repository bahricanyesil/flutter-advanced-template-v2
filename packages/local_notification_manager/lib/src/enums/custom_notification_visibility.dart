import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as local;

/// The visibility of a notification.
enum CustomNotificationVisibility {
  /// The secret visibility.
  secret,

  /// The private visibility.
  private,

  /// The public visibility.
  public,
}

/// Extension for [CustomNotificationVisibility].
extension NotificationVisibilityExtension on CustomNotificationVisibility {
  /// Get the corresponding [CustomNotificationVisibility].
  local.NotificationVisibility get toLocalAndroidVisibility => switch (this) {
        CustomNotificationVisibility.secret =>
          local.NotificationVisibility.secret,
        CustomNotificationVisibility.private =>
          local.NotificationVisibility.private,
        CustomNotificationVisibility.public =>
          local.NotificationVisibility.public,
      };
}
