import 'package:flutter/material.dart';

/// AppThemeData is an abstract interface class that
/// provides the theme data for the app.
abstract interface class AppThemeData {
  /// Light theme data.
  ThemeData get lightTheme;

  /// Dark theme data.
  ThemeData get darkTheme;
}
