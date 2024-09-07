import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as local;

import '../enums/notification_category.dart';
import '../enums/notification_importance.dart';
import '../enums/notification_interruption_level.dart';
import '../enums/notification_priority.dart';
import '../enums/notification_visibility.dart';

/// Custom local notification settings.
class CustomLocalNotificationSettings {
  /// Creates an instance of [CustomLocalNotificationSettings].
  const CustomLocalNotificationSettings({
    // Common settings
    this.channelId = 'default_channel',
    this.channelName = 'Default Channel',
    this.channelDescription = 'Default notification channel',
    this.icon = 'app_icon',
    this.importance = NotificationImportance.normal,
    this.priority = NotificationPriority.normal,
    this.groupKey,
    this.channelShowBadge = true,
    this.playSound = true,
    this.enableVibration = true,
    this.enableLights = true,

    // Android specific
    this.vibrationPattern,
    this.ledColor,
    this.sound,
    this.ticker,
    this.visibility = NotificationVisibility.private,
    this.category,
    this.timeoutAfter,
    this.ongoing = false,
    this.autoCancel = true,
    this.onlyAlertOnce = false,
    this.showWhen = true,
    this.usesChronometer = false,

    // iOS specific
    this.presentAlert = true,
    this.presentBadge = true,
    this.presentSound = true,
    this.badgeNumber,
    this.threadIdentifier,
    this.interruptionLevel,
    this.subtitle,
    this.attachments,

    // Linux specific
    this.defaultActionName = 'Open',
    this.urgency,
    this.resident = false,
    this.suppressSound = false,
    this.transient = false,
    this.actions = const <Map<String, String>>[],
  });

  // Common settings
  /// The id of the notification channel.
  final String channelId;

  /// The name of the notification channel.
  final String channelName;

  /// The description of the notification channel.
  final String channelDescription;

  /// The icon of the notification.
  final String icon;

  /// The importance of the notification.
  final NotificationImportance importance;

  /// The priority of the notification.
  final NotificationPriority priority;

  /// The key of the group of notifications.
  final String? groupKey;

  /// Whether the channel should show the badge.
  final bool channelShowBadge;

  /// Whether the notification should play sound.
  final bool playSound;

  /// Whether the notification should enable vibration.
  final bool enableVibration;

  /// Whether the notification should enable lights.
  final bool enableLights;

  // Android specific
  /// The vibration pattern of the notification.
  final Int64List? vibrationPattern;

  /// The color of the notification.
  final Color? ledColor;

  /// The sound of the notification.
  final String? sound;

  /// The ticker of the notification.
  final String? ticker;

  /// The visibility of the notification.
  final NotificationVisibility visibility;

  /// The category of the notification.
  final NotificationCategory? category;

  /// The timeout after which the notification should be canceled.
  final int? timeoutAfter;

  /// Whether the notification should be ongoing.
  final bool ongoing;

  /// Whether the notification should be auto-canceled.
  final bool autoCancel;

  /// Whether the notification should only alert once.
  final bool onlyAlertOnce;

  /// Whether the notification should show when.
  final bool showWhen;

  /// Whether the notification should use the chronometer.
  final bool usesChronometer;

  // iOS specific
  /// Whether the notification should present the alert.
  final bool presentAlert;

  /// Whether the notification should present the badge.
  final bool presentBadge;

  /// Whether the notification should present the sound.
  final bool presentSound;

  /// The badge number of the notification.
  final int? badgeNumber;

  /// The thread identifier of the notification.
  final String? threadIdentifier;

  /// The interruption level of the notification.
  final NotificationInterruptionLevel? interruptionLevel;

  /// The subtitle of the notification.
  final String? subtitle;

  /// The attachments of the notification.
  final List<Map<String, String>>? attachments;

  // Linux specific
  /// The default action name of the notification.
  final String defaultActionName;

  /// The urgency of the notification.
  final String? urgency;

  /// Whether the notification should be resident.
  final bool resident;

  /// Whether the notification should suppress sound.
  final bool suppressSound;

  /// Whether the notification should be transient.
  final bool transient;

  /// The actions of the notification.
  final List<Map<String, String>> actions;
}

/// Extension for [CustomLocalNotificationSettings].
extension CustomLocalNotificationSettingsExtension
    on CustomLocalNotificationSettings {
  /// Get the corresponding [local.NotificationDetails].
  local.NotificationDetails get toLocalNotificationDetails =>
      local.NotificationDetails(
        android: _androidDetails,
        iOS: _iOSDetails,
        linux: _linuxDetails,
      );

  local.AndroidNotificationDetails get _androidDetails =>
      local.AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: importance.toLocalImportance,
        priority: priority.toLocalPriority,
        enableVibration: enableVibration,
        vibrationPattern: vibrationPattern,
        enableLights: enableLights,
        ledColor: ledColor,
        sound: sound != null
            ? local.RawResourceAndroidNotificationSound(sound)
            : null,
        ticker: ticker,
        visibility: visibility.toLocalAndroidVisibility,
        category: category?.toLocalAndroidCategory,
        timeoutAfter: timeoutAfter,
        ongoing: ongoing,
        autoCancel: autoCancel,
        onlyAlertOnce: onlyAlertOnce,
        showWhen: showWhen,
        usesChronometer: usesChronometer,
      );

  local.DarwinNotificationDetails get _iOSDetails =>
      local.DarwinNotificationDetails(
        presentAlert: presentAlert,
        presentBadge: presentBadge,
        presentSound: presentSound,
        badgeNumber: badgeNumber,
        threadIdentifier: threadIdentifier,
        interruptionLevel: interruptionLevel?.toDarwinInterruptionLevel,
        subtitle: subtitle,
        sound: sound,
        attachments: attachments
            ?.map(
              (Map<String, String> attachment) =>
                  local.DarwinNotificationAttachment(
                attachment['identifier'] ?? '',
              ),
            )
            .toList(),
      );

  local.LinuxNotificationDetails get _linuxDetails =>
      local.LinuxNotificationDetails(
        urgency: importance.toLocalLinuxUrgency,
        resident: resident,
        suppressSound: suppressSound,
        transient: transient,
        actions: actions
            .map(
              (Map<String, String> action) => local.LinuxNotificationAction(
                key: action['key'] ?? '',
                label: action['label'] ?? '',
              ),
            )
            .toList(),
      );
}
