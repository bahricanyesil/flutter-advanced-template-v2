import 'package:log_manager/log_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Extension methods for [LogLevel] to convert to [SentryLevel].
extension LogLevelExtensions on LogLevel {
  /// Converts [LogLevel] to [SentryLevel].
  SentryLevel get sentryLevel {
    switch (this) {
      case LogLevel.debug:
        return SentryLevel.debug;
      case LogLevel.info:
        return SentryLevel.info;
      case LogLevel.warning:
        return SentryLevel.warning;
      case LogLevel.error:
        return SentryLevel.error;
      case LogLevel.fatal:
        return SentryLevel.fatal;
      default:
        return SentryLevel.info;
    }
  }
}
