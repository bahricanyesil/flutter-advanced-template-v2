/// Base abstract interface for notification manager.
abstract interface class PushNotificationManager {
  /// Initialize the push notification service
  Future<void> initialize();

  /// Request notification permissions
  Future<void> requestPermission();

  /// Handle notifications received in the foreground
  Future<void> onMessage(Map<String, dynamic> message);

  /// Handle when a notification is opened by the user
  Future<void> onMessageOpenedApp(Map<String, dynamic> message);

  /// Get the device's Firebase messaging token
  Future<String?> getToken();

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Check and update permission status
  Future<void> checkAndUpdatePermissionStatus();

  /// Boolean to check whether the app has notification permission
  bool get hasPermission;
}
