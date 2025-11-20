import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:key_value_storage_manager/key_value_storage_manager.dart';
import 'package:log_manager/log_manager.dart';

import 'package:theme_manager/theme_manager.dart';

/// ThemeManagerImpl is a class that implements the ThemeManager interface.
/// It is used to manage the themes for the app.
final class ThemeManagerImpl implements ThemeManager {
  /// ThemeManagerImpl is a class that implements the ThemeManager interface.
  /// It is used to manage the themes for the app.
  ThemeManagerImpl({
    required ThemeModel initialTheme,
    ThemeMode initialMode = ThemeMode.system,
    LogManager? logManager,
    KeyValueStorageManager? storageManager,
  })  : _currentTheme = initialTheme,
        _storageManager = storageManager,
        _currentThemeMode = initialMode,
        _logManager = logManager {
    _initializeThemeMode(initialMode);
  }
  static const String _themeModeKey = 'theme_mode';

  final LogManager? _logManager;
  final KeyValueStorageManager? _storageManager;
  ThemeModel _currentTheme;
  ThemeMode _currentThemeMode;

  @override
  ThemeMode get currentThemeMode => _currentThemeMode;

  @override
  ThemeModel get currentTheme => _currentTheme;

  Future<void> _initializeThemeMode(ThemeMode initialMode) async {
    final String? storedMode = _storageManager?.read<String>(_themeModeKey);
    if (storedMode != null) {
      _currentThemeMode = ThemeMode.values.firstWhere(
        (ThemeMode mode) => mode.name == storedMode,
        orElse: () => initialMode,
      );
    } else {
      _currentThemeMode = initialMode;
    }
    await setThemeMode(_currentThemeMode);
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    _currentThemeMode = mode;
    await _storageManager?.write<String>(key: _themeModeKey, value: mode.name);
    SystemChrome.setSystemUIOverlayStyle(
      switch (mode) {
        ThemeMode.light => SystemUiOverlayStyle.dark,
        ThemeMode.dark => SystemUiOverlayStyle.light,
        ThemeMode.system => _isSystemLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      },
    );
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
      ThemeMode.system => _isSystemLight ? ThemeMode.dark : ThemeMode.light,
    };
    await setThemeMode(newMode);
  }

  bool get _isSystemLight =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.light;
}
