import 'package:flutter/foundation.dart';

import 'package:log_manager/src/enums/log_levels.dart';

/// Represents a base log message.
///
/// This class is used as a base for all log message models.
/// It contains properties for the log message, log level, error,
/// stack trace, and time.
@immutable
class BaseLogMessageModel {
  /// Constructor for the [BaseLogMessageModel] class.
  const BaseLogMessageModel({
    required this.message,
    required this.logLevel,
    this.error,
    this.stackTrace,
    this.time,
  });

  /// The log message.
  final Object? message;

  /// The error associated with the log message.
  final Object? error;

  /// The stack trace associated with the log message.
  final StackTrace? stackTrace;

  /// The time when the log message was created.
  final DateTime? time;

  /// The log level of the message.
  final LogLevels logLevel;
}

/// Extension methods for [BaseLogMessageModel]
///
/// This extension provides methods for filtering log messages.
///
/// It provides a method to check if the log message is a warning or error.
extension BaseLogMessageModelX on BaseLogMessageModel {
  /// Returns whether the log message is a warning or error.
  bool get isWarningOrError => logLevel.compareTo(LogLevels.warning) <= 0;
}
