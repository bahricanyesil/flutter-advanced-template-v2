import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:theme_manager/src/models/theme_model.dart';

/// ThemeEvent is a class that represents an event in the theme manager.
sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// ToggleThemeEvent is a class that represents an event in the theme manager.
@immutable
final class ToggleThemeEvent extends ThemeEvent {}

/// SetThemeModeEvent is a class that represents an event in the theme manager.
@immutable
final class SetThemeModeEvent extends ThemeEvent {
  /// SetThemeModeEvent is a class that represents an event
  /// in the theme manager.
  const SetThemeModeEvent(this.themeMode);

  /// Theme mode.
  final ThemeMode themeMode;

  @override
  List<Object?> get props => <Object?>[themeMode];
}

/// SetThemeModelEvent is a class that represents an event in the theme manager.

@immutable
final class SetThemeModelEvent extends ThemeEvent {
  /// SetThemeModelEvent is a class that represents an event
  /// in the theme manager.
  const SetThemeModelEvent(this.themeModel);

  /// Theme model.
  final ThemeModel themeModel;

  @override
  List<Object?> get props => <Object?>[themeModel];
}
