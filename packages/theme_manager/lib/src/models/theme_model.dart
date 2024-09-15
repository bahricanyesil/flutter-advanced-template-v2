import 'package:flutter/material.dart';

import 'app_theme_data.dart';

/// ThemeModel is a class that holds the theme data for the app.
@immutable
base class ThemeModel {
  /// ThemeModel is a class that holds the theme data for the app.
  const ThemeModel({required this.name, required this.appThemeData});

  /// Name of the theme.
  final String name;

  /// Theme data for the app.
  final AppThemeData appThemeData;
}
