import 'dart:async';

/// Callback type for handling messages.
typedef OnMessageCallback = FutureOr<void> Function(Map<String, dynamic>);

/// Base abstract interface for notification manager.
abstract interface class PushNotificationManager {
  /// Initialize the push notification service
  Future<void> initialize();

  /// Dispose the push notification service
  Future<void> dispose();

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
  Future<StreamSubscription<Map<String, dynamic>>> setOnMessageListener(
    OnMessageCallback callback,
  );

  /// Callback for handling messages when the app is opened from a notification.
  /// You should set this to react to messages when the app is opened from a
  /// notification.
  Future<StreamSubscription<Map<String, dynamic>>>
      setOnMessageOpenedAppListener(OnMessageCallback callback);

  /// Boolean to check whether the app has enabled notifications
  bool get enabledNotifications;

  /// Boolean to check whether the app has notifications allowed
  /// The difference between enabled notifications and notifications allowed
  /// is that enabled notifications means that the user enabled notifications
  /// in the app settings, while notifications allowed means that the user has
  /// allowed the app to send notifications and has not disabled them in the
  /// system settings.
  bool get notificationsAllowed;

  /// Set the enabled notifications boolean
  // ignore: avoid_positional_boolean_parameters
  Future<bool> setEnabledNotifications(bool enabled);
}
