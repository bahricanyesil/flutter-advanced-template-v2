import 'models/custom_notification_response_model.dart';

/// Abstract class for the local notification manager.
abstract interface class LocalNotificationManager {
  /// Initializes the local notification manager.
  Future<void> initialize();

  /// Shows an instant notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Schedules a notification.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  });

  /// Cancels a notification.
  Future<void> cancelNotification(int id);

  /// Cancels all notifications.
  Future<void> cancelAllNotifications();

  /// On did receive local notification callback.
  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  );

  /// On did receive notification response callback.
  void onDidReceiveNotificationResponse(
      CustomNotificationResponseModel response);

  /// On did receive background notification response callback.
  void onDidReceiveBackgroundNotificationResponse(
    CustomNotificationResponseModel response,
  );
}
