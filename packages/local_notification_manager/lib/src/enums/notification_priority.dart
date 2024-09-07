import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationPriority {
  min,
  low,
  normal,
  high,
  max,
}

extension NotificationPriorityExtension on NotificationPriority {
  Priority get toLocalPriority => switch (this) {
        NotificationPriority.min => Priority.min,
        NotificationPriority.low => Priority.low,
        NotificationPriority.normal => Priority.defaultPriority,
        NotificationPriority.high => Priority.high,
        NotificationPriority.max => Priority.max,
      };
}
