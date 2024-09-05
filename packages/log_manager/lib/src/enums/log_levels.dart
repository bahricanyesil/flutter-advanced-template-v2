import 'package:logger/logger.dart';

/// The [LogLevels] enum is used to specify the level of logging that should
enum LogLevels implements Comparable<LogLevels> {
  /// The [all] level is used to log all messages.
  /// Color: Black
  all._(1000, '🔄', AnsiColor.fg(0)),

  /// Represents the log level for tracing.
  ///
  /// The trace log level is used for detailed debugging information.
  /// It has a numeric value of 600.
  /// Color: Blue
  trace._(600, '🔍', AnsiColor.fg(4)),

  /// Represents a debug log level with a value of 500.
  ///
  /// This log level is used for debugging purposes and provides detailed
  /// information that can help identify and fix issues in the code.
  /// Color: Grey
  debug._(500, '🐛', AnsiColor.fg(244)),

  /// Represents the log level for informational messages.
  /// The log level value is 400.
  /// Color: Green
  info._(400, 'ℹ️', AnsiColor.fg(2)),

  /// Represents the log level for warning messages.
  /// Color: Orange
  warning._(300, '⚠️', AnsiColor.fg(3)),

  /// Represents the log level for an error.
  /// The value 200 is used to indicate the severity of the error.
  /// Color: Red
  error._(200, '❌', AnsiColor.fg(1)),

  /// Represents the log level "fatal" with a value of 100. This log level
  /// indicates a critical error that causes the application to terminate.
  /// Color: Purple
  fatal._(100, '💣', AnsiColor.fg(5)),

  /// Represents the log level "off" with a value of 0.
  /// This log level is used to turn off logging.
  /// Color: Transparent
  off._(0, '🚫', AnsiColor.none());

  const LogLevels._(this.value, this.emoji, this.color);

  /// Value of the level
  final int value;

  /// Emoji representation
  final String emoji;

  /// Color representation
  final AnsiColor color;

  @override
  int compareTo(LogLevels other) => value.compareTo(other.value);

  @override
  String toString() => '$LogLevels($value, $emoji, $color)';
}
