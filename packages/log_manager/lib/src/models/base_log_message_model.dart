import 'package:flutter/foundation.dart';

import '../constants/log_levels.dart';

/// Represents a base log message.
///
/// This class is used as a base for all log message models.
/// It contains properties for the log message, log level, error,
/// stack trace, and time.
@immutable
class BaseLogMessage {
  /// Constructor for the [BaseLogMessage] class.
  const BaseLogMessage({
    required this.message,
    required this.logLevel,
    this.error,
    this.stackTrace,
    this.time,
  });

  /// The log message.
  final dynamic message;

  /// The error associated with the log message.
  final Object? error;

  /// The stack trace associated with the log message.
  final StackTrace? stackTrace;

  /// The time when the log message was created.
  final DateTime? time;

  /// The log level of the message.
  final LogLevel logLevel;
}

/// Extension methods for [BaseLogMessage]
///
/// This extension provides methods for filtering log messages.
///
/// It provides a method to check if the log message is a warning or error.
extension BaseLogMessageX on BaseLogMessage {
  /// Returns whether the log message is a warning or error.
  bool get isWarningOrError => logLevel.compareTo(LogLevel.warning) <= 0;
}
