# Cache Manager

The `cache_manager` module provides a unified, platform-independent interface for managing cache operations in Flutter applications. This module is designed to facilitate efficient data storage and retrieval for improved app performance.

## Features

- Store and retrieve data with optional expiry
- Remove specific cache entries
- Clear all cached data
- Check if a key exists in the cache
- Get the current size of the cache
- Set maximum cache size
- Retrieve all cache keys
- Retrieve all cached data
- Batch insert multiple entries

## Installation

To use the `cache_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  cache_manager:
    path: ../packages/cache_manager
```

## Usage

Here's a basic example of how to use the `cache_manager` module:

```dart
import 'package:cache_manager/cache_manager.dart';

// Initialize the cache manager
final cacheManager = CacheManagerImpl(logManager: yourLogManager);

// Use it in your code
final result = await cacheManager.put('user_data', {'name': 'John Doe', 'age': 30}, expiry: Duration(hours: 1));
if (result == CacheOperationResult.success) {
  print('User data cached successfully');
}

// Retrieve cached data
final userData = await cacheManager.get<Map<String, dynamic>>('user_data');
if (userData != null) {
  print('Retrieved user data: $userData');
}
```

For more detailed usage instructions and advanced features, please refer to the documentation.
