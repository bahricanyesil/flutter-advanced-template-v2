import 'dart:async';

import 'package:local_notification_manager/local_notification_manager.dart';

/// The callback for receiving a local notification.
typedef ReceivedLocalNotificationCallback = FutureOr<void> Function(
  int id,
  String? title,
  String? body,
  String? payload,
);

/// The callback for receiving a notification response.
///
typedef ReceivedNotificationResponseCallback = FutureOr<bool> Function(
  CustomNotificationResponseModel response,
);

/// Abstract class for the local notification manager.
abstract interface class LocalNotificationManager {
  /// Initializes the local notification manager.
  Future<bool> initialize();

  /// Shows an instant notification.
  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    CustomLocalNotificationSettings? settings,
  });

  /// Schedules a notification.
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    CustomLocalNotificationSettings? settings,
  });

  /// Cancels a notification.
  Future<bool> cancelNotification(int id);

  /// Cancels all notifications.
  Future<bool> cancelAllNotifications();

  /// On did receive notification response callback.
  Future<bool> onDidReceiveNotificationResponse(
    CustomNotificationResponseModel response,
  );

  /// Creates a notification channel.
  /// This method is only available on Android.
  /// On iOS, this method does nothing.
  Future<void> createNotificationChannel(BaseNotificationChannel channel);
}
