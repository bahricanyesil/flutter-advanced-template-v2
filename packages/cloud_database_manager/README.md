# Cloud Database Manager

The `cloud_database_manager` module provides a unified, platform-independent interface for managing cloud-based database operations in Flutter applications. This module is designed to facilitate CRUD operations, querying, and streaming data from cloud-based databases.

## Features

- Add documents to collections
- Update existing documents
- Delete documents
- Retrieve single documents
- Stream collections
- Query documents with filters, sorting, and pagination
- Perform batch write operations
- Count documents in a collection

## Installation

To use the `cloud_database_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  cloud_database_manager:
    path: ../packages/cloud_database_manager
```

## Usage

Here's a basic example of how to use the `cloud_database_manager` module:

```dart
import 'package:cloud_database_manager/cloud_database_manager.dart';

// Initialize the cloud database manager
final databaseManager = CloudDatabaseManagerImpl(logManager: yourLogManager);

// Use it in your code
final result = await databaseManager.addDocument('users', {'name': 'John Doe', 'age': 30});
if (result == DatabaseOperationResult.success) {
  print('Document added successfully');
}

// Query documents
final users = await databaseManager.queryDocuments('users', where: {'age': 30}, orderBy: 'name', limit: 10);
for (var user in users) {
  print(user['name']);
}
```

For more detailed usage instructions and advanced features, please refer to the documentation.
