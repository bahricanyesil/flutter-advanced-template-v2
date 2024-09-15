import 'package:flutter/material.dart';
import 'package:log_manager/log_manager.dart';

import '../theme_manager.dart';

/// ThemeManagerImpl is a class that implements the ThemeManager interface.
/// It is used to manage the themes for the app.
final class ThemeManagerImpl implements ThemeManager {
  /// ThemeManagerImpl is a class that implements the ThemeManager interface.
  /// It is used to manage the themes for the app.
  ThemeManagerImpl({
    required ThemeModel initialTheme,
    ThemeMode initialMode = ThemeMode.system,
    LogManager? logManager,
  })  : _currentTheme = initialTheme,
        _currentThemeMode = initialMode,
        _logManager = logManager;

  final LogManager? _logManager;
  ThemeModel _currentTheme;
  ThemeMode _currentThemeMode;

  @override
  ThemeMode get currentThemeMode => _currentThemeMode;

  @override
  ThemeModel get currentTheme => _currentTheme;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _currentThemeMode = mode;
    _logManager?.lInfo('Theme mode set to: $mode');
  }

  @override
  Future<void> setThemeModel(ThemeModel theme) async {
    _currentTheme = theme;
    _logManager?.lInfo('Theme set to: ${theme.name}');
  }

  @override
  Future<void> toggleThemeMode() async {
    final ThemeMode newMode = switch (_currentThemeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.system,
    };
    await setThemeMode(newMode);
  }
}
