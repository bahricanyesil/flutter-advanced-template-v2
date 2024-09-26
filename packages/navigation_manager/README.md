# Navigation Manager

The `navigation_manager` module provides a unified interface for managing navigation in Flutter applications. This module is designed to facilitate the routing and handling of navigation events.

## Features

- Manage navigation routes.
- Handle deep linking.
- Support for named routes.

## Installation

To use the `navigation_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  navigation_manager:
    path: ../packages/navigation_manager
```

## Usage

Here's a basic example of how to use the `navigation_manager` module:

```dart
import 'package:navigation_manager/navigation_manager.dart';

// Initialize the navigation manager
final navigationManager = NavigationManager();

// Use it in your code
navigationManager.navigateTo('/home');
```
