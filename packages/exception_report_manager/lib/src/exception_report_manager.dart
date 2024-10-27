import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

/// Represents an interface for managing exception reports.
abstract class ExceptionReportManager {
  /// Creates an instance of [ExceptionReportManager].
  ExceptionReportManager(this.logManager, {this.maxReportsPerMinute = 10});

  /// The logger manager instance.
  final LogManager? logManager;

  StreamSubscription<BaseLogMessageModel>? _subscription;

  /// Custom error filter function
  bool Function(Object? error)? errorFilter;

  /// Rate limiting: max reports per minute
  int maxReportsPerMinute;
  int _reportCount = 0;
  DateTime? _lastReportTime;

  /// Enables reporting of exception logs.
  /// It listens to the log stream from the [LogManager] and reports any
  /// warning or error logs that meet the criteria specified in [shouldReport].
  @mustCallSuper
  Future<void> enableReporting() async {
    _subscription ??= logManager?.logStream
        .where((BaseLogMessageModel log) => log.isWarningOrError)
        .listen(_listenLogMessage);
  }

  Future<void> _listenLogMessage(BaseLogMessageModel log) async {
    if (shouldReport(log.error)) {
      await report(log);
    }
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
  Future<bool> report(
    BaseLogMessageModel log, {
    Map<String, dynamic>? additionalContext,
  }) async {
    return _processReport(log, additionalContext: additionalContext);
  }

  /// Reports the given [errorDetails] as a fatal exception.
  @mustCallSuper
  Future<bool> reportFatal(
    FlutterErrorDetails errorDetails, {
    Map<String, dynamic>? additionalContext,
  }) async {
    final BaseLogMessageModel log = BaseLogMessageModel(
      logLevel: LogLevels.error,
      message: errorDetails.exceptionAsString(),
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
    );
    return _processReport(
      log,
      additionalContext: additionalContext,
      isFatal: true,
    );
  }

  Future<bool> _processReport(
    BaseLogMessageModel log, {
    Map<String, dynamic>? additionalContext,
    bool isFatal = false,
  }) async {
    if (_isRateLimited()) {
      logManager?.lWarning('Rate limit exceeded. Skipping report.');
      return false;
    }

    final String reportType = isFatal ? 'fatal error' : 'log';
    logManager
        ?.lInfo('Reporting $reportType to the exception manager: ${log.error}');

    final Map<String, dynamic> reportData =
        _prepareReportData(log, additionalContext, isFatal);

    logManager?.lInfo('Exception report: $reportData');

    _updateReportCount();
    return true;
  }

  Map<String, dynamic> _prepareReportData(
    BaseLogMessageModel log,
    Map<String, dynamic>? additionalContext,
    bool isFatal,
  ) {
    return <String, dynamic>{
      'error': log.error.toString(),
      'stackTrace': log.stackTrace?.toString(),
      'logLevel': log.logLevel.toString(),
      'message': log.message,
      if (isFatal) 'isFatal': true,
      ...?additionalContext,
    };
  }

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
