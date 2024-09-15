import 'package:flutter/material.dart';

/// Interface for defining a theme base class.
@immutable
abstract interface class BaseTheme {
  /// Gets the current [ThemeData].
  abstract final ThemeData themeData;

  /// Gets the floating action button theme data.
  abstract final FloatingActionButtonThemeData floatingActionButtonThemeData;

  /// Gets the current [ColorScheme].
  abstract final ColorScheme colorScheme;
}
