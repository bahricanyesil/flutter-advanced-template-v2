import 'package:flutter/foundation.dart';

import 'package:key_value_storage_manager/src/models/base_data_model.dart';

/// The function to convert the JSON to the required type.
typedef FromJsonFunction<T> = T? Function(String json);

/// The base class for the key-value storage manager.
@immutable
abstract interface class KeyValueStorageManager {
  /// The list of supported types.
  List<Type> get supportedTypes;

  /// Writes the value to the storage.
  Future<bool> write<T>({
    required String key,
    required T value,
    bool defaultToString = false,
  });

  /// Reads the value from the storage.
  T? read<T>(
    String key, {
    bool tryToParse = false,
    FromJsonFunction<T>? fromJson,
  });

  /// Deletes the value from the storage.
  Future<bool> delete({required String key});

  /// Deletes all the values from the storage.
  Future<bool> deleteAll();

  /// Checks if the key is present in the storage.
  bool containsKey(String key);

  /// Reads the list of models from the storage.
  List<T>? readModelList<T extends BaseDataModel<T>>(
    String key,
    FromJsonFunction<T> fromJson,
  );
}
