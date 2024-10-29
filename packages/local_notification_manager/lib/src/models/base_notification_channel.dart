import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../local_notification_manager.dart';

/// The base class for notification channels.
/// This class is used to create a notification channel.
///
/// The [channelId] is a unique identifier for the channel.
/// The [channelName] is the name of the channel.
/// The [channelDescription] is the description of the channel.
/// The [importance] is the importance of the channel.
base class BaseNotificationChannel {
  /// Creates a new notification channel.
  const BaseNotificationChannel({
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.importance,
    this.playSound = true,
    this.enableVibration = true,
    this.enableLights = false,
    this.vibrationPattern,
    this.ledColor,
    this.groupId,
    this.showBadge = true,
    this.sound,
  });

  /// The unique identifier for the channel.
  final String channelId;

  /// The name of the channel.
  final String channelName;

  /// The description of the channel.
  final String channelDescription;

  /// The importance of the channel.
  final NotificationImportance importance;

  /// Whether to play a sound when a notification is shown.
  final bool playSound;

  /// Whether to enable vibration when a notification is shown.
  final bool enableVibration;

  /// The vibration pattern when a notification is shown.
  final Int64List? vibrationPattern;

  /// The color of the LED light when a notification is shown.
  final Color? ledColor;

  /// Whether to enable lights when a notification is shown.
  final bool enableLights;

  /// The group identifier for the channel.
  final String? groupId;

  /// Whether to show a badge when a notification is shown.
  final bool showBadge;

  /// The sound to play when a notification is shown.
  final String? sound;
}
