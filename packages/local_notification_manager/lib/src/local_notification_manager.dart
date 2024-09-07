import 'models/custom_local_notification_settings.dart';
import 'models/custom_notification_response_model.dart';

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

  /// On did receive local notification callback.
  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  );

  /// On did receive notification response callback.
  Future<bool> onDidReceiveNotificationResponse(
      CustomNotificationResponseModel response);

  /// On did receive background notification response callback.
  Future<bool> onDidReceiveBackgroundNotificationResponse(
    CustomNotificationResponseModel response,
  );
}
