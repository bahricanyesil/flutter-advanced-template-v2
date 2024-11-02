import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:log_manager/log_manager.dart';
import 'package:permission_manager/permission_manager.dart';

import 'push_notification_manager.dart';
import 'utils/remote_message_extensions.dart';

/// Firebase push notification manager.
final class FirebasePushNotificationManager implements PushNotificationManager {
  /// Constructs a firebase push notification manager.
  FirebasePushNotificationManager({
    required FirebaseMessaging firebaseMessaging,
    OnMessageCallback? onMessageCallback,
    OnMessageCallback? onMessageOpenedAppCallback,
    OnMessageCallback? onBackgroundMessageCallback,
    PermissionManager? permissionManager,
    LogManager? logManager,
  })  : _firebaseMessaging = firebaseMessaging,
        _permissionManager = permissionManager,
        _logManager = logManager,
        _onMessageCallback = onMessageCallback,
        _onMessageOpenedAppCallback = onMessageOpenedAppCallback {
    if (onBackgroundMessageCallback != null) {
      setOnBackgroundMessageListener(onBackgroundMessageCallback);
    }
  }

  final FirebaseMessaging _firebaseMessaging;
  final LogManager? _logManager;
  final PermissionManager? _permissionManager;

  /// Callback for handling messages. You should set this to react to messages.
  final OnMessageCallback? _onMessageCallback;

  /// Callback for handling messages when the app is opened from a notification.
  /// You should set this to react to messages when the app is opened from a
  /// notification.
  final OnMessageCallback? _onMessageOpenedAppCallback;

  /// Static field to hold the background message handler
  static OnMessageCallback? _backgroundMessageHandler;

  bool _hasPermission = false;
  @override
  bool get hasPermission => _hasPermission;

  StreamSubscription<Map<String, dynamic>>? _onMessageSubscription;

  /// On message subscription getter.
  StreamSubscription<Map<String, dynamic>>? get onMessageSubscription =>
      _onMessageSubscription;

  StreamSubscription<Map<String, dynamic>>? _onMessageOpenedAppSubscription;

  /// On message app opened subscription getter.
  StreamSubscription<Map<String, dynamic>>?
      get onMessageOpenedAppSubscription => _onMessageOpenedAppSubscription;

  @override
  Future<void> initialize({
    bool waitForPermissions = false,
    bool notificationOnForeground = true,
  }) async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: notificationOnForeground,
      badge: notificationOnForeground,
      sound: notificationOnForeground,
    );
    if (waitForPermissions) {
      await checkAndUpdatePermissionStatus();
      await requestPermission();
    } else {
      unawaited(checkAndUpdatePermissionStatus());
      unawaited(requestPermission());
    }

    if (_onMessageCallback != null) {
      await setOnMessageListener(_onMessageCallback);
    }
    if (_onMessageOpenedAppCallback != null) {
      await setOnMessageOpenedAppListener(_onMessageOpenedAppCallback);
    }
    _logManager?.lDebug('FirebasePushNotificationManager initialized');
  }

  /// Disposes the [FirebasePushNotificationManager] by releasing the resources.
  @override
  Future<void> dispose() async {
    await _onMessageSubscription?.cancel();
    await _onMessageOpenedAppSubscription?.cancel();
    _logManager?.lDebug('FirebasePushNotificationManager closed');
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
      _hasPermission = initStatus == AuthorizationStatus.authorized ||
          initStatus == AuthorizationStatus.provisional;

      final PermissionStatusTypes? statusType =
          await _permissionManager?.checkAndRequestPermission(
        PermissionTypes.notification,
      );
      _hasPermission = statusType?.isGranted ?? false;

      _logManager?.lDebug(
        '''FirebasePushNotificationManager permission status updated: $_hasPermission''',
      );
      return _hasPermission;
    } catch (e) {
      _logManager?.lError(
        'FirebasePushNotificationManager permission request failed: $e',
      );
      return _hasPermission;
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
    if (_hasPermission) {
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
    if (_hasPermission) {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logManager?.lDebug(
        'FirebasePushNotificationManager unsubscribed from topic: $topic',
      );
      return true;
    } else {
      _logManager?.lDebug('No permission to unsubscribe from topic: $topic');
      return false;
    }
  }

  @override
  Future<bool> checkAndUpdatePermissionStatus() async {
    final NotificationSettings settings =
        await _firebaseMessaging.getNotificationSettings();
    _hasPermission =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    _logManager?.lDebug(
      '''FirebasePushNotificationManager permission status checked: $_hasPermission''',
    );
    return _hasPermission;
  }

  @override
  Future<StreamSubscription<Map<String, dynamic>>> setOnMessageListener(
    OnMessageCallback callback,
  ) async {
    await _onMessageSubscription?.cancel();
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
