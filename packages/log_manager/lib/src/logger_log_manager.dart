import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_manager/log_manager.dart';
import 'package:log_manager/src/utils/string_extensions.dart';
import 'package:logger/logger.dart';

/// The [LogManager] class is used to manage logger.
///
/// This class is used to manage logger. It is a wrapper around the
/// [Logger] class from the `logger` package.
/// It implements the [LogManager] abstract class.
/// It is used to log messages to the console.
/// It also provides a stream of log messages.
@visibleForTesting
final class LoggerLogManager extends LogManager {
  /// Constructor for the [LogManager] class.
  LoggerLogManager({required Logger logger}) {
    _logger = logger;
    _streamOutput = CustomStreamOutput();
    enableLogging();
  }

  late final Logger _logger;
  late final CustomStreamOutput _streamOutput;

  static final List<String> _ignoredFlutterErrors = <String>[
    '''A KeyDownEvent is dispatched, but the state shows that the physical key is already pressed.''',
  ];

  void _logWrapper(
    void Function(
      Object message, {
      DateTime? time,
      Object? error,
      StackTrace? stackTrace,
    }) logMethod,
    Object message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (loggingEnabled) {
      logMethod(message, error: error, stackTrace: stackTrace);
    }
  }

  @override
  void lTrace(Object message, {Object? error, StackTrace? stackTrace}) =>
      _logWrapper(_logger.t, message, error: error, stackTrace: stackTrace);

  @override
  void lDebug(Object message, {Object? error, StackTrace? stackTrace}) =>
      _logWrapper(_logger.d, message, error: error, stackTrace: stackTrace);

  @override
  void lInfo(
    Object message, {
    Object? error,
    StackTrace? stackTrace,
    String? type,
  }) {
    _logWrapper(_logger.i, message, error: error, stackTrace: stackTrace);
  }

  @override
  void lWarning(Object message, {Object? error, StackTrace? stackTrace}) =>
      _logWrapper(_logger.w, message, error: error, stackTrace: stackTrace);

  @override
  void lError(
    Object message, {
    Object? error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    _logWrapper(_logger.e, message, error: error, stackTrace: stackTrace);
  }

  @override
  void lFatal(Object message, {Object? error, StackTrace? stackTrace}) {
    _logWrapper(_logger.f, message, error: error, stackTrace: stackTrace);
    if (error == null) return;
  }

  @override
  Stream<BaseLogMessage> get logStream => _streamOutput.stream;

  @override
  L setUp<L>(
    LoggerSetupCallback<L> fn, [
    BaseLogOptions options = const BaseLogOptions(),
  ]) {
    if (kReleaseMode && !options.logInRelease) {
      disableLogging();
      return fn(this);
    }
    enableLogging();
    return fn(this);
  }

  @override
  Future<void> close() async {
    await _streamOutput.destroy();
    await _logger.close();
  }

  /// Sets up the logger manager by assigning error handlers
  /// for Flutter errors and platform dispatcher errors.
  @override
  void setFlutterErrorHandlers() {
    final FlutterExceptionHandler? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      final String exceptionText = errorDetails.exceptionAsString();
      if (_ignoredFlutterErrors.any(exceptionText.containsIgnoreCase)) return;
      await logFlutterError(errorDetails);
      originalOnError?.call(errorDetails);
    };
    final ErrorCallback? originalOnErrorWithDetails =
        WidgetsBinding.instance.platformDispatcher.onError;
    WidgetsBinding.instance.platformDispatcher.onError =
        (Object error, StackTrace stackTrace) {
      if (_ignoredFlutterErrors.any(error.toString().containsIgnoreCase)) {
        return true;
      }
      final bool val = logPlatformDispatcherError(error, stackTrace);
      originalOnErrorWithDetails?.call(error, stackTrace);
      return val;
    };
  }

  @override
  void enableLogging() {
    super.enableLogging();
    Logger.addOutputListener(_outputListener);
  }

  @override
  void disableLogging() {
    Logger.removeOutputListener(_outputListener);
    super.disableLogging();
  }

  void _outputListener(OutputEvent e) =>
      _streamOutput.output(e.origin.logMessage);
}
