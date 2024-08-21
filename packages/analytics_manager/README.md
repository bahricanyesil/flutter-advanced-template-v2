# Analytics Manager

The `analytics_manager` module provides a unified interface for managing analytics services in Flutter applications. This module is designed to facilitate the integration of various analytics platforms, with built-in support for Firebase Analytics.

## Features

- **Log Events:** Track custom events in your app.
- **Set User Properties:** Assign properties to users for more detailed analytics.
- **Log Screen Views:** Record screen views to analyze user navigation.

## Installation

To use the `analytics_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  analytics_manager:
    path: ../packages/analytics_manager
```

## Usage

Here's a basic example of how to use the `analytics_manager` module:

### Import the Module

```dart
import 'package:analytics_manager/analytics_manager.dart';
```

### Initialize `AnalyticsManager`

```dart
final IAnalyticsManager analyticsManager = IAnalyticsManager.instance;
```
