import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:key_value_storage_manager/key_value_storage_manager.dart';
import 'package:log_manager/log_manager.dart';

import 'utils/locale_parse_utils.dart';

/// The base interface for language managers.
abstract class LanguageManager {
  /// Constructor.
  LanguageManager({
    LogManager? logManager,
    KeyValueStorageManager? storageManager,
  })  : _logManager = logManager,
        _storageManager = storageManager {
    _localeController = StreamController<Locale>.broadcast();
  }

  final LogManager? _logManager;
  final KeyValueStorageManager? _storageManager;
  late final StreamController<Locale> _localeController;
  Locale _currentLocale = const Locale('en', 'us');

  static const String _localeStorageKey = 'app_locale_key';

  /// Get the locale storage key.
  String get localeStorageKey => _localeStorageKey;

  /// Initialize the language manager
  Future<void> initialize() async {
    final Locale? savedLocale = _loadSavedLocale();
    if (savedLocale != null) {
      await setLocale(savedLocale);
    }
  }

  /// Gets the current locale.
  Locale get currentLocale => _currentLocale;

  /// Stream of the current locale.
  Stream<Locale> get localeStream => _localeController.stream;

  /// Gets the list of supported locales.
  List<Locale> get supportedLocales;

  /// Stream of the current app locale.
  Stream<Locale> get appLocaleStream;

  /// Gets the list of supported language codes.
  List<String> get supportedLanguageCodes => supportedLocales
      .map((Locale l) => l.languageCode)
      .toList(growable: false);

  /// Sets the locale.
  ///
  /// Returns true if the locale was set successfully, false otherwise.
  @mustCallSuper
  Future<bool> setLocale(Locale newLocale) async {
    if (!isLocaleSupported(newLocale)) {
      _logManager?.lWarning('Locale not supported: $newLocale');
      return false;
    }

    if (newLocale == _currentLocale) return true;

    try {
      await _saveLocale(newLocale);
      updateCurrentLocale(newLocale);
      _logManager?.lInfo('Locale changed to: $newLocale');
      return true;
    } catch (e, stackTrace) {
      _logManager?.lError('Error setting locale: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// Checks if the locale is supported.
  @protected
  bool isLocaleSupported(Locale locale) => supportedLocales.contains(locale);

  /// Gets the locale for the given language code.
  @protected
  Locale? getLocaleForLanguageCode(String languageCode) => languageCode.isEmpty
      ? null
      : supportedLocales.firstWhereOrNull(
          (Locale locale) => locale.languageCode == languageCode,
        );

  /// Checks if two locales are equal.
  @protected
  bool isLocaleEqual(Locale locale1, Locale locale2) =>
      locale1.languageCode == locale2.languageCode &&
      locale1.countryCode == locale2.countryCode;

  /// Updates the current locale.
  @protected
  void updateCurrentLocale(Locale newLocale) {
    if (newLocale != _currentLocale) {
      _currentLocale = newLocale;
      _localeController.add(_currentLocale);
    }
  }

  /// Set the app locale
  @protected
  Future<Locale> setAppLocale(Locale locale);

  /// Load the saved locale
  Locale? _loadSavedLocale() {
    try {
      final String? storedLocale =
          _storageManager?.read<String>(_localeStorageKey);
      if (storedLocale == null) return null;
      return LocaleParseUtils.parseLocale(storedLocale);
    } catch (e, stackTrace) {
      _logManager?.lError(
        'Error loading saved locale: $e',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Save the locale
  Future<void> _saveLocale(Locale locale) async {
    try {
      await _storageManager?.write<String>(
        key: _localeStorageKey,
        value: locale.languageCode,
      );
    } catch (e, stackTrace) {
      _logManager?.lError(
        'Error saving locale: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Set up locale resolution
  Locale? localeResolutionCallback(Locale? locale) {
    if (locale == null) {
      if (supportedLocales.isEmpty) return null;
      return supportedLocales.first;
    }
    // Try to find a supported locale with the same language code
    final Locale? supportedLocale = supportedLocales
        .firstWhereOrNull((Locale l) => l.languageCode == locale.languageCode);
    // If not found, return the first supported locale
    return supportedLocale ?? supportedLocales.first;
  }

  /// Dispose of the language manager.
  @mustCallSuper
  void dispose() {
    _localeController.close();
  }
}
