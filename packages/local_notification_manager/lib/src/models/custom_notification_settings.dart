import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationSettings {
  const NotificationSettings({
    this.channelId = 'default_channel',
    this.channelName = 'Default Channel',
    this.channelDescription = 'Default notification channel',
    this.icon = '@mipmap/ic_launcher',
    this.importance = Importance.defaultImportance,
    this.priority = Priority.defaultPriority,
  });

  final String channelId;
  final String channelName;
  final String channelDescription;
  final String icon;
  final Importance importance;
  final Priority priority;
}
