import 'dart:ui';

import 'package:collection/collection.dart';

import 'language_manager.dart';

/// A singleton class that manages the language settings of the application.
/// It implements the [LanguageManagerImpl] interface.
abstract class LanguageManagerImpl extends LanguageManager {
  /// Creates a new [LanguageManagerImpl] instance.
  LanguageManagerImpl({super.logManager});

  @override
  List<Locale> get locales;

  @override
  Locale? get currentLocale => locales
      .firstWhereOrNull((Locale l) => l.languageCode == currentLanguageCode);

  @override
  bool setLanguage(String newLanguageCode) {
    final Locale? newLocale = locales.firstWhereOrNull(
          (Locale locale) => locale.languageCode == newLanguageCode,
        ) ??
        currentLocale;
    if (newLocale == null) return false;
    final Locale appLocaleResult = setLocale(newLocale);
    if (appLocaleResult != newLocale) return false;
    final bool isSet = super.setLanguage(newLanguageCode);
    return isSet;
  }

  /// Stram of the current app locale.
  @override
  Stream<Locale> get appLocaleStream;

  /// Stram of the current language.
  @override
  Stream<String> get languageCodeStream => appLocaleStream.map(
        (Locale l) =>
            supportedLanguageCodes
                .firstWhereOrNull((String code) => l.languageCode == code) ??
            currentLanguageCode,
      );
}
