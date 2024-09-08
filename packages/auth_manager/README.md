# Auth Manager

The `auth_manager` module provides a unified interface for managing authentication in Flutter applications. This module is designed to facilitate user authentication operations such as sign-in, sign-up, and sign-out.

## Features

- Sign in with email and password
- Sign up new users
- Sign out users
- Get current user authentication status

## Installation

To use the `auth_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  auth_manager:
    path: ../packages/auth_manager
```

## Usage

Here's a basic example of how to use the `auth_manager` module:

```dart
import 'package:auth_manager/auth_manager.dart';

// Initialize the auth manager
final authManager = AuthManagerImpl(logManager: yourLogManager);

// Use it in your code
final authStatus = await authManager.signIn(email: 'user@example.com', password: 'password');
if (authStatus == AuthStatus.authenticated) {
  print('User signed in successfully');
}
```

For more detailed usage instructions and advanced features, please refer to the documentation.
