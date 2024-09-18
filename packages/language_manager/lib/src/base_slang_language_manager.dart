import 'dart:async';

import 'package:flutter/material.dart';

import 'language_manager.dart';

/// A base class for language managers that use Slang for translations.
abstract class BaseSlangLanguageManager extends LanguageManager {
  /// Constructor for the base slang language manager.
  BaseSlangLanguageManager({
    required this.supportedLocales,
    super.logManager,
  }) {
    _appLocaleController = StreamController<Locale>.broadcast();
  }

  @override
  final List<Locale> supportedLocales;

  late final StreamController<Locale> _appLocaleController;

  @override
  Stream<Locale> get appLocaleStream => _appLocaleController.stream;

  @override
  @protected
  Future<Locale> setLocale(Locale locale) async {
    final Locale newLocale = await setAppLocale(locale);
    _appLocaleController.add(newLocale);
    return newLocale;
  }

  @override
  Future<void> dispose() async {
    await _appLocaleController.close();
    super.dispose();
  }

  /// Initialize the language manager
  Future<void> initialize() async {
    final Locale? savedLocale = await loadSavedLocale();
    if (savedLocale != null) {
      await setLanguage(savedLocale.languageCode);
    }
  }

  /// Set the app locale
  @protected
  Future<Locale> setAppLocale(Locale locale);

  /// Load the saved locale
  @protected
  Future<Locale?> loadSavedLocale();

  /// Get translated string
  String translate(String key, {Map<String, dynamic>? args});

  /// Set up locale resolution
  Locale? localeResolutionCallback(Locale? locale, Iterable<Locale> supported) {
    if (locale == null) {
      return supportedLocales.first;
    }
    return basicLocaleListResolution(<Locale>[locale], supported);
  }

  /// Get the translations delegate
  LocalizationsDelegate<LocalizationsDelegate<Object?>>
      get translationsDelegate;
}
