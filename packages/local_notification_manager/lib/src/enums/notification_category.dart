import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// The category of the notification.
enum NotificationCategory {
  /// The alarm category is used for notifications that are related to alarms.
  alarm,

  /// The call category is used for notifications that are related to calls.
  call,

  /// The email category is used for notifications that are related to email.
  email,

  /// The error category is used for notifications that are related to errors.
  error,

  /// The event category is used for notifications that are related to events.
  event,

  /// The message category is used for notifications that are related
  /// to messages.
  message,

  /// The progress category is used for notifications that are related
  /// to progress.
  progress,

  /// The promo category is used for notifications that are related
  /// to promotions.
  promo,

  /// The recommendation category is used for notifications that are related
  /// to recommendations.
  recommendation,

  /// The reminder category is used for notifications that are related
  /// to reminders.
  reminder,

  /// The service category is used for notifications that are related
  /// to services.
  service,

  /// The social category is used for notifications that are related
  /// to social.
  social,

  /// The status category is used for notifications that are related
  /// to status.
  status,

  /// The system category is used for notifications that are related
  /// to the system.
  system,

  /// The transport category is used for notifications that are related
  /// to transport.
  transport
}

/// Extension for [NotificationCategory].
extension NotificationCategoryExtension on NotificationCategory {
  /// Get the corresponding [AndroidNotificationCategory].
  AndroidNotificationCategory get toLocalAndroidCategory => switch (this) {
        NotificationCategory.alarm => AndroidNotificationCategory.alarm,
        NotificationCategory.call => AndroidNotificationCategory.call,
        NotificationCategory.email => AndroidNotificationCategory.email,
        NotificationCategory.error => AndroidNotificationCategory.error,
        NotificationCategory.event => AndroidNotificationCategory.event,
        NotificationCategory.message => AndroidNotificationCategory.message,
        NotificationCategory.progress => AndroidNotificationCategory.progress,
        NotificationCategory.promo => AndroidNotificationCategory.promo,
        NotificationCategory.recommendation =>
          AndroidNotificationCategory.recommendation,
        NotificationCategory.reminder => AndroidNotificationCategory.reminder,
        NotificationCategory.service => AndroidNotificationCategory.service,
        NotificationCategory.social => AndroidNotificationCategory.social,
        NotificationCategory.status => AndroidNotificationCategory.status,
        NotificationCategory.system => AndroidNotificationCategory.system,
        NotificationCategory.transport => AndroidNotificationCategory.transport,
      };
}
