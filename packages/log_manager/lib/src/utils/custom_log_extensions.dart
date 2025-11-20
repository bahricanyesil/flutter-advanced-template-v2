import 'package:log_manager/src/enums/log_levels.dart';
import 'package:log_manager/src/models/base_log_message_model.dart';
import 'package:logger/logger.dart';

/// Extension method to convert a [LogEvent] into a [BaseLogMessageModel].
extension CustomLogExtensions on LogEvent {
  /// Converts the [LogEvent] into a [BaseLogMessageModel].
  ///
  /// The [LogLevels] is extracted from the [level] property of the [LogEvent].
  /// The [message], [error], [stackTrace], and [time] properties
  /// are used to create the [BaseLogMessageModel].
  BaseLogMessageModel get logMessage => BaseLogMessageModel(
        logLevel: level.logLevel,
        message: message,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
}

/// Extension on [Level] enum to convert it to [LogLevels].
extension LogLevelExtensions on Level {
  /// Converts the [Level] into a [LogLevels].
  LogLevels get logLevel => switch (this) {
        Level.fatal => LogLevels.fatal,
        Level.error => LogLevels.error,
        Level.warning => LogLevels.warning,
        Level.info => LogLevels.info,
        Level.debug => LogLevels.debug,
        Level.all => LogLevels.all,
        Level.off => LogLevels.off,
        _ => LogLevels.trace,
      };
}
