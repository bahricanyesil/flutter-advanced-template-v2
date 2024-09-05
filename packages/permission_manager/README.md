# Permission Manager

The `permission_manager` module provides a unified interface for managing permissions in Flutter applications. This module is designed to facilitate the request and handling of permissions.

## Features

- Request permissions from users.
- Check permission statuses.
- Handle permission request responses.

## Installation

To use the `permission_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  permission_manager:
    path: ../packages/permission_manager
```

## Usage

Here's a basic example of how to use the `permission_manager` module:

```dart
import 'package:permission_manager/permission_manager.dart';

// Initialize the permission manager
final permissionManager = PermissionManager();

// Use it in your code
await permissionManager.requestPermission(Permission.camera);
```
