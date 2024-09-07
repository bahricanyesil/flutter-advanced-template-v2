# Local Notification Manager

The `local_notification_manager` module provides a unified interface for managing local notifications in Flutter applications. This module is designed to facilitate the handling of local notifications.

## Features

- Initialize local notification service
- Show notifications
- Cancel notifications
- Schedule notifications
- Check notification permissions

## Installation

To use the `local_notification_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  local_notification_manager:
    path: ../packages/local_notification_manager
```

## Usage

Here's a basic example of how to use the `local_notification_manager` module:

```dart
import 'package:local_notification_manager/local_notification_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Initialize the local notification manager
final localNotificationManager = LocalNotificationManagerImpl(
  flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
);

// Use it in your code
await localNotificationManager.initialize();
await localNotificationManager.showNotification(
  id: 1,
  title: 'Test Notification',
  body: 'This is a test notification',
);
```

For more detailed usage instructions, please refer to the API documentation.
