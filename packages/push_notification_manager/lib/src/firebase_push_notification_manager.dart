import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';
import 'package:permission_manager/permission_manager.dart';

import 'push_notification_manager.dart';
import 'utils/remote_message_extensions.dart';

/// Callback type for handling messages.
typedef OnMessageCallback = FutureOr<void> Function(Map<String, dynamic>);

/// Callback type for handling background messages.
typedef BackgroundMessageCallback = Future<void> Function(RemoteMessage);

/// Firebase push notification manager.
@visibleForTesting
final class FirebasePushNotificationManager implements PushNotificationManager {
  /// Constructs a firebase push notification manager.
  FirebasePushNotificationManager({
    required FirebaseMessaging firebaseMessaging,
    this.onMessageCallback,
    PermissionManager? permissionManager,
    LogManager? logManager,
  })  : _firebaseMessaging = firebaseMessaging,
        _permissionManager = permissionManager,
        _logManager = logManager;

  final FirebaseMessaging _firebaseMessaging;
  final LogManager? _logManager;
  final PermissionManager? _permissionManager;

  /// Callback for handling messages. You should set this to react to messages.
  OnMessageCallback? onMessageCallback;

  /// Callback for handling messages when the app is opened from a notification.
  /// You should set this to react to messages when the app is opened from a
  /// notification.
  OnMessageCallback? onMessageOpenedAppCallback;

  bool _hasPermission = false;
  @override
  bool get hasPermission => _hasPermission;

  /// Static field to hold the background message handler
  static BackgroundMessageCallback? _backgroundMessageHandler;

  /// Static method to set the background message handler
  // ignore: avoid_setters_without_getters
  static set backgroundMessageHandler(BackgroundMessageCallback handler) {
    _backgroundMessageHandler = handler;
  }

  @override
  Future<void> initialize() async {
    await checkAndUpdatePermissionStatus();
    await requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logManager?.lDebug(
        '''Message received in foreground: ${message.data}, Title: ${message.notification?.title}, Body: ${message.notification?.body}''',
      );
      onMessage(message.toCompleteMap);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logManager?.lDebug(
        '''Message opened by user: ${message.data}, Title: ${message.notification?.title}, Body: ${message.notification?.body}''',
      );
      onMessageOpenedApp(message.toCompleteMap);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async =>
      _backgroundMessageHandler?.call(message);

  @override
  Future<void> requestPermission() async {
    final NotificationSettings permissionRes =
        await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    final AuthorizationStatus initStatus = permissionRes.authorizationStatus;
    _hasPermission = initStatus == AuthorizationStatus.authorized ||
        initStatus == AuthorizationStatus.provisional;

    if (!_hasPermission) {
      final PermissionStatusTypes? statusType =
          await _permissionManager?.checkAndRequestPermission(
        PermissionTypes.notification,
      );
      _hasPermission = statusType?.isGranted ?? false;
    }
    _logManager?.lDebug('Permission status updated: $_hasPermission');
  }

  @override
  Future<void> onMessage(Map<String, dynamic> message) async {
    _logManager?.lDebug('Message received in foreground: $message');
    onMessageCallback?.call(message);
  }

  @override
  Future<void> onMessageOpenedApp(Map<String, dynamic> message) async {
    _logManager?.lDebug('Message opened by user: $message');
    onMessageOpenedAppCallback?.call(message);
  }

  @override
  Future<String?> getToken() async {
    final String? token = await _firebaseMessaging.getToken();
    _logManager?.lDebug('FirebaseMessaging token: $token');
    return token;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    if (_hasPermission) {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logManager?.lDebug('Subscribed to topic: $topic');
    } else {
      _logManager?.lDebug('No permission to subscribe to topic: $topic');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_hasPermission) {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logManager?.lDebug('Unsubscribed from topic: $topic');
    } else {
      _logManager?.lDebug('No permission to unsubscribe from topic: $topic');
    }
  }

  @override
  Future<void> checkAndUpdatePermissionStatus() async {
    final NotificationSettings settings =
        await _firebaseMessaging.getNotificationSettings();
    _hasPermission =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    _logManager?.lDebug('Permission status checked: $_hasPermission');
  }
}
