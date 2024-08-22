import 'package:log_manager/src/constants/log_levels.dart';
import 'package:logger/logger.dart';

import '../models/base_log_message_model.dart';

/// Extension method to convert a [LogEvent] into a [BaseLogMessage].
extension LogEventExtensions on LogEvent {
  /// Converts the [LogEvent] into a [BaseLogMessage].
  ///
  /// The [LogLevel] is extracted from the [level] property of the [LogEvent].
  /// The [message], [error], [stackTrace], and [time] properties
  /// are used to create the [BaseLogMessage].
  BaseLogMessage get logMessage => BaseLogMessage(
        logLevel: level.logLevel,
        message: message,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
}

/// Extension on [Level] enum to convert it to [LogLevel].
extension LogLevelExtensions on Level {
  /// Converts the [Level] into a [LogLevel].
  LogLevel get logLevel => switch (this) {
        Level.fatal => LogLevel.fatal,
        Level.error => LogLevel.error,
        Level.warning => LogLevel.warning,
        Level.info => LogLevel.info,
        Level.debug => LogLevel.debug,
        Level.all => LogLevel.all,
        Level.off => LogLevel.off,
        _ => LogLevel.trace,
      };
}
