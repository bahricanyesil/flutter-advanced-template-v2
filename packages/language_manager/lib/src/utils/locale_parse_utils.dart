import 'package:flutter/material.dart';

/// Utility class for parsing locale strings.
abstract final class LocaleParseUtils {
  /// Parses a locale string into a [Locale] object.
  ///
  /// The locale string should be in the format "language_country".
  /// If the country is not specified, it defaults to an empty string.
  static Locale parseLocale(String localeString) {
    final List<String> parts = localeString.split('_');
    if (parts.isEmpty) {
      throw ArgumentError('Invalid locale string: $localeString');
    }
    return Locale(parts[0], parts.length > 1 ? parts[1] : '');
  }
}
