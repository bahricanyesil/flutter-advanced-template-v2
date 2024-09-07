import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationInterruptionLevel {
  passive,
  active,
  timeSensitive,
  critical,
}

extension NotificationInterruptionLevelExtension
    on NotificationInterruptionLevel {
  InterruptionLevel get toDarwinInterruptionLevel => switch (this) {
        NotificationInterruptionLevel.passive => InterruptionLevel.passive,
        NotificationInterruptionLevel.active => InterruptionLevel.active,
        NotificationInterruptionLevel.timeSensitive =>
          InterruptionLevel.timeSensitive,
        NotificationInterruptionLevel.critical => InterruptionLevel.critical,
      };
}
