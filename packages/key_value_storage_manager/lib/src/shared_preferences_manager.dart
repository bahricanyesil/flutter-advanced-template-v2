import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'exceptions/index.dart';
import 'key_value_storage_manager.dart';
import 'models/data_model.dart';
import 'utils/data_parser_helpers.dart';
import 'utils/extensions/iterable_extensions.dart';

/// This is a concrete class for shared preferences storage.
/// It implements the [KeyValueStorageManager] interface.
@immutable
final class SharedPreferencesManager implements KeyValueStorageManager {
  /// Constructor for SharedPreferencesManager.
  const SharedPreferencesManager({required this.preferences});

  /// Instance of [SharedPreferences].
  final SharedPreferences preferences;

  static const List<Type> _supportedTypes = <Type>[
    String,
    int,
    double,
    bool,
    DataModel,
    List,
  ];

  @override
  List<Type> get supportedTypes => _supportedTypes;

  @override
  bool containsKey(String key) => preferences.containsKey(key);

  @override
  Future<bool> delete({required String key}) async {
    if (!containsKey(key)) return false;
    return preferences.remove(key);
  }

  @override
  Future<bool> deleteAll() async => preferences.clear();

  @override
  T? read<T>(
    String key, {
    bool tryToParse = false,
    FromJsonFunction<T>? fromJson,
  }) {
    final Object? value = preferences.get(key);
    if (value is T || value == null) return value as T?;
    if (!tryToParse) {
      final Type valType = value.runtimeType;
      throw MismatchedTypeException(expectedType: T, actualType: valType);
    }
    final Exception cannotParseError =
        UnsuccessfulParseException(expectedType: T, value: value);
    if (DataParserHelpers.isSupportedPrimitive<T>()) {
      return DataParserHelpers.parsePrimitive<T>(value);
    }
    if (value is List) {
      throw UnsuccessfulParseException(
        expectedType: T,
        value: value,
        customMessage:
            '''If you want to parse list of models (INetworkData), please use readModelList function''',
      );
    }
    if (value is! String) throw cannotParseError;
    final T? parsedModel = fromJson?.call(value);
    if (parsedModel != null) return parsedModel;
    throw cannotParseError;
  }

  @override
  Future<bool> write<T>({
    required String key,
    required T value,
    bool defaultToString = false,
  }) async {
    if (key.isEmpty) throw const EmptyKeyException();
    switch (T) {
      case String:
        return preferences.setString(key, value as String);
      case int:
        return preferences.setInt(key, value as int);
      case double:
        return preferences.setDouble(key, value as double);
      case bool:
        return preferences.setBool(key, value as bool);
      case const (List<String>):
        return preferences.setStringList(key, value as List<String>);
    }

    if (value is List) return _writeList(value, key);
    if (value is DataModel) return preferences.setString(key, value.toJson());
    if (defaultToString) return preferences.setString(key, value.toString());

    throw const UnsupportedTypeException(supportedTypes: _supportedTypes);
  }

  Future<bool> _writeList(List<Object?> value, String key) {
    late final List<String> stringList;
    if (value is List<DataModel<Object?>>) {
      stringList = value.map((DataModel<Object?> e) => e.toJson()).toList();
    } else {
      stringList = value.mapFromStringIterable<String>().toList();
    }
    return preferences.setStringList(key, stringList);
  }

  @override
  List<T>? readModelList<T extends DataModel<T>>(
    String key,
    FromJsonFunction<T> fromJson,
  ) {
    final List<String>? stringList = read<List<String>>(key, tryToParse: true);
    if (stringList == null) return null;
    final List<T> result =
        stringList.mapToIterable<T>((String? e) => fromJson.call(e)).toList();
    return result;
  }
}
