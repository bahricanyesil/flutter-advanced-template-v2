/// This is an abstract class for secure storage.
/// It contains the methods to write, read, delete, deleteAll and containsKey.
abstract interface class SecureStorageManager {
  /// Writes the value to the storage.
  Future<void> write({required String key, required String value});

  /// Reads the value from the storage.
  Future<String?> read({required String key});

  /// Deletes the value from the storage.
  Future<bool> delete({required String key});

  /// Deletes all the values from the storage.
  Future<void> deleteAll();

  /// Checks if the key is present in the storage.
  Future<bool> containsKey(String key);
}
