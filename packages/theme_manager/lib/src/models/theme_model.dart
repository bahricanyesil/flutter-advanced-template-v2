import 'package:flutter/material.dart';

/// ThemeModel is a class that holds the theme data for the app.
@immutable
final class ThemeModel {
  /// ThemeModel is a class that holds the theme data for the app.
  const ThemeModel({
    required this.name,
    required this.lightTheme,
    required this.darkTheme,
  });

  /// Name of the theme.
  final String name;

  /// Light theme data.
  final ThemeData lightTheme;

  /// Dark theme data.
  final ThemeData darkTheme;
}
