# Exception Report Manager

The `exception_report_manager` module provides a unified interface for managing exception reporting in Flutter applications. This module is designed to facilitate the capture, logging, and reporting of exceptions to improve debugging and user support.

## Features

- Capture and log exceptions
- Report exceptions to various services (e.g., Crashlytics, Sentry)
- Customizable exception handling

## Installation

To use the `exception_report_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  exception_report_manager:
    path: ../packages/exception_report_manager
```

## Usage

Here's a basic example of how to use the `exception_report_manager` module:

```dart
import 'package:exception_report_manager/exception_report_manager.dart';

// Initialize the exception report manager
final exceptionReportManager = ExceptionReportManager();

// Use it in your code
try {
  // Your code that might throw an exception
} catch (e, stackTrace) {
  exceptionReportManager.reportException(e, stackTrace);
}
```

For more detailed usage instructions and advanced features, please refer to the documentation.
