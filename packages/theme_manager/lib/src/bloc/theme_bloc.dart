import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_manager/src/bloc/theme_event.dart';
import 'package:theme_manager/src/bloc/theme_state.dart';
import 'package:theme_manager/src/theme_manager.dart';

/// ThemeBloc is a class that manages the theme state.
final class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  /// Constructs a new ThemeBloc.
  ThemeBloc(this._themeManager)
      : super(
          ThemeState(
            themeMode: _themeManager.currentThemeMode,
            themeModel: _themeManager.currentTheme,
          ),
        ) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeModeEvent>(_onSetThemeMode);
    on<SetThemeModelEvent>(_onSetThemeModel);
  }
  final ThemeManager _themeManager;

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _themeManager.toggleThemeMode();
    emit(
      ThemeState(
        themeMode: _themeManager.currentThemeMode,
        themeModel: _themeManager.currentTheme,
      ),
    );
  }

  Future<void> _onSetThemeMode(
    SetThemeModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _themeManager.setThemeMode(event.themeMode);
    emit(
      ThemeState(
        themeMode: _themeManager.currentThemeMode,
        themeModel: state.themeModel,
      ),
    );
  }

  Future<void> _onSetThemeModel(
    SetThemeModelEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _themeManager.setThemeModel(event.themeModel);
    emit(
      ThemeState(
        themeMode: state.themeMode,
        themeModel: _themeManager.currentTheme,
      ),
    );
  }
}
