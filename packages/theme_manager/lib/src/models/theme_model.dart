import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// ThemeModel is a class that holds the theme data for the app.
@immutable
base class ThemeModel extends Equatable {
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

  @override
  List<Object?> get props => <Object?>[name, lightTheme, darkTheme];
}
