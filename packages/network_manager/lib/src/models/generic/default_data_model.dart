import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/foundation.dart';

import '../data_model.dart';

part 'default_data_model.mapper.dart';

/// A type alias for [DefaultDataModel].
typedef WD<T> = DefaultDataModel<T>;

/// Represents a default data model.
///
/// This model is used to store default data information.
@MappableClass(hook: DefaultDataHook())
@immutable
base class DefaultDataModel<T>
    with DefaultDataModelMappable<T>
    implements DataModel<DefaultDataModel<T>> {
  /// Creates a new instance of [DefaultDataModel] with the
  /// given [resultMessage]
  const DefaultDataModel({
    required this.resultMessage,
    required this.resultCode,
    required this.data,
  });

  /// The result messages associated with the default data.
  final Map<LanguageTypes, String>? resultMessage;

  /// The result code of the default data.
  final String? resultCode;

  /// The data of the default data.
  final T? data;
}

/// Enum representing different language types.
///
/// The available language types are:
/// - `en`: English
/// - `tr`: Turkish
@MappableEnum()
enum LanguageTypes {
  /// English
  en('en', 'English', 'English'),

  /// Turkish
  tr('tr', 'Türkçe', 'Turkish'),

  /// German
  de('de', 'Deutsch', 'German'),

  /// French
  fr('fr', 'Français', 'French');

  const LanguageTypes(this.code, this.localName, this.englishName);

  /// Language code.
  final String code;

  /// Local name of the language.
  final String localName;

  /// English name of the language.
  final String englishName;
}

/// A hook class used for decoding default data models.
/// This hook removes the 'resultMessage' and 'resultCode' keys from the input
/// map and returns a new map with the remaining keys and values.
@immutable
final class DefaultDataHook extends MappingHook {
  /// Creates a new instance of [DefaultDataHook].
  const DefaultDataHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is Map<String, dynamic>) {
      const String resultMessageKey = 'resultMessage';
      const String resultCodeKey = 'resultCode';
      Object? resultMessage = value[resultMessageKey];
      resultMessage ??= value['message'];
      final Object? resultCode = value[resultCodeKey];
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(value)
        ..remove(resultMessageKey)
        ..remove(resultCodeKey);
      return <String, dynamic>{
        resultMessageKey: resultMessage,
        resultCodeKey: resultCode,
        'data': dataMap,
      };
    }
    return value;
  }
}
