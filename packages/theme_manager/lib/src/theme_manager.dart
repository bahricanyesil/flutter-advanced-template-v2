import 'package:flutter/material.dart';

import 'models/theme_model.dart';

/// ThemeManager is an abstract class that provides a way to manage themes
/// for Flutter apps.
abstract class ThemeManager {
  /// Current theme mode.
  ThemeMode get currentThemeMode;

  /// Current theme.
  ThemeModel get currentTheme;

  /// Set the theme mode.
  Future<void> setThemeMode(ThemeMode mode);

  /// Set the theme.
  Future<void> setTheme(ThemeModel theme);

  /// Toggle the theme.
  Future<void> toggleTheme();
}
