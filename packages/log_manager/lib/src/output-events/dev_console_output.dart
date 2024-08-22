import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A log output implementation that outputs log events to the
/// developer console.
///
/// This implementation extends the [LogOutput] class and overrides
/// the [output] method to output the log event lines to the developer console.
@immutable
final class DevConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    final StringBuffer buffer = StringBuffer();
    event.lines.forEach(buffer.writeln);
    log(buffer.toString());
  }
}
