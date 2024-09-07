import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../enums/notification_category.dart';
import '../enums/notification_importance.dart';
import '../enums/notification_interruption_level.dart';
import '../enums/notification_priority.dart';
import '../enums/notification_visibility.dart';

class CustomLocalNotificationSettings {
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
  final String channelId;
  final String channelName;
  final String channelDescription;
  final String icon;
  final NotificationImportance importance;
  final NotificationPriority priority;
  final String? groupKey;
  final bool channelShowBadge;
  final bool playSound;
  final bool enableVibration;
  final bool enableLights;

  // Android specific
  final Int64List? vibrationPattern;
  final Color? ledColor;
  final String? sound;
  final String? ticker;
  final NotificationVisibility visibility;
  final NotificationCategory? category;
  final int? timeoutAfter;
  final bool ongoing;
  final bool autoCancel;
  final bool onlyAlertOnce;
  final bool showWhen;
  final bool usesChronometer;

  // iOS specific
  final bool presentAlert;
  final bool presentBadge;
  final bool presentSound;
  final int? badgeNumber;
  final String? threadIdentifier;
  final NotificationInterruptionLevel? interruptionLevel;
  final String? subtitle;
  final List<Map<String, String>>? attachments;

  // Linux specific
  final String defaultActionName;
  final String? urgency;
  final bool resident;
  final bool suppressSound;
  final bool transient;
  final List<Map<String, String>> actions;
}
