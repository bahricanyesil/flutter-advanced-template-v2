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
  DevConsoleOutput(this._logger);
  final CustomConsoleLogger _logger;

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

    _logger.log(buffer.toString());
  }
}

/// A custom console logger interface.
// ignore: one_member_abstracts
abstract interface class CustomConsoleLogger {
  /// Logs the provided message.
  void log(String message);
}
