import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:local_notification_manager/src/models/custom_notification_response_model.dart';
import 'package:log_manager/log_manager.dart';
import 'package:permission_manager/permission_manager.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/timezone.dart' as tz;

import 'local_notification_manager.dart';
import 'models/custom_local_notification_settings.dart';

/// Implementation of the local notification manager.
///
/// This class is used to manage local notifications in the app.
/// It uses the [FlutterLocalNotificationsPlugin] to manage notifications.
/// It also uses the [PermissionManager] to manage permissions.
/// It also uses the [LogManager] to log messages.
@immutable
base class LocalNotificationManagerImpl implements LocalNotificationManager {
  /// Constructs a local notification manager.
  LocalNotificationManagerImpl({
    required this.localNotificationPlugin,
    LogManager? logManager,
    PermissionManager? permissionManager,
    this.receiveLocalNotificationCallback,
    this.receiveNotificationResponseCallback,
    CustomLocalNotificationSettings customSettings =
        const CustomLocalNotificationSettings(),
    this.rethrowExceptions = true,
    ReceivedNotificationResponseCallback? onBackgroundNotificationCallback,
  })  : _logManager = logManager,
        _permissionManager = permissionManager,
        _settings = customSettings {
    if (onBackgroundNotificationCallback != null) {
      _setOnBackgroundMessageListener(onBackgroundNotificationCallback);
    }
  }

  /// The log manager.
  final LogManager? _logManager;

  /// The permission manager.
  final PermissionManager? _permissionManager;

  /// The local notification plugin.
  final FlutterLocalNotificationsPlugin localNotificationPlugin;

  /// The callback for receiving a local notification.
  final ReceivedLocalNotificationCallback? receiveLocalNotificationCallback;

  /// The callback for receiving a notification response.
  final ReceivedNotificationResponseCallback?
      receiveNotificationResponseCallback;

  /// The custom local notification settings.
  final CustomLocalNotificationSettings _settings;

  /// Whether to rethrow exceptions.
  final bool rethrowExceptions;

  /// Static field to hold the background message handler
  static ReceivedNotificationResponseCallback? _backgroundMessageHandler;

  @override
  Future<bool> initialize() async {
    try {
      await _initTimezone();
      final AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings(_settings.icon);
      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );
      const LinuxInitializationSettings initializationSettingsLinux =
          LinuxInitializationSettings(defaultActionName: 'Open notification');
      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux,
        macOS: initializationSettingsDarwin,
      );

      await localNotificationPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse r) =>
            onDidReceiveNotificationResponse.call(
          CustomNotificationResponseModel.fromNotificationResponse(r),
        ),
        onDidReceiveBackgroundNotificationResponse:
            _localNotificationBackgroundHandler,
      );

      final PermissionStatusTypes? statusType = await _permissionManager
          ?.checkPermission(PermissionTypes.notification);
      if (statusType?.isGranted == false) {
        await _permissionManager
            ?.requestPermission(PermissionTypes.notification);
      }

      _logManager?.lDebug('Local notification manager initialized');
      return true;
    } catch (e) {
      _logManager
          ?.lError('Failed to initialize local notification manager: $e');
      if (rethrowExceptions) rethrow;
      return false;
    }
  }

  static Future<void> _localNotificationBackgroundHandler(
    NotificationResponse message,
  ) async =>
      await _backgroundMessageHandler?.call(
        CustomNotificationResponseModel.fromNotificationResponse(message),
      );

  // ignore: use_setters_to_change_properties
  static void _setOnBackgroundMessageListener(
    ReceivedNotificationResponseCallback? newHandler,
  ) =>
      _backgroundMessageHandler = newHandler;

  @override
  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    CustomLocalNotificationSettings? settings,
  }) async {
    if (!isEnabled) return false;
    try {
      final PermissionStatusTypes? statusType = await _permissionManager
          ?.checkPermission(PermissionTypes.notification);
      if (statusType?.isGranted == false) {
        throw Exception('No permission to show notification');
      }
      await localNotificationPlugin.show(
        id,
        title,
        body,
        (settings ?? _settings).toLocalNotificationDetails,
        payload: payload,
      );

      _logManager?.lDebug(
        '''Notification shown: {id: $id, title: $title, body: $body, payload: $payload}''',
      );
      return true;
    } catch (e) {
      _logManager?.lError('Failed to show notification: $e');
      if (rethrowExceptions) rethrow;
      return false;
    }
  }

  @override
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    CustomLocalNotificationSettings? settings,
  }) async {
    if (!isEnabled) return false;
    try {
      final PermissionStatusTypes? statusType = await _permissionManager
          ?.checkPermission(PermissionTypes.notification);
      if (statusType?.isGranted == false) {
        throw Exception('No permission to schedule notification');
      }

      final tz.TZDateTime timezonedDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      await localNotificationPlugin.zonedSchedule(
        id,
        title,
        body,
        timezonedDate,
        (settings ?? _settings).toLocalNotificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      _logManager?.lDebug(
        '''Notification scheduled: {id: $id, title: $title, body: $body, scheduledDate: $timezonedDate, payload: $payload}''',
      );
      return true;
    } catch (e) {
      _logManager?.lError('Failed to schedule notification: $e');
      if (rethrowExceptions) rethrow;
      return false;
    }
  }

  @override
  Future<bool> cancelNotification(int id) async {
    try {
      await localNotificationPlugin.cancel(id);
      _logManager?.lDebug('Notification canceled: id $id');
      return true;
    } catch (e) {
      _logManager?.lError('Failed to cancel notification: $e');
      if (rethrowExceptions) rethrow;
      return false;
    }
  }

  @override
  Future<bool> cancelAllNotifications() async {
    try {
      await localNotificationPlugin.cancelAll();
      _logManager?.lDebug('All notifications canceled');
      return true;
    } catch (e) {
      _logManager?.lError('Failed to cancel all notifications: $e');
      if (rethrowExceptions) rethrow;
      return false;
    }
  }

  @override
  Future<bool> onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    try {
      _logManager?.lDebug(
        '''Notification received: {id: $id, title: $title, body: $body, payload: $payload}''',
      );
      await receiveLocalNotificationCallback?.call(id, title, body, payload);
      return true;
    } catch (e) {
      _logManager?.lError('Failed to receive local notification: $e');
      if (rethrowExceptions) rethrow;
      return false;
    }
  }

  @override
  Future<bool> onDidReceiveNotificationResponse(
    CustomNotificationResponseModel response,
  ) async {
    try {
      _logManager?.lDebug(
        '''Notification response received: {id: ${response.id}, actionId: ${response.actionId}, input: ${response.input}, payload: ${response.payload}}''',
      );
      return await receiveNotificationResponseCallback?.call(response) ?? false;
    } catch (e) {
      _logManager?.lError('Failed to receive notification response: $e');
      if (rethrowExceptions) rethrow;
      return false;
    }
  }

  /// Whether the local notification manager is enabled.
  ///
  /// This is a placeholder implementation.
  /// You can customize this implementation.
  bool get isEnabled => true;

  Future<void> _initTimezone() async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tzl.initializeTimeZones();
    final tz.Location foundLocation = tz.getLocation(currentTimeZone);
    tz.setLocalLocation(foundLocation);
    _logManager?.lDebug('Timezone initialized to $currentTimeZone');
  }
}
