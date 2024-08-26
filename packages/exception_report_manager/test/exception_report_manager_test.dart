import 'package:exception_report_manager/exception_report_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockLogManager extends Mock implements LogManager {}

final class TestExceptionReportManager extends ExceptionReportManager {
  TestExceptionReportManager(super.logManager);

  @override
  Future<void> enableReporting() async {
    // Ensure the logStream is initialized
    when(() => logManager.logStream)
        .thenAnswer((_) => const Stream<BaseLogMessage>.empty());
    await super.enableReporting();
  }
}

void main() {
  late MockLogManager mockLogManager;
  late TestExceptionReportManager exceptionReportManager;

  setUp(() {
    mockLogManager = MockLogManager();
    exceptionReportManager = TestExceptionReportManager(mockLogManager);
  });

  group('ExceptionReportManager', () {
    test('enableReporting starts listening to log stream', () async {
      when(() => mockLogManager.logStream)
          .thenAnswer((_) => const Stream<BaseLogMessage>.empty());

      await exceptionReportManager.enableReporting();

      expect(exceptionReportManager.enabledReporting, isTrue);
      verify(() => mockLogManager.logStream).called(1);
    });

    test('disableReporting stops listening to log stream', () async {
      when(() => mockLogManager.logStream)
          .thenAnswer((_) => const Stream<BaseLogMessage>.empty());

      await exceptionReportManager.enableReporting();
      await exceptionReportManager.disableReporting();

      expect(exceptionReportManager.enabledReporting, isFalse);
    });

    test('report logs the exception', () async {
      final BaseLogMessage testLog = BaseLogMessage(
        logLevel: LogLevel.error,
        message: 'Test error',
        error: Exception('Test'),
      );

      await exceptionReportManager.report(testLog);

      verify(() => mockLogManager.lInfo(any())).called(2);
    });

    test('reportFatal logs a fatal exception', () async {
      final FlutterErrorDetails errorDetails = FlutterErrorDetails(
        exception: Exception('Fatal error'),
        stack: StackTrace.current,
        library: 'test_library',
      );

      await exceptionReportManager.reportFatal(errorDetails);

      verify(() => mockLogManager.lInfo(any())).called(2);
    });

    test('shouldReport returns correct value', () async {
      expect(exceptionReportManager.shouldReport(null), isFalse);
      expect(exceptionReportManager.shouldReport(Exception('Test')), isFalse);

      when(() => mockLogManager.logStream)
          .thenAnswer((_) => const Stream<BaseLogMessage>.empty());

      await exceptionReportManager.enableReporting();
      expect(exceptionReportManager.shouldReport(Exception('Test')), isTrue);

      exceptionReportManager.errorFilter =
          (Object? error) => error.toString().contains('specific');
      expect(exceptionReportManager.shouldReport(Exception('Test')), isFalse);
      expect(
        exceptionReportManager.shouldReport(Exception('Test specific')),
        isTrue,
      );
    });

    test('rate limiting works correctly', () async {
      when(() => mockLogManager.logStream).thenAnswer(
        (_) => Stream<BaseLogMessage>.fromIterable(<BaseLogMessage>[
          BaseLogMessage(
            logLevel: LogLevel.error,
            message: 'Error',
            error: Exception('Test'),
          ),
        ]),
      );

      exceptionReportManager.maxReportsPerMinute = 2;
      await exceptionReportManager.enableReporting();

      // First two reports should go through
      await exceptionReportManager.report(
        BaseLogMessage(
          logLevel: LogLevel.error,
          message: 'Error 1',
          error: Exception('Test 1'),
        ),
      );
      await exceptionReportManager.report(
        BaseLogMessage(
          logLevel: LogLevel.error,
          message: 'Error 2',
          error: Exception('Test 2'),
        ),
      );

      // Third report should be rate limited
      await exceptionReportManager.report(
        BaseLogMessage(
          logLevel: LogLevel.error,
          message: 'Error 3',
          error: Exception('Test 3'),
        ),
      );

      verify(() => mockLogManager.lInfo(any()))
          .called(4); // 2 for each successful report
    });
  });
}
