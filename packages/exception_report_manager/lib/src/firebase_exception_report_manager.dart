import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

import 'exception_report_manager.dart';

/// A [ExceptionReportManager] that uses Firebase Crashlytics for exception
/// reporting.
///
/// This class is a base class for all Firebase Crashlytics exception reporting
/// implementations.
///
/// It provides a default implementation for the [report] and [reportFatal]
/// methods that use Firebase Crashlytics for exception reporting.
base class FirebaseCrashlyticsReportManager extends ExceptionReportManager {
  /// Creates a new [FirebaseCrashlyticsReportManager].
  ///
  /// The [crashlytics] parameter is optional and defaults to the global
  /// Firebase Crashlytics instance.
  FirebaseCrashlyticsReportManager({
    required LogManager logManager,
    required FirebaseCrashlytics crashlytics,
  })  : _crashlytics = crashlytics,
        super(logManager);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> enableReporting() async {
    await super.enableReporting();
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  @override
  Future<void> disableReporting() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(false);
    await super.disableReporting();
  }

  @override
  Future<bool> report(
    BaseLogMessage log, {
    bool fatal = false,
    Map<String, dynamic>? additionalContext,
  }) async {
    if (enabledReporting) {
      await _crashlytics.recordError(
        log.error,
        log.stackTrace,
        reason: log.message,
        fatal: fatal,
        information: <String>[
          'logLevel: ${log.logLevel}',
          ...?additionalContext?.entries
              .map((MapEntry<String, dynamic> e) => '${e.key}: ${e.value}'),
        ],
      );
      return super.report(log, additionalContext: additionalContext);
    }
    return false;
  }

  @override
  Future<bool> reportFatal(
    FlutterErrorDetails errorDetails, {
    Map<String, dynamic>? additionalContext,
  }) async {
    if (enabledReporting) {
      await _crashlytics.recordFlutterFatalError(errorDetails);
      return super
          .reportFatal(errorDetails, additionalContext: additionalContext);
    }
    return false;
  }

  @override
  bool get enabledReporting =>
      _crashlytics.isCrashlyticsCollectionEnabled && super.enabledReporting;
}
