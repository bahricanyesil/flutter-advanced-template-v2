import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationCategory {
  alarm,
  call,
  email,
  error,
  event,
  message,
  progress,
  promo,
  recommendation,
  reminder,
  service,
  social,
  status,
  system,
  transport
}

extension NotificationCategoryExtension on NotificationCategory {
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
