import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:key_value_storage_manager/key_value_storage_manager.dart';
import 'package:log_manager/log_manager.dart';

import 'push_notification_manager.dart';
import 'utils/remote_message_extensions.dart';

/// Firebase push notification manager.
final class FirebasePushNotificationManager implements PushNotificationManager {
  /// Constructs a firebase push notification manager.
  FirebasePushNotificationManager._({
    required FirebaseMessaging firebaseMessaging,
    KeyValueStorageManager? keyValueStorageManager,
    OnMessageCallback? onMessageCallback,
    OnMessageCallback? onMessageOpenedAppCallback,
    OnMessageCallback? onBackgroundMessageCallback,
    LogManager? logManager,
    bool checkPermissionsWhileEnabling = true,
  })  : _firebaseMessaging = firebaseMessaging,
        _logManager = logManager,
        _keyValueStorageManager = keyValueStorageManager,
        _onMessageCallback = onMessageCallback,
        _onMessageOpenedAppCallback = onMessageOpenedAppCallback,
        _checkPermissionsWhileEnabling = checkPermissionsWhileEnabling {
    if (onBackgroundMessageCallback != null) {
      setOnBackgroundMessageListener(onBackgroundMessageCallback);
    }
  }

  final FirebaseMessaging _firebaseMessaging;
  final LogManager? _logManager;
  final KeyValueStorageManager? _keyValueStorageManager;

  /// Callback for handling messages. You should set this to react to messages.
  final OnMessageCallback? _onMessageCallback;

  /// Callback for handling messages when the app is opened from a notification.
  /// You should set this to react to messages when the app is opened from a
  /// notification.
  final OnMessageCallback? _onMessageOpenedAppCallback;

  /// Static field to hold the background message handler
  static OnMessageCallback? _backgroundMessageHandler;

  /// Boolean to check whether the permission should be checked while enabling
  /// notifications.
  final bool _checkPermissionsWhileEnabling;

  StreamSubscription<Map<String, dynamic>>? _onMessageSubscription;

  /// On message subscription getter.
  StreamSubscription<Map<String, dynamic>>? get onMessageSubscription =>
      _onMessageSubscription;

  StreamSubscription<Map<String, dynamic>>? _onMessageOpenedAppSubscription;

  /// On message app opened subscription getter.
  StreamSubscription<Map<String, dynamic>>?
      get onMessageOpenedAppSubscription => _onMessageOpenedAppSubscription;

  static const String _notificationsEnabledKey = 'notifications_enabled';

  /// Creates a [FirebasePushNotificationManager] instance.
  static Future<FirebasePushNotificationManager> create({
    required FirebaseMessaging firebaseMessaging,
    KeyValueStorageManager? keyValueStorageManager,
    OnMessageCallback? onMessageCallback,
    OnMessageCallback? onMessageOpenedAppCallback,
    OnMessageCallback? onBackgroundMessageCallback,
    LogManager? logManager,
    bool checkPermissionsWhileEnabling = true,
    bool waitForPermissions = false,
    bool notificationOnForeground = true,
    bool isEnabledNotifications = true,
  }) async {
    final FirebasePushNotificationManager manager =
        FirebasePushNotificationManager._(
      firebaseMessaging: firebaseMessaging,
      keyValueStorageManager: keyValueStorageManager,
      onMessageCallback: onMessageCallback,
      onMessageOpenedAppCallback: onMessageOpenedAppCallback,
      logManager: logManager,
      checkPermissionsWhileEnabling: checkPermissionsWhileEnabling,
      onBackgroundMessageCallback: onBackgroundMessageCallback,
    );
    await manager.initialize(
      waitForPermissions: waitForPermissions,
      notificationOnForeground: notificationOnForeground,
      isEnabledNotifications: isEnabledNotifications,
    );
    return manager;
  }

  @override
  Future<void> initialize({
    bool waitForPermissions = false,
    bool notificationOnForeground = true,
    bool isEnabledNotifications = true,
  }) async {
    try {
      await setEnabledNotifications(isEnabledNotifications);

      if (waitForPermissions) {
        final bool hasPermission = await requestPermission();
        if (!hasPermission) {
          _logManager?.lDebug('Permission denied, skipping initialization');
          return;
        }
      }

      if (!await isNotificationsAllowed()) {
        _logManager
            ?.lDebug('Notifications not allowed, skipping initialization');
        return;
      }

      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: notificationOnForeground,
        badge: notificationOnForeground,
        sound: notificationOnForeground,
      );

      await Future.wait(<Future<StreamSubscription<Map<String, dynamic>>>>[
        if (_onMessageCallback != null)
          setOnMessageListener(_onMessageCallback),
        if (_onMessageOpenedAppCallback != null)
          setOnMessageOpenedAppListener(_onMessageOpenedAppCallback),
      ]);

      _logManager?.lDebug('Push notification manager initialized');
    } catch (e) {
      _logManager?.lError('Failed to initialize push notifications: $e');
    }
  }

  /// Disposes the [FirebasePushNotificationManager] by releasing the resources.
  @override
  Future<void> dispose() async {
    await Future.wait(<Future<void>>[
      _onMessageSubscription?.cancel() ?? Future<void>.value(),
      _onMessageOpenedAppSubscription?.cancel() ?? Future<void>.value(),
    ]);
    _backgroundMessageHandler = null;
    _logManager?.lDebug('Push notification manager disposed');
  }

  @override
  Future<bool> get hasPermission async => _checkSystemPermission();

  Future<bool> _checkSystemPermission() async {
    try {
      final NotificationSettings settings =
          await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      _logManager?.lError('Failed to check notification settings: $e');
      return false;
    }
  }

  @override
  bool get enabledNotifications {
    final bool isEnabled =
        _keyValueStorageManager?.read<bool>(_notificationsEnabledKey) ?? true;
    _logManager?.lDebug('Notifications enabled state: $isEnabled');
    return isEnabled;
  }

  /// Checks if notifications are allowed.
  @override
  Future<bool> isNotificationsAllowed() async {
    if (!enabledNotifications) return false;

    if (_checkPermissionsWhileEnabling) {
      return hasPermission;
    }
    return true;
  }

  @override
  Future<bool> setEnabledNotifications(bool enabled) async {
    if (enabled && _checkPermissionsWhileEnabling) {
      final bool hasSystemPermission = await hasPermission;
      if (!hasSystemPermission) {
        _logManager?.lWarning('Cannot enable notifications without permission');
        return false;
      }
    }

    try {
      await _keyValueStorageManager?.write<bool>(
        key: _notificationsEnabledKey,
        value: enabled,
      );
      _logManager?.lInfo('Notifications ${enabled ? 'enabled' : 'disabled'}');
      return true;
    } catch (e) {
      _logManager?.lError('Failed to set notifications state: $e');
      return false;
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async =>
      await _backgroundMessageHandler?.call(message.toCompleteMap);

  @override
  Future<bool> requestPermission() async {
    try {
      final NotificationSettings permissionRes =
          await _firebaseMessaging.requestPermission();
      final AuthorizationStatus initStatus = permissionRes.authorizationStatus;
      final bool isGranted = initStatus == AuthorizationStatus.authorized ||
          initStatus == AuthorizationStatus.provisional;

      _logManager?.lDebug(
        '''FirebasePushNotificationManager permission status updated: $isGranted''',
      );
      return isGranted;
    } catch (e) {
      _logManager?.lError(
        'FirebasePushNotificationManager permission request failed: $e',
      );
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    final String? token = await _firebaseMessaging.getToken();
    _logManager
        ?.lDebug('FirebasePushNotificationManager token retrieved: $token');
    return token;
  }

  @override
  Future<bool> subscribeToTopic(String topic) async {
    final bool isAllowed = await isNotificationsAllowed();
    if (isAllowed) {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logManager?.lDebug(
        'FirebasePushNotificationManager subscribed to topic: $topic',
      );
      return true;
    } else {
      _logManager?.lWarning('No permission to subscribe to topic: $topic');
      return false;
    }
  }

  @override
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logManager?.lDebug(
        'FirebasePushNotificationManager unsubscribed from topic: $topic',
      );
      return true;
    } catch (e) {
      _logManager?.lError(
        'FirebasePushNotificationManager failed to unsubscribe from topic: $e',
      );
      return false;
    }
  }

  @override
  Future<bool> checkAndUpdatePermissionStatus() async {
    final NotificationSettings settings =
        await _firebaseMessaging.getNotificationSettings();
    bool isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!isGranted) {
      isGranted = await requestPermission();
    }
    _logManager?.lDebug(
      '''FirebasePushNotificationManager permission status checked: $isGranted''',
    );
    return isGranted;
  }

  @override
  Future<StreamSubscription<Map<String, dynamic>>> setOnMessageListener(
    OnMessageCallback callback,
  ) async {
    await _onMessageSubscription?.cancel();

    final bool isAllowed = await isNotificationsAllowed();
    if (!isAllowed) {
      _logManager
          ?.lDebug('Notifications not allowed, skipping message listener');
      return const Stream<Map<String, dynamic>>.empty().listen((_) {});
    }

    _onMessageSubscription = FirebaseMessaging.onMessage
        .map((RemoteMessage message) => message.toCompleteMap)
        .listen((Map<String, dynamic> message) {
      _logManager?.lDebug(
        '''FirebasePushNotificationManager message received in foreground: $message''',
      );
      callback(message);
    });
    return _onMessageSubscription!;
  }

  @override
  Future<StreamSubscription<Map<String, dynamic>>>
      setOnMessageOpenedAppListener(
    OnMessageCallback callback,
  ) async {
    await _onMessageOpenedAppSubscription?.cancel();
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp
        .map((RemoteMessage message) => message.toCompleteMap)
        .listen((Map<String, dynamic> message) {
      _logManager?.lDebug(
        '''FirebasePushNotificationManager message opened by user received in foreground: $message''',
      );
      callback(message);
    });
    return _onMessageOpenedAppSubscription!;
  }

  @override
  void setOnBackgroundMessageListener(OnMessageCallback callback) {
    _backgroundMessageHandler = callback;
    if (_backgroundMessageHandler != null) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }
  }
}
