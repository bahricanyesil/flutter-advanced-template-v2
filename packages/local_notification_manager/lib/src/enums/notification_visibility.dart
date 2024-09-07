import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as local;

/// The visibility of a notification.
enum NotificationVisibility {
  /// The secret visibility.
  secret,

  /// The private visibility.
  private,

  /// The public visibility.
  public,
}

/// Extension for [NotificationVisibility].
extension NotificationVisibilityExtension on NotificationVisibility {
  /// Get the corresponding [NotificationVisibility].
  local.NotificationVisibility get toLocalAndroidVisibility => switch (this) {
        NotificationVisibility.secret => local.NotificationVisibility.secret,
        NotificationVisibility.private => local.NotificationVisibility.private,
        NotificationVisibility.public => local.NotificationVisibility.public,
      };
}
