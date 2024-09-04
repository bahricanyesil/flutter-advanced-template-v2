# Connectivity Manager

The `connectivity_manager` module provides a unified interface for managing network connectivity in Flutter applications. This module is designed to facilitate the monitoring of network status and handle offline scenarios.

## Features

- Monitor network connectivity status.
- Handle connectivity changes.

## Installation

To use the `connectivity_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  connectivity_manager:
    path: ../packages/connectivity_manager
```

## Usage

Here's a basic example of how to use the `connectivity_manager` module:

```dart
import 'package:connectivity_manager/connectivity_manager.dart';

// Initialize the connectivity manager
final connectivityManager = FirebaseConnectivityManager.create();

// Use it in your code
final isConnected = await connectivityManager.isConnected();
```
