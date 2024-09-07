import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notification_manager/src/models/custom_notification_response_model.dart';
import 'package:log_manager/log_manager.dart';
import 'package:permission_manager/permission_manager.dart';
import 'package:timezone/timezone.dart' as tz;

import 'local_notification_manager.dart';
import 'models/custom_notification_settings.dart';

typedef ReceivedLocalNotificationCallback = Function(
  int id,
  String? title,
  String? body,
  String? payload,
);

typedef ReceivedNotificationResponseCallback = Function(
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

  @override
  Future<void> initialize() async {
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

    final PermissionStatusTypes? statusType =
        await _permissionManager?.checkPermission(PermissionTypes.notification);
    if (statusType?.isGranted == false) {
      await _permissionManager?.requestPermission(PermissionTypes.notification);
    }

    _logManager?.lDebug('LocalNotificationManagerImpl initialized');
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!isEnabled) return;
    final PermissionStatusTypes? statusType =
        await _permissionManager?.checkPermission(PermissionTypes.notification);
    if (statusType?.isGranted == false) {
      _logManager?.lError('No permission to show notification');
      return;
    }
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: _androidDetails);
    await localNotificationPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);

    _logManager?.lDebug(
      '''Notification shown: {id: $id, title: $title, body: $body, payload: $payload}''',
    );
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!isEnabled) return;
    final PermissionStatusTypes? statusType =
        await _permissionManager?.checkPermission(PermissionTypes.notification);
    if (statusType?.isGranted == false) {
      _logManager?.lError('No permission to show notification');
      return;
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
  }

  @override
  Future<void> cancelNotification(int id) async {
    await localNotificationPlugin.cancel(id);
    _logManager?.lDebug('Notification canceled: id $id');
  }

  @override
  Future<void> cancelAllNotifications() async {
    await localNotificationPlugin.cancelAll();
    _logManager?.lDebug('All notifications canceled');
  }

  @override
  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    _logManager?.lDebug(
      '''Notification received: {id: $id, title: $title, body: $body, payload: $payload}''',
    );
    receiveLocalNotificationCallback?.call(id, title, body, payload);
  }

  @override
  void onDidReceiveBackgroundNotificationResponse(
    CustomNotificationResponseModel response,
  ) {
    _logManager?.lDebug(
      '''Background notification response received: {id: ${response.id}, actionId: ${response.actionId}, input: ${response.input}, payload: ${response.payload}}''',
    );
    receiveBackgroundNotificationResponseCallback?.call(response);
  }

  @override
  void onDidReceiveNotificationResponse(
    CustomNotificationResponseModel response,
  ) {
    _logManager?.lDebug(
      '''Notification response received: {id: ${response.id}, actionId: ${response.actionId}, input: ${response.input}, payload: ${response.payload}}''',
    );
    receiveNotificationResponseCallback?.call(response);
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
