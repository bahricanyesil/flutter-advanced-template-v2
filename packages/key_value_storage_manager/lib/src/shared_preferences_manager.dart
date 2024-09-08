import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_storage_manager.dart';
import 'models/data_model.dart';

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
}
