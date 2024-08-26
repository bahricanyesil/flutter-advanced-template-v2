import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

/// Represents an interface for managing exception reports.
abstract base class ExceptionReportManager {
  /// Creates an instance of [ExceptionReportManager].
  ExceptionReportManager(this.logManager);

  /// The logger manager instance.
  final LogManager logManager;

  StreamSubscription<BaseLogMessage>? _subscription;

  /// Custom error filter function
  bool Function(Object? error)? errorFilter;

  /// Rate limiting: max reports per minute
  int maxReportsPerMinute = 10;
  int _reportCount = 0;
  DateTime? _lastReportTime;

  /// Enables reporting of exception logs.
  /// It listens to the log stream from the [LogManager] and reports any
  /// warning or error logs that meet the criteria specified in [shouldReport].
  @mustCallSuper
  Future<void> enableReporting() async {
    await disableReporting();
    _subscription ??= logManager.logStream
        .where(_isWarningOrError)
        .listen((BaseLogMessage log) async {
      if (shouldReport(log.error) && !_isRateLimited()) {
        await report(log);
      }
    });
  }

  /// Disables reporting of exception logs.
  /// It cancels the subscription to the log stream.
  @mustCallSuper
  Future<void> disableReporting() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Reports the given [log] as an exception.
  @mustCallSuper
  Future<void> report(
    BaseLogMessage log, {
    bool fatal = false,
    Map<String, dynamic>? additionalContext,
  }) async {
    if (_isRateLimited()) {
      logManager.lWarning('Rate limit exceeded. Skipping report.');
      return;
    }
    logManager.lInfo(
      '''Reporting log to the exception manager: ${log.error}''',
    );

    // Prepare report data
    final Map<String, dynamic> reportData = <String, dynamic>{
      'error': log.error.toString(),
      'stackTrace': log.stackTrace?.toString(),
      'logLevel': log.logLevel.toString(),
      'message': log.message,
      'fatal': fatal,
      ...?additionalContext,
    };

    // Implement actual reporting logic here
    // This could involve sending the data to a remote server or storing it
    // locally. For demonstration, we'll just log it
    logManager.lInfo('Exception report: $reportData');

    _updateReportCount();
  }

  /// Reports the given [errorDetails] as a fatal exception.
  @mustCallSuper
  Future<void> reportFatal(FlutterErrorDetails errorDetails) async {
    final BaseLogMessage log = BaseLogMessage(
      logLevel: LogLevel.error,
      message: errorDetails.exceptionAsString(),
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
    );

    await report(
      log,
      fatal: true,
      additionalContext: <String, dynamic>{
        'context': errorDetails.context?.toString(),
        'library': errorDetails.library,
      },
    );
  }

  bool _isWarningOrError(BaseLogMessage log) =>
      log.logLevel.compareTo(LogLevel.warning) <= 0;

  /// Returns whether the error should be reported.
  bool shouldReport(Object? error) =>
      enabledReporting &&
      error != null &&
      (errorFilter == null || errorFilter!(error));

  /// Returns whether reporting is enabled.
  bool get enabledReporting => _subscription != null;

  bool _isRateLimited() {
    final DateTime now = DateTime.now();
    if (_lastReportTime == null ||
        now.difference(_lastReportTime!) > const Duration(minutes: 1)) {
      _reportCount = 0;
      _lastReportTime = now;
    }
    return _reportCount >= maxReportsPerMinute;
  }

  void _updateReportCount() {
    _reportCount++;
    _lastReportTime = DateTime.now();
  }
}
