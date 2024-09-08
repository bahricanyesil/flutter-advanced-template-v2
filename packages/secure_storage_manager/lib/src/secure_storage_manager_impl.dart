import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage_manager.dart';

/// This is a concrete class for secure storage. It implements
/// the [SecureStorageManager] interface.
/// It uses [FlutterSecureStorage] to manage the secure storage.
/// It contains the methods to write, read, delete, deleteAll and containsKey.
@immutable
final class SecureStorageManagerImpl implements SecureStorageManager {
  /// Constructor for SecureStorageManagerImpl.
  const SecureStorageManagerImpl({required this.storage});

  /// Instance of [FlutterSecureStorage].
  final FlutterSecureStorage storage;

  @override
  Future<bool> containsKey(String key) async => storage.containsKey(key: key);

  @override
  Future<bool> delete({required String key}) async {
    final bool keyExists = await containsKey(key);
    if (keyExists) await storage.delete(key: key);
    return keyExists;
  }

  @override
  Future<void> deleteAll() async => storage.deleteAll();

  @override
  Future<String?> read({required String key}) async => storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) async =>
      storage.write(key: key, value: value);
}
