# Push Notification Manager

The `push_notification_manager` module provides a unified interface for managing push notifications in Flutter applications. This module is designed to facilitate the handling of push notifications.

## Features

- Request permission for push notifications.
- Handle incoming push notifications.
- Manage notification settings.

## Installation

To use the `push_notification_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  push_notification_manager:
    path: ../packages/push_notification_manager
```

## Usage

Here's a basic example of how to use the `push_notification_manager` module:

```dart
import 'package:push_notification_manager/push_notification_manager.dart';

// Initialize the push notification manager
final pushNotificationManager = PushNotificationManager();

// Use it in your code
await pushNotificationManager.requestPermission();
```
