import 'package:flutter/foundation.dart';

/// The [LoggerBuildMode] class is used to determine the build mode.
/// It is used to determine whether the app is running in release mode.
abstract class LoggerBuildMode {
  /// Returns true if the app is running in release mode.
  bool get isReleaseMode;
}

/// The [LoggerBuildModeImpl] class is used to
/// implement the [LoggerBuildMode] class.
class LoggerBuildModeImpl implements LoggerBuildMode {
  @override
  bool get isReleaseMode => kReleaseMode;
}
