import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notification_manager/src/models/custom_notification_response_model.dart';
import 'package:log_manager/log_manager.dart';
import 'package:permission_manager/permission_manager.dart';
import 'package:timezone/timezone.dart' as tz;

import 'local_notification_manager.dart';
import 'models/custom_notification_settings.dart';

typedef ReceivedLocalNotificationCallback = FutureOr<void> Function(
  int id,
  String? title,
  String? body,
  String? payload,
);

typedef ReceivedNotificationResponseCallback = FutureOr<bool> Function(
  CustomNotificationResponseModel response,
);

/// Implementation of the local notification manager.
///
/// This class is used to manage local notifications in the app.
/// It uses the [FlutterLocalNotificationsPlugin] to manage notifications.
/// It also uses the [PermissionManager] to manage permissions.
/// It also uses the [LogManager] to log messages.
@immutable
final class LocalNotificationManagerImpl implements LocalNotificationManager {
  /// Constructs a local notification manager.
  const LocalNotificationManagerImpl({
    required this.localNotificationPlugin,
    LogManager? logManager,
    PermissionManager? permissionManager,
    this.receiveLocalNotificationCallback,
    this.receiveNotificationResponseCallback,
    this.receiveBackgroundNotificationResponseCallback,
    NotificationSettings settings = const NotificationSettings(),
    this.rethrowExceptions = true,
  })  : _logManager = logManager,
        _permissionManager = permissionManager,
        _settings = settings;

  final LogManager? _logManager;
  final PermissionManager? _permissionManager;
  final FlutterLocalNotificationsPlugin localNotificationPlugin;

  final ReceivedLocalNotificationCallback? receiveLocalNotificationCallback;
  final ReceivedNotificationResponseCallback?
      receiveNotificationResponseCallback;
  final ReceivedNotificationResponseCallback?
      receiveBackgroundNotificationResponseCallback;
  final NotificationSettings _settings;
  final bool rethrowExceptions;

  @override
  Future<bool> initialize() async {
    try {
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        _settings.channelId,
        _settings.channelName,
        description: _settings.channelDescription,
        importance: _settings.importance,
      );

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
      );

      await localNotificationPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse r) =>
            onDidReceiveNotificationResponse.call(
          CustomNotificationResponseModel.fromNotificationResponse(r),
        ),
        onDidReceiveBackgroundNotificationResponse: (NotificationResponse r) =>
            onDidReceiveBackgroundNotificationResponse.call(
          CustomNotificationResponseModel.fromNotificationResponse(r),
        ),
      );

      await localNotificationPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

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

  @override
  Future<bool> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!isEnabled) return false;
    try {
      final PermissionStatusTypes? statusType = await _permissionManager
          ?.checkPermission(PermissionTypes.notification);
      if (statusType?.isGranted == false) {
        throw Exception('No permission to show notification');
      }
      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: _androidDetails);
      await localNotificationPlugin
          .show(id, title, body, platformChannelSpecifics, payload: payload);

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
  }) async {
    if (!isEnabled) return false;
    try {
      final PermissionStatusTypes? statusType = await _permissionManager
          ?.checkPermission(PermissionTypes.notification);
      if (statusType?.isGranted == false) {
        throw Exception('No permission to schedule notification');
      }

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: _androidDetails);
      final tz.TZDateTime timezonedDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      await localNotificationPlugin.zonedSchedule(
        id,
        title,
        body,
        timezonedDate,
        platformChannelSpecifics,
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
      int id, String? title, String? body, String? payload) async {
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
  Future<bool> onDidReceiveBackgroundNotificationResponse(
    CustomNotificationResponseModel response,
  ) async {
    try {
      _logManager?.lDebug(
        '''Background notification response received: {id: ${response.id}, actionId: ${response.actionId}, input: ${response.input}, payload: ${response.payload}}''',
      );
      return await receiveBackgroundNotificationResponseCallback
              ?.call(response) ??
          false;
    } catch (e) {
      _logManager
          ?.lError('Failed to receive background notification response: $e');
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

  AndroidNotificationDetails get _androidDetails => AndroidNotificationDetails(
        _settings.channelId,
        _settings.channelName,
        channelDescription: _settings.channelDescription,
        importance: _settings.importance,
        priority: _settings.priority,
      );

  // You can customize this implementation.
  bool get isEnabled => true;
}
