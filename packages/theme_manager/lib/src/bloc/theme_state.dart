import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:theme_manager/src/models/theme_model.dart';

/// ThemeState is a class that represents the state of the theme manager.
@immutable
final class ThemeState extends Equatable {
  /// ThemeState is a class that represents the state of the theme manager.
  const ThemeState({required this.themeMode, required this.themeModel});

  /// Theme mode.
  final ThemeMode themeMode;

  /// Theme model.
  final ThemeModel themeModel;

  @override
  List<Object?> get props => <Object?>[themeMode, themeModel];
}
