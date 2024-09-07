import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notification_manager/src/enums/notification_category.dart';
import 'package:local_notification_manager/src/enums/notification_importance.dart';
import 'package:local_notification_manager/src/enums/notification_interruption_level.dart';
import 'package:local_notification_manager/src/enums/notification_priority.dart';
import 'package:local_notification_manager/src/models/custom_notification_response_model.dart';
import 'package:log_manager/log_manager.dart';
import 'package:permission_manager/permission_manager.dart';
import 'package:timezone/timezone.dart' as tz;

import 'local_notification_manager.dart';
import 'models/custom_local_notification_settings.dart';

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
    CustomLocalNotificationSettings customSettings =
        const CustomLocalNotificationSettings(),
    this.rethrowExceptions = true,
  })  : _logManager = logManager,
        _permissionManager = permissionManager,
        _settings = customSettings;

  final LogManager? _logManager;
  final PermissionManager? _permissionManager;
  final FlutterLocalNotificationsPlugin localNotificationPlugin;

  final ReceivedLocalNotificationCallback? receiveLocalNotificationCallback;
  final ReceivedNotificationResponseCallback?
      receiveNotificationResponseCallback;
  final ReceivedNotificationResponseCallback?
      receiveBackgroundNotificationResponseCallback;
  final CustomLocalNotificationSettings _settings;
  final bool rethrowExceptions;

  @override
  Future<bool> initialize() async {
    try {
      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        _settings.channelId,
        _settings.channelName,
        description: _settings.channelDescription,
        importance: _settings.importance.toLocalImportance,
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

      final tz.TZDateTime timezonedDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      await localNotificationPlugin.zonedSchedule(
        id,
        title,
        body,
        timezonedDate,
        _platformSpecificDetails,
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

  NotificationDetails get _platformSpecificDetails => NotificationDetails(
        android: _androidDetails,
        iOS: _iOSDetails,
        linux: _linuxDetails,
      );

  AndroidNotificationDetails get _androidDetails => AndroidNotificationDetails(
        _settings.channelId,
        _settings.channelName,
        channelDescription: _settings.channelDescription,
        importance: _settings.importance.toLocalImportance,
        priority: _settings.priority.toLocalPriority,
        enableVibration: _settings.enableVibration,
        vibrationPattern: _settings.vibrationPattern,
        enableLights: _settings.enableLights,
        ledColor: _settings.ledColor,
        sound: _settings.sound != null
            ? RawResourceAndroidNotificationSound(_settings.sound!)
            : null,
        ticker: _settings.ticker,
        visibility: _settings.visibility == NotificationVisibility.public
            ? NotificationVisibility.public
            : _settings.visibility == NotificationVisibility.secret
                ? NotificationVisibility.secret
                : NotificationVisibility.private,
        category: _settings.category?.toLocalAndroidCategory,
        timeoutAfter: _settings.timeoutAfter,
        ongoing: _settings.ongoing,
        autoCancel: _settings.autoCancel,
        onlyAlertOnce: _settings.onlyAlertOnce,
        showWhen: _settings.showWhen,
        usesChronometer: _settings.usesChronometer,
      );

  DarwinNotificationDetails get _iOSDetails => DarwinNotificationDetails(
        presentAlert: _settings.presentAlert,
        presentBadge: _settings.presentBadge,
        presentSound: _settings.presentSound,
        badgeNumber: _settings.badgeNumber,
        threadIdentifier: _settings.threadIdentifier,
        interruptionLevel:
            _settings.interruptionLevel?.toDarwinInterruptionLevel,
        subtitle: _settings.subtitle,
        sound: _settings.sound,
        attachments: _settings.attachments
            ?.map((attachment) =>
                DarwinNotificationAttachment(attachment['identifier'] ?? ''))
            .toList(),
      );

  LinuxNotificationDetails get _linuxDetails => LinuxNotificationDetails(
        urgency: _settings.importance.toLocalLinuxUrgency,
        resident: _settings.resident,
        suppressSound: _settings.suppressSound,
        transient: _settings.transient,
        actions: _settings.actions
            .map((action) => LinuxNotificationAction(
                  key: action['key'] ?? '',
                  label: action['label'] ?? '',
                ))
            .toList(),
      );

  // You can customize this implementation.
  bool get isEnabled => true;
}
