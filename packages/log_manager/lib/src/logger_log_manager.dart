import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';
import 'package:log_manager/src/utils/string_log_extensions.dart';

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
  LoggerLogManager({
    required Logger logger,
    CustomStreamOutput? streamOutput,
    LoggerOutputWrapper? outputWrapper,
    LoggerBuildMode? buildMode,
    bool setErrorHandlers = true,
    BaseLogOptionsModel options = const BaseLogOptionsModel(),
    super.wrapWidthProperties,
    super.maxDescendentsTruncatableNode,
  }) {
    _loggerOutputWrapper = outputWrapper ?? LoggerOutputWrapperImpl();
    _logger = logger;
    _buildMode = buildMode ?? LoggerBuildModeImpl();
    _streamOutput = streamOutput ?? CustomStreamOutput();
    enableLogging();

    if (_buildMode.isReleaseMode && !options.logInRelease) {
      disableLogging();
    } else {
      enableLogging();
    }
    if (setErrorHandlers) {
      setFlutterErrorHandlers(dispatcher: PlatformDispatcher.instance);
    }
  }

  late final Logger _logger;
  late final LoggerOutputWrapper _loggerOutputWrapper;
  late final CustomStreamOutput _streamOutput;
  late final LoggerBuildMode _buildMode;

  /// [CustomStreamOutput] is used to manage the stream of log messages.
  CustomStreamOutput get streamOutput => _streamOutput;

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
  }) {
    _logWrapper(_logger.e, message, error: error, stackTrace: stackTrace);
  }

  @override
  void lFatal(Object message, {Object? error, StackTrace? stackTrace}) {
    _logWrapper(_logger.f, message, error: error, stackTrace: stackTrace);
    if (error == null) return;
  }

  @override
  Stream<BaseLogMessageModel> get logStream => _streamOutput.stream;

  @override
  Future<void> close() async {
    await _streamOutput.destroy();
    await _logger.close();
  }

  /// Sets up the logger manager by assigning error handlers
  /// for Flutter errors and platform dispatcher errors.
  @override
  void setFlutterErrorHandlers({required PlatformDispatcher dispatcher}) {
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      final String exceptionText = errorDetails.exceptionAsString();
      if (_ignoredFlutterErrors.any(exceptionText.containsIgnoreCase)) return;
      await logFlutterError(errorDetails);
    };
    dispatcher.onError = (Object error, StackTrace stackTrace) {
      if (_ignoredFlutterErrors.any(error.toString().containsIgnoreCase)) {
        return true;
      }
      final bool val = logPlatformDispatcherError(error, stackTrace);
      return val;
    };
  }

  @override
  void enableLogging() {
    super.enableLogging();
    _loggerOutputWrapper.addOutputListener(_outputListener);
  }

  @override
  void disableLogging() {
    _loggerOutputWrapper.removeOutputListener(_outputListener);
    super.disableLogging();
  }

  void _outputListener(OutputEvent e) {
    _streamOutput.output(e.origin.logMessage);
  }
}
