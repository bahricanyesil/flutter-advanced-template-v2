import 'package:exception_report_manager/src/utils/log_level_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'exception_report_manager.dart';

/// A [ExceptionReportManager] that uses Sentry for exception reporting.
///
/// This class is a base class for all Sentry exception reporting
/// implementations.
///
/// It provides a default implementation for the [report] and [reportFatal]
/// methods that use Sentry for exception reporting.
base class SentryExceptionReportManager extends ExceptionReportManager {
  /// Creates a new [SentryExceptionReportManager].
  SentryExceptionReportManager({
    required LogManager logManager,
    required this.sentryDSN,
    required this.sentryEnvironment,
    this.sampleRate = 0.2,
  }) : super(logManager);

  /// The Sentry DSN.
  final String sentryDSN;

  /// The Sentry environment.
  final String sentryEnvironment;

  /// The sample rate for Sentry.
  final double sampleRate;

  @override
  Future<bool> enableReporting({bool initSentry = true}) async {
    if (sentryDSN.isEmpty || enabledReporting) return true;
    try {
      if (initSentry) {
        await SentryFlutter.init((SentryFlutterOptions options) {
          options
            ..dsn = sentryDSN
            ..tracesSampleRate = sampleRate
            ..debug = kDebugMode
            ..environment = sentryEnvironment;
        });
      }
      await super.enableReporting();
      logManager.lInfo('Sentry reporting enabled with DSN: $sentryDSN');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> disableReporting() async {
    if (!enabledReporting) return true;
    try {
      await Sentry.close();
      await super.disableReporting();
      logManager.lInfo('Sentry reporting disabled');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> report(
    BaseLogMessage log, {
    Map<String, dynamic>? additionalContext,
  }) async {
    if (!enabledReporting) return false;

    final Object? error = log.error;
    final StackTrace? stackTrace = log.stackTrace;

    Future<void> withScope(Scope scope) async {
      // Add additional context to the scope
      if (additionalContext != null) {
        for (final MapEntry<String, dynamic> entry
            in additionalContext.entries) {
          await scope.setContexts(entry.key, entry.value);
        }
      }

      final SentryLevel sentryLevel = log.logLevel.sentryLevel;
      scope.level = sentryLevel;

      // Add log message as a breadcrumb
      await scope.addBreadcrumb(
        Breadcrumb(
          message: log.message.toString(),
          timestamp: log.time,
          level: sentryLevel,
        ),
      );
    }

    try {
      if (error == null && stackTrace == null) {
        await Sentry.captureMessage(
          log.message.toString(),
          level: log.logLevel.sentryLevel,
          withScope: withScope,
        );
      } else {
        await Sentry.captureException(
          error ?? log.message,
          stackTrace: stackTrace,
          withScope: withScope,
        );
      }

      // Call the superclass method to ensure
      // any additional logging is performed
      return super.report(log, additionalContext: additionalContext);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> reportFatal(
    FlutterErrorDetails errorDetails, {
    Map<String, dynamic>? additionalContext,
  }) async {
    if (!enabledReporting) return false;

    try {
      await Sentry.captureException(
        errorDetails.exception,
        stackTrace: errorDetails.stack,
        withScope: (Scope scope) async {
          scope.level = SentryLevel.fatal;

          // Add error message as a breadcrumb
          await scope.addBreadcrumb(
            Breadcrumb(
              message: errorDetails.exceptionAsString(),
              level: SentryLevel.fatal,
              timestamp: DateTime.now(),
            ),
          );

          // Add context information
          await scope.setContexts('Flutter Error', <String, Object?>{
            'library': errorDetails.library,
            'context': errorDetails.context,
            'silent': errorDetails.silent,
          });

          // Add any available Flutter specific information
          if (errorDetails.informationCollector != null) {
            final Iterable<DiagnosticsNode> information =
                errorDetails.informationCollector!();
            await scope.setContexts('Additional Information', <String, String>{
              'details': information.join('\n'),
            });
          }
        },
      );

      // Call the superclass method to ensure
      // any additional logging is performed
      return super
          .reportFatal(errorDetails, additionalContext: additionalContext);
    } catch (e) {
      return false;
    }
  }
}
