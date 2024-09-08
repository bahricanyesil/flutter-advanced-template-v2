# Secure Storage Manager

The `secure_storage_manager` module provides a unified, platform-independent interface for managing secure storage operations in Flutter applications. This module is designed to facilitate storing and retrieving sensitive data securely.

## Features

- Securely store and retrieve string values
- Delete specific key-value pairs
- Clear all stored data
- Check if a key exists
- Retrieve all stored key-value pairs

## Installation

To use the `secure_storage_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  secure_storage_manager:
    path: ../packages/secure_storage_manager
```

## Usage

Here's a basic example of how to use the `secure_storage_manager` module:

```dart
import 'package:secure_storage_manager/secure_storage_manager.dart';

// Initialize the secure storage manager
final secureStorageManager = SecureStorageManagerImpl(logManager: yourLogManager);

// Use it in your code
final result = await secureStorageManager.write('apiKey', 'your-secret-api-key');
if (result == SecureStorageResult.success) {
  print('API key stored securely');
}

// Retrieve a value
final apiKey = await secureStorageManager.read('apiKey');
print('Retrieved API key: $apiKey');
```

For more detailed usage instructions and advanced features, please refer to the documentation.
