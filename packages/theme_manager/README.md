# Theme Manager

The `theme_manager` module provides a unified interface for managing themes in Flutter applications. This module is designed to facilitate theme switching and customization.

## Features

- Switch between light and dark themes
- Set custom themes
- Toggle between light and dark modes
- Get current theme and theme mode

## Installation

To use the `theme_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  theme_manager:
    path: ../packages/theme_manager
```

## Usage

Here's a basic example of how to use the `theme_manager` module:

```dart
import 'package:theme_manager/theme_manager.dart';
import 'package:flutter/material.dart';

// Initialize the theme manager
final themeManager = ThemeManagerImpl(
  initialTheme: ThemeModel(
    name: 'Default',
    lightTheme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
  ),
  initialMode: ThemeMode.system,
);

// Use it in your code
await themeManager.setThemeMode(ThemeMode.dark);
await themeManager.toggleTheme();

// Get current theme
final currentTheme = themeManager.currentTheme;
```

For more detailed usage instructions and advanced features, please refer to the documentation.
