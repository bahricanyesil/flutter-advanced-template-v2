import 'package:exception_report_manager/exception_report_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

class CustomExceptionReportManager extends ExceptionReportManager {
  CustomExceptionReportManager(super.logManager);
  final List<BaseLogMessage> reportCalls = <BaseLogMessage>[];
  final List<BaseLogMessage> reportFatalCalls = <BaseLogMessage>[];
  bool reportCalled = false;
  bool reportFatalCalled = false;

  @override
  Future<bool> report(
    BaseLogMessage log, {
    bool fatal = false,
    Map<String, dynamic>? additionalContext,
  }) async {
    reportCalled =
        await super.report(log, additionalContext: additionalContext);
    if (reportCalled) reportCalls.add(log);
    return reportCalled;
  }

  @override
  Future<bool> reportFatal(
    FlutterErrorDetails errorDetails, {
    Map<String, dynamic>? additionalContext,
  }) async {
    final BaseLogMessage log = BaseLogMessage(
      logLevel: LogLevel.error,
      message: errorDetails.exceptionAsString(),
      error: errorDetails.exception,
      stackTrace: errorDetails.stack,
    );
    reportFatalCalled = await super
        .reportFatal(errorDetails, additionalContext: additionalContext);
    if (reportFatalCalled) reportFatalCalls.add(log);
    return reportFatalCalled;
  }
}
