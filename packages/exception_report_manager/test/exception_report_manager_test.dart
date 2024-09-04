import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';

import 'custom_exception_report_manager.dart';
import 'fakes/fake_base_log_message.dart';
import 'fakes/fake_flutter_error_details.dart';
import 'mocks/mock_exception_report_manager.dart';
import 'mocks/mock_log_manager.dart';

void main() {
  late MockExceptionReportManager mockExceptionReportManager;
  late MockLogManager mockLogManager;
  late CustomExceptionReportManager testManager;
  late StreamController<BaseLogMessage> logStreamController;

  setUpAll(() {
    registerFallbackValue(FakeBaseLogMessage());
    registerFallbackValue(FakeFlutterErrorDetails());
  });

  setUp(() {
    mockExceptionReportManager = MockExceptionReportManager();
    mockLogManager = MockLogManager();
    logStreamController = StreamController<BaseLogMessage>.broadcast();
    when(() => mockLogManager.logStream)
        .thenAnswer((_) => logStreamController.stream);
    testManager = CustomExceptionReportManager(mockLogManager);
  });

  tearDown(() {
    logStreamController.close();
  });

  group('ExceptionReportManager', () {
    test('enableReporting starts listening to log stream', () async {
      when(() => mockExceptionReportManager.enableReporting())
          .thenAnswer((_) async {
        return;
      });
      when(() => mockExceptionReportManager.enabledReporting).thenReturn(true);

      await mockExceptionReportManager.enableReporting();

      expect(mockExceptionReportManager.enabledReporting, isTrue);
      verify(() => mockExceptionReportManager.enableReporting()).called(1);
    });

    test('disableReporting stops listening to log stream', () async {
      when(() => mockExceptionReportManager.enableReporting())
          .thenAnswer((_) async {
        return;
      });
      when(() => mockExceptionReportManager.disableReporting())
          .thenAnswer((_) async {
        return;
      });
      when(() => mockExceptionReportManager.enabledReporting).thenReturn(false);

      await mockExceptionReportManager.enableReporting();
      await mockExceptionReportManager.disableReporting();

      expect(mockExceptionReportManager.enabledReporting, isFalse);
      verify(() => mockExceptionReportManager.disableReporting()).called(1);
    });

    test('report logs the exception', () async {
      final BaseLogMessage testLog = BaseLogMessage(
        logLevel: LogLevel.error,
        message: 'Test error',
        error: Exception('Test'),
      );

      when(() => mockExceptionReportManager.report(any()))
          .thenAnswer((_) async => true);

      await mockExceptionReportManager.report(testLog);

      verify(() => mockExceptionReportManager.report(testLog)).called(1);
    });

    test('reportFatal logs a fatal exception', () async {
      final FlutterErrorDetails errorDetails = FlutterErrorDetails(
        exception: Exception('Fatal error'),
        stack: StackTrace.current,
        library: 'test_library',
      );

      when(() => mockExceptionReportManager.reportFatal(any()))
          .thenAnswer((_) async => true);

      await mockExceptionReportManager.reportFatal(errorDetails);

      verify(() => mockExceptionReportManager.reportFatal(errorDetails))
          .called(1);
    });

    test('reportFatal includes context in additionalContext', () async {
      final FlutterErrorDetails errorDetails = FlutterErrorDetails(
        exception: Exception('Fatal error'),
        stack: StackTrace.current,
        library: 'test_library',
      );

      final List<String> capturedLogs = <String>[];
      when(() => mockLogManager.lInfo(any()))
          .thenAnswer((Invocation invocation) {
        capturedLogs.add(invocation.positionalArguments[0] as String);
      });

      final Map<String, dynamic> additionalContext = <String, dynamic>{
        'context': 'Test context',
      };
      await testManager.reportFatal(
        errorDetails,
        additionalContext: additionalContext,
      );

      expect(testManager.reportFatalCalls.length, 1);
      final BaseLogMessage reportedLog = testManager.reportFatalCalls.first;

      // Verify that lInfo was called twice
      verify(() => mockLogManager.lInfo(any())).called(2);

      // Check if any of the logs contain the expected strings
      final bool containsContext = capturedLogs.any(
        (String log) => log.contains(
          '${additionalContext.keys.first}: ${additionalContext.values.first}',
        ),
      );

      expect(
        containsContext,
        isTrue,
        reason: 'Log should contain "Test context"',
      );

      expect(reportedLog.error, errorDetails.exception);
      expect(reportedLog.stackTrace, errorDetails.stack);
      expect(reportedLog.logLevel, LogLevel.error);
      expect(reportedLog.message, errorDetails.exceptionAsString());
    });

    test('shouldReport returns correct value', () async {
      when(() => mockExceptionReportManager.shouldReport(any()))
          .thenReturn(true);
      when(() => mockExceptionReportManager.shouldReport(null))
          .thenReturn(false);

      expect(mockExceptionReportManager.shouldReport(null), isFalse);
      expect(
        mockExceptionReportManager.shouldReport(Exception('Test')),
        isTrue,
      );

      verify(() => mockExceptionReportManager.shouldReport(null)).called(1);
      verify(() => mockExceptionReportManager.shouldReport(any())).called(1);
    });

    test('rate limiting works correctly', () async {
      final BaseLogMessage baseLogMessage = BaseLogMessage(
        logLevel: LogLevel.error,
        message: 'Error',
        error: Exception('Test'),
      );

      when(() => mockExceptionReportManager.report(any()))
          .thenAnswer((_) async => true);
      when(() => mockExceptionReportManager.maxReportsPerMinute).thenReturn(2);

      // First two reports should go through
      await mockExceptionReportManager.report(baseLogMessage);
      await mockExceptionReportManager.report(baseLogMessage);

      // Third report should be rate limited
      await mockExceptionReportManager.report(baseLogMessage);

      verify(() => mockExceptionReportManager.report(any())).called(3);
    });

    test('reports error logs and respects rate limiting', () async {
      // Enable reporting
      await testManager.enableReporting();

      // Emit a log that should be reported
      final BaseLogMessage errorLog = BaseLogMessage(
        logLevel: LogLevel.error,
        message: 'Test error',
        error: Exception('Test exception'),
      );
      logStreamController.add(errorLog);

      // Wait for the async operations to complete
      await Future<void>.delayed(Duration.zero);

      // Verify that report was called once
      expect(testManager.reportCalls.length, 1);
      expect(testManager.reportCalls.first, errorLog);

      // Emit multiple logs to trigger rate limiting
      for (int i = 0; i < testManager.maxReportsPerMinute; i++) {
        logStreamController.add(errorLog);
        await Future<void>.delayed(Duration.zero);
      }

      // Wait for the async operations to complete
      await Future<void>.delayed(Duration.zero);

      // Verify that report was called only maxReportsPerMinute times
      expect(
        testManager.reportCalls.length,
        testManager.maxReportsPerMinute,
      );
    });

    test('logs warning when rate limit is exceeded', () async {
      final BaseLogMessage errorLog = BaseLogMessage(
        logLevel: LogLevel.error,
        message: 'Test error',
        error: Exception('Test exception'),
      );

      // Enable reporting
      await testManager.enableReporting();

      // Exceed the rate limit
      for (int i = 0; i < testManager.maxReportsPerMinute + 1; i++) {
        await testManager.report(errorLog);
      }

      // Verify that the warning message was logged
      verify(
        () => mockLogManager.lWarning('Rate limit exceeded. Skipping report.'),
      ).called(1);
    });

    test('shouldReport returns correct values for different scenarios',
        () async {
      // Test when reporting is not enabled
      expect(testManager.shouldReport(Exception('Test')), isFalse);

      // Enable reporting
      await testManager.enableReporting();

      // Test with null error
      expect(testManager.shouldReport(null), isFalse);

      // Test with non-null error and no filter
      expect(testManager.shouldReport(Exception('Test')), isTrue);

      // Test with custom error filter
      testManager.errorFilter = (Object? error) => error is ArgumentError;
      expect(testManager.shouldReport(Exception('Test')), isFalse);
      expect(testManager.shouldReport(ArgumentError('Test')), isTrue);

      // Disable reporting
      await testManager.disableReporting();
      expect(testManager.shouldReport(Exception('Test')), isFalse);
    });
  });
}
