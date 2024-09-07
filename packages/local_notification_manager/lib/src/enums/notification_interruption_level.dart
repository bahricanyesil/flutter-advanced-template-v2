import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// The interruption level of a notification.
enum NotificationInterruptionLevel {
  /// The passive interruption level.
  passive,

  /// The active interruption level.
  active,

  /// The time-sensitive interruption level.
  timeSensitive,

  /// The critical interruption level.
  critical,
}

/// Extension for [NotificationInterruptionLevel].
extension NotificationInterruptionLevelExtension
    on NotificationInterruptionLevel {
  /// Get the corresponding [InterruptionLevel].
  InterruptionLevel get toDarwinInterruptionLevel => switch (this) {
        NotificationInterruptionLevel.passive => InterruptionLevel.passive,
        NotificationInterruptionLevel.active => InterruptionLevel.active,
        NotificationInterruptionLevel.timeSensitive =>
          InterruptionLevel.timeSensitive,
        NotificationInterruptionLevel.critical => InterruptionLevel.critical,
      };
}
