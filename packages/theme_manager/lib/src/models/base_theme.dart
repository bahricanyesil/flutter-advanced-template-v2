import 'package:flutter/material.dart';

/// Interface for defining a theme base class.
@immutable
abstract interface class BaseTheme {
  /// Gets the current [ThemeData].
  ThemeData get themeData;

  /// Gets the floating action button theme data.
  FloatingActionButtonThemeData get floatingActionButtonThemeData;

  /// Gets the current [ColorScheme].
  ColorScheme get colorScheme;
}
