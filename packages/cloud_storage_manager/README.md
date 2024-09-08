# Cloud Storage Manager

The `cloud_storage_manager` module provides a unified, platform-independent interface for managing cloud-based file storage operations in Flutter applications. This module is designed to facilitate file upload, download, deletion, and other storage-related operations across various cloud storage providers.

## Features

- Upload files to cloud storage
- Download files from cloud storage
- Delete files from cloud storage
- Check file existence
- Get file URLs
- List files in a directory
- Get file sizes

## Installation

To use the `cloud_storage_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  cloud_storage_manager:
    path: ../packages/cloud_storage_manager
```

## Usage

Here's a basic example of how to use the `cloud_storage_manager` module:

```dart
import 'dart:io';
import 'package:cloud_storage_manager/cloud_storage_manager.dart';

// Initialize the cloud storage manager
final storageManager = CloudStorageManagerImpl(logManager: yourLogManager);

// Use it in your code
final file = File('path/to/local/file.txt');
final result = await storageManager.uploadFile(file, 'remote/path/file.txt');
if (result == StorageOperationResult.success) {
  print('File uploaded successfully');
}

// Get file URL
final url = await storageManager.getFileUrl('remote/path/file.txt');
print('File URL: $url');
```

For more detailed usage instructions and advanced features, please refer to the documentation.
