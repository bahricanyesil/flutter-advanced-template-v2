import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:log_manager/src/models/base_log_message_model.dart';

/// A base class for managing logging functionality.
///
/// This abstract class provides methods for logging fatal errors, errors,
/// warnings, informational messages, debug messages, and trace messages.
/// It also includes methods for setting up the logger manager, retrieving logs,
/// and logging specific types of errors.
///
/// Implementations of this class should provide the necessary logic
/// for handling and storing log messages.
abstract class LogManager {
  /// Creates an instance of [LogManager].
  LogManager({
    this.wrapWidthProperties = 100,
    this.maxDescendentsTruncatableNode = 5,
  });

  /// The wrap width properties for the flutter error log messages.
  final int wrapWidthProperties;

  /// The max descendents truncatable node for the flutter error log messages.
  final int maxDescendentsTruncatableNode;

  /// Logs a trace message.
  void lTrace(Object message, {Object? error, StackTrace? stackTrace});

  /// Logs a debug message.
  void lDebug(Object message, {Object? error, StackTrace? stackTrace});

  /// Logs an informational message.
  void lInfo(Object message, {Object? error, StackTrace? stackTrace});

  /// Logs a warning message.
  void lWarning(Object message, {Object? error, StackTrace? stackTrace});

  /// Logs an error message.
  void lError(
    Object message, {
    Object? error,
    StackTrace? stackTrace,
  });

  /// Logs a fatal error message.
  void lFatal(Object message, {Object? error, StackTrace? stackTrace});

  /// Closes the logger manager.
  ///
  /// This method should be called when you are done using the
  /// logger manager to release any resources it may have acquired.
  /// It is important to call this method to ensure proper cleanup
  /// and prevent resource leaks.
  ///
  /// Example usage:
  /// ```dart
  /// LogManager logManager = LogManager();
  /// ...Use the logger manager...
  /// await logManager.close();
  /// ```
  Future<void> close();

  /// Returns a stream of [BaseLogMessageModel] objects representing the logs.
  ///
  /// The stream emits log messages whenever a new log is added
  /// to the logger manager.
  /// Subscribers can listen to this stream to receive
  /// log messages in real-time.
  Stream<BaseLogMessageModel> get logStream;

  String _renderFlutterError(FlutterErrorDetails details) {
    final TextTreeRenderer renderer = TextTreeRenderer(
      wrapWidthProperties: 100,
      maxDescendentsTruncatableNode: 5,
    );
    return renderer
        .render(details.toDiagnosticsNode(style: DiagnosticsTreeStyle.error))
        .trimRight();
  }

  /// Logs a Flutter error.
  ///
  /// This method logs the given [details] of a Flutter error.
  /// If the error is marked as silent,
  /// it will not be logged. The error description, exception,
  /// and stack trace are included in the log.
  ///
  /// Example usage:
  /// ```dart
  /// logFlutterError(FlutterErrorDetails details);
  /// ```
  @mustCallSuper
  Future<void> logFlutterError(FlutterErrorDetails details) async {
    if (details.silent) return;
    final String description = _renderFlutterError(details);
    final String message = 'Flutter Error: $description';
    lFatal(
      message,
      error: details.exception,
      stackTrace: details.stack,
    );
  }

  /// Logs a platform dispatcher error.
  ///
  /// This method logs the given [error] along with the provided [stackTrace].
  /// It returns `true` to indicate that the error has been logged.
  @mustCallSuper
  bool logPlatformDispatcherError(Object error, StackTrace stackTrace) {
    final String message = 'Platform Dispatcher Error: $error';
    lError(message, error: error, stackTrace: stackTrace);
    return true;
  }

  /// Sets flutter and platform dispatcher error handlers.
  void setFlutterErrorHandlers({required PlatformDispatcher dispatcher});

  /// Controls whether logging is enabled or disabled.
  bool loggingEnabled = true;

  /// Disables logging for the logger manager.
  @mustCallSuper
  void disableLogging() {
    loggingEnabled = false;
  }

  /// Enables logging for the logger manager.
  @mustCallSuper
  void enableLogging() {
    loggingEnabled = true;
  }
}
