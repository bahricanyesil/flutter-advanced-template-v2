import 'package:exception_report_manager/exception_report_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockCustomExceptionReportManager extends ExceptionReportManager
    with Mock {
  MockCustomExceptionReportManager(super.logManager);
  final List<BaseLogMessageModel> reportCalls = <BaseLogMessageModel>[];
  final List<BaseLogMessageModel> reportFatalCalls = <BaseLogMessageModel>[];
  bool reportCalled = false;
  bool reportFatalCalled = false;

  @override
  Future<bool> report(
    BaseLogMessageModel log, {
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
    final BaseLogMessageModel log = BaseLogMessageModel(
      logLevel: LogLevels.error,
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
