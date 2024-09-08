# Key-Value Storage Manager

The `key_value_storage_manager` module provides a unified, platform-independent interface for managing key-value storage operations in Flutter applications. This module is designed to facilitate storing and retrieving various types of data using a key-value paradigm.

## Features

- Store and retrieve strings, integers, booleans, doubles, and string lists
- Check if a key exists
- Remove specific key-value pairs
- Clear all stored data
- Retrieve all stored key-value pairs

## Installation

To use the `key_value_storage_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  key_value_storage_manager:
    path: ../packages/key_value_storage_manager
```

## Usage

Here's a basic example of how to use the `key_value_storage_manager` module:

```dart
import 'package:key_value_storage_manager/key_value_storage_manager.dart';

// Initialize the key-value storage manager
final storageManager = KeyValueStorageManagerImpl(logManager: yourLogManager);

// Use it in your code
final result = await storageManager.setString('username', 'JohnDoe');
if (result == StorageOperationResult.success) {
  print('Username stored successfully');
}

// Retrieve a value
final username = await storageManager.getString('username');
print('Retrieved username: $username');
```

For more detailed usage instructions and advanced features, please refer to the documentation.
