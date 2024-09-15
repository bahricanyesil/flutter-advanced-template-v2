import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A log output implementation that outputs log events to the
/// developer console.
///
/// This implementation extends the [LogOutput] class and overrides
/// the [output] method to output the log event lines to the developer console.
@immutable
final class DevConsoleOutput extends LogOutput {
  /// Constructor with an optional logger parameter
  DevConsoleOutput({ConsoleLogger? logger})
      : _logger = logger ?? DefaultConsoleLogger();
  final ConsoleLogger _logger;

  @override
  void output(OutputEvent event) {
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < event.lines.length; i++) {
      buffer.write(event.lines[i]);
      // Add newline if not the last item
      if (i < event.lines.length - 1) {
        buffer.write('\n');
      }
    }

    _logger.logMessage(buffer.toString());
  }
}

/// A custom console logger interface.
// ignore: one_member_abstracts
abstract interface class ConsoleLogger {
  /// Logs the provided message.
  void logMessage(String message);
}

/// A custom console logger implementation that logs messages
/// to the developer console.
final class DefaultConsoleLogger extends ConsoleLogger {
  @override
  void logMessage(String message) {
    dev.log(message);
  }
}
