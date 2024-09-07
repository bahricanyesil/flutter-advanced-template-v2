import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationImportance {
  min,
  low,
  normal,
  high,
  max,
}

extension NotificationImportanceExtension on NotificationImportance {
  Importance get toLocalImportance => switch (this) {
        NotificationImportance.min => Importance.min,
        NotificationImportance.low => Importance.low,
        NotificationImportance.normal => Importance.defaultImportance,
        NotificationImportance.high => Importance.high,
        NotificationImportance.max => Importance.max,
      };

  LinuxNotificationUrgency get toLocalLinuxUrgency => switch (this) {
        NotificationImportance.min => LinuxNotificationUrgency.low,
        NotificationImportance.low => LinuxNotificationUrgency.low,
        NotificationImportance.normal => LinuxNotificationUrgency.normal,
        NotificationImportance.high => LinuxNotificationUrgency.critical,
        NotificationImportance.max => LinuxNotificationUrgency.critical,
      };
}
