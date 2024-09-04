import 'package:log_manager/log_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Extension methods for [LogLevels] to convert to [SentryLevel].
extension LogLevelExtensions on LogLevels {
  /// Converts [LogLevels] to [SentryLevel].
  SentryLevel get sentryLevel {
    switch (this) {
      case LogLevels.debug:
        return SentryLevel.debug;
      case LogLevels.info:
        return SentryLevel.info;
      case LogLevels.warning:
        return SentryLevel.warning;
      case LogLevels.error:
        return SentryLevel.error;
      case LogLevels.fatal:
        return SentryLevel.fatal;
      default:
        return SentryLevel.info;
    }
  }
}
