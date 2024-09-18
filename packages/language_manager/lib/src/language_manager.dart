import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

/// The base interface for language managers.
abstract class LanguageManager {
  /// Constructor.
  LanguageManager({LogManager? logManager}) : _logManager = logManager {
    _languageController = StreamController<String>.broadcast();
  }

  final LogManager? _logManager;
  late final StreamController<String> _languageController;
  String _currentLanguageCode = 'en';

  /// Gets the current language code.
  String get currentLanguageCode => _currentLanguageCode;

  /// Sets the current locale.
  @protected
  Future<Locale> setLocale(Locale locale);

  /// Stream of the current language code.
  Stream<String> get languageCodeStream => _languageController.stream;

  /// Gets the list of supported locales.
  List<Locale> get supportedLocales;

  /// Stream of the current app locale.
  Stream<Locale> get appLocaleStream;

  /// Gets the current locale.
  Locale? get currentLocale => supportedLocales
      .firstWhereOrNull((Locale l) => l.languageCode == currentLanguageCode);

  /// Gets the list of supported language codes.
  List<String> get supportedLanguageCodes => supportedLocales
      .map((Locale l) => l.languageCode)
      .toList(growable: false);

  /// Sets the language code.
  ///
  /// Returns true if the language code was set successfully, false otherwise.
  @mustCallSuper
  Future<bool> setLanguage(String newLanguageCode) async {
    if (newLanguageCode.isEmpty) {
      _logManager?.lWarning('Empty language code provided');
      return false;
    }

    if (!isLanguageSupported(newLanguageCode)) {
      _logManager?.lWarning('Language not supported: $newLanguageCode');
      return false;
    }

    if (newLanguageCode == _currentLanguageCode) return true;

    final Locale? newLocale = getLocaleForLanguageCode(newLanguageCode);
    if (newLocale == null) {
      _logManager?.lWarning('No matching locale found for: $newLanguageCode');
      return false;
    }

    try {
      final Locale appLocaleResult = await setLocale(newLocale);
      if (!isLocaleEqual(appLocaleResult, newLocale)) {
        _logManager?.lWarning(
          'Locale mismatch: expected $newLocale, got $appLocaleResult',
        );
        return false;
      }

      updateCurrentLanguage(newLanguageCode);
      _logManager?.lInfo('Language changed to: $newLanguageCode');
      return true;
    } catch (e, stackTrace) {
      _logManager?.lError('Error setting language: $e', stackTrace: stackTrace);
      return false;
    }
  }

  /// Checks if the language code is supported.
  @protected
  bool isLanguageSupported(String languageCode) =>
      languageCode.isNotEmpty && supportedLanguageCodes.contains(languageCode);

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

  /// Updates the current language code.
  @protected
  void updateCurrentLanguage(String newLanguageCode) {
    if (newLanguageCode.isNotEmpty && newLanguageCode != _currentLanguageCode) {
      _currentLanguageCode = newLanguageCode;
      _languageController.add(_currentLanguageCode);
    }
  }

  /// Dispose of the language manager.
  @mustCallSuper
  void dispose() {
    _languageController.close();
  }
}
