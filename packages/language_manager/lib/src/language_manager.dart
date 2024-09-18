import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

/// The base interface for language managers.
abstract class LanguageManager {
  /// Constructor.
  LanguageManager(this._logManager);
  final LogManager _logManager;
  String _currentLanguageCode = 'en';

  /// Gets the current language code.
  String get currentLanguageCode => _currentLanguageCode;

  /// Sets the current language.
  @mustCallSuper
  bool setLanguage(String newLanguageCode) {
    if (newLanguageCode == _currentLanguageCode) return true;
    if (supportedLanguageCodes.contains(newLanguageCode)) {
      _currentLanguageCode = newLanguageCode;
      _logManager
          .lInfo('LanguageManager: Language changed to: $newLanguageCode');
      return true;
    } else {
      _logManager.lWarning(
        'LanguageManager: Language not supported: $newLanguageCode',
      );
      return false;
    }
  }

  /// Sets the current locale.
  Locale setLocale(Locale languageCode);

  /// Stream of the current language code.
  Stream<String> get languageCodeStream;

  /// Gets the list of supported locales.
  List<Locale> get locales;

  /// Stream of the current app locale.
  Stream<Locale> get appLocaleStream;

  /// Gets the current locale.
  Locale? get currentLocale =>
      langLocale(_currentLanguageCode) ?? const Locale('en', 'US');

  /// Gets the locale for the given language code.
  Locale? langLocale(String languageCode) =>
      locales.firstWhereOrNull((Locale l) => l.languageCode == languageCode);

  /// Gets the list of supported language codes.
  List<String> get supportedLanguageCodes =>
      locales.map((Locale l) => l.languageCode).toList();
}
