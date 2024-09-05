import 'dart:async';

/// Callback type for handling messages.
typedef OnMessageCallback = FutureOr<void> Function(Map<String, dynamic>);

/// Callback type for handling background messages.
typedef BackgroundMessageCallback = FutureOr<void> Function(
  Map<String, dynamic>,
);

/// Base abstract interface for notification manager.
abstract interface class PushNotificationManager {
  /// Initialize the push notification service
  Future<void> initialize();

  /// Request notification permissions
  Future<bool> requestPermission();

  /// Handle notifications received in the foreground
  Future<void> onMessage(Map<String, dynamic> message);

  /// Handle when a notification is opened by the user
  Future<void> onMessageOpenedApp(Map<String, dynamic> message);

  /// Get the device's Firebase messaging token
  Future<String?> getToken();

  /// Subscribe to a topic
  Future<bool> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<bool> unsubscribeFromTopic(String topic);

  /// Check and update permission status
  Future<bool> checkAndUpdatePermissionStatus();

  /// Boolean to check whether the app has notification permission
  bool get hasPermission;

  /// Set the background message handler
  // ignore: avoid_setters_without_getters
  set backgroundMessageHandler(BackgroundMessageCallback handler);

  /// Callback for handling messages. You should set this to react to messages.
  OnMessageCallback? onMessageCallback;

  /// Callback for handling messages when the app is opened from a notification.
  /// You should set this to react to messages when the app is opened from a
  /// notification.
  OnMessageCallback? onMessageOpenedAppCallback;
}
