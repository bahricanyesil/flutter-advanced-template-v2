import 'package:flutter/foundation.dart';

import '../enums/log_levels.dart';
import 'base_log_message_model.dart';

/// A function type that defines the signature for a log formatter.
///
/// The [LogFormatter] function takes in a [BaseLogMessageModel]
/// and [BaseLogOptionsModel] as parameters and returns a [String].
/// It is used to format log messages according to the specified options.
typedef LogFormatter = String Function(
  BaseLogMessageModel message,
  BaseLogOptionsModel options,
);

/// Represents the base options for logging.
///
/// The [BaseLogOptionsModel] class provides a set of options that can be
/// used to configure logging behavior.
///
/// The options include:
/// - [level]: The log level to filter log messages.
/// - [showTime]: Whether to display the timestamp in log messages.
/// - [showEmoji]: Whether to display emojis in log messages.
/// - [logInRelease]: Whether to enable logging in release mode.
/// - [formatter]: The log formatter to customize the log message format.
@immutable
final class BaseLogOptionsModel {
  /// Constructor for the [BaseLogOptionsModel] class.
  const BaseLogOptionsModel({
    this.showTime = true,
    this.showEmoji = true,
    this.logInRelease = false,
    this.level = LogLevels.info,
    this.formatter,
  });

  /// The log level to filter log messages.
  final LogLevels level;

  /// Whether to display the timestamp in log messages.
  final bool showTime;

  /// Whether to display emojis in log messages.
  final bool showEmoji;

  /// Whether to enable logging in release mode.
  final bool logInRelease;

  /// The log formatter to customize the log message format.
  final LogFormatter? formatter;
}
