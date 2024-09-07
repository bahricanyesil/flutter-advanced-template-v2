import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as local;

enum NotificationVisibility { secret, private, public }

extension NotificationVisibilityExtension on NotificationVisibility {
  local.NotificationVisibility get toLocalAndroidVisibility => switch (this) {
        NotificationVisibility.secret => local.NotificationVisibility.secret,
        NotificationVisibility.private => local.NotificationVisibility.private,
        NotificationVisibility.public => local.NotificationVisibility.public,
      };
}
