# LogManager

The `LogManager` module provides a centralized way to handle logging in your Flutter project. It supports different log levels (Info, Warning, Error) and can be extended for more complex logging needs.

## Features

- Log messages with different severity levels: `Info`, `Warning`, `Error`.
- Simple and consistent logging interface across your app.
- Easily extendable to include more sophisticated logging mechanisms (e.g., saving logs to a file, sending logs to a server).

## Installation

To include the `log_manager` in your Flutter project, add it as a dependency:

### Option 1: As a Git Dependency

Add the following to your `pubspec.yaml`:

  ```yaml
  dev_dependencies:
    log_manager:
      git:
        url: https://github.com/bahricanyesil/flutter-advanced-template-v2.git
        path: packages/log_manager
  ```

  or as a path dependency

  ```yaml
  dev_dependencies:
    log_manager:
      path: packages/log_manager
  ```
