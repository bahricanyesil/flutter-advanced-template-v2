import 'dart:async';

/// Callback type for handling messages.
typedef OnMessageCallback = FutureOr<void> Function(Map<String, dynamic>);

/// Base abstract interface for notification manager.
abstract interface class PushNotificationManager {
  /// Initialize the push notification service
  Future<void> initialize();

  /// Request notification permissions
  Future<bool> requestPermission();

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
  void setOnBackgroundMessageListener(OnMessageCallback callback);

  /// Callback for handling messages. You should set this to react to messages.
  void setOnMessageListener(OnMessageCallback callback);

  /// Callback for handling messages when the app is opened from a notification.
  /// You should set this to react to messages when the app is opened from a
  /// notification.
  void setOnMessageOpenedAppListener(OnMessageCallback callback);
}
