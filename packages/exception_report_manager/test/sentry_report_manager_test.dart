// ignore_for_file: avoid-dynamic

import 'package:exception_report_manager/src/sentry_exception_report_manager.dart';
import 'package:exception_report_manager/src/utils/log_level_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'mocks/mock_log_manager.dart';
import 'mocks/mock_sentry_client.dart';

void main() {
  late SentryExceptionReportManager manager;
  late MockSentryClient mockSentryClient;
  late MockLogManager mockLogManager;

  const String fakeDsn = 'https://examplePublicKey@o0.ingest.sentry.io/0';

  setUpAll(() {
    registerFallbackValue(SentryFlutterOptions());
    registerFallbackValue(SentryEvent());
  });

  setUp(() async {
    mockSentryClient = MockSentryClient();
    mockLogManager = MockLogManager();

    when(() => mockLogManager.logStream)
        .thenAnswer((_) => const Stream<BaseLogMessage>.empty());

    await Sentry.init(
      (SentryOptions options) {
        options
          ..dsn = fakeDsn
          ..environment = 'test';
      },
    );

    Sentry.bindClient(mockSentryClient);

    manager = SentryExceptionReportManager(
      logManager: mockLogManager,
      sentryDSN: fakeDsn,
      sentryEnvironment: 'test',
    );
  });

  tearDown(() async {
    await Sentry.close();
  });

  group('SentryExceptionReportManager', () {
    test(
        'enableReporting initializes Sentry and disableReporting closes Sentry',
        () async {
      await manager.enableReporting();
      verify(() => mockLogManager.lInfo(any())).called(1);
      expect(manager.enabledReporting, true);

      await manager.disableReporting();
      verify(() => mockLogManager.lInfo(any())).called(1);
      expect(manager.enabledReporting, false);
    });

    test('report captures exception with Sentry', () async {
      await manager.enableReporting(initSentry: false);

      final BaseLogMessage logWithError = BaseLogMessage(
        message: 'Test error',
        logLevel: LogLevel.error,
        error: Exception('Test'),
        stackTrace: StackTrace.current,
      );

      final Map<String, dynamic> additionalContext = <String, dynamic>{
        'test': 'tested successfully',
        'key2': 'value2',
        'key3': 42,
      };

      await manager.report(logWithError, additionalContext: additionalContext);

      expect(mockSentryClient.captureEventCalls.length, 1);
      expect(
        mockSentryClient.captureEventCalls.first.event.throwable,
        logWithError.error,
      );

      // Verify all additional context items are present
      additionalContext.forEach((String key, dynamic value) {
        expect(
          mockSentryClient.captureEventCalls.first.scope?.contexts,
          containsPair(key, <String, dynamic>{'value': value}),
        );
      });

      // Verify the number of custom context items
      expect(
        mockSentryClient.captureEventCalls.first.scope?.contexts.entries
            .where(
              (MapEntry<String, dynamic> entry) =>
                  additionalContext.containsKey(entry.key),
            )
            .length,
        additionalContext.length,
      );
    });

    test('reportFatal captures fatal exception with Sentry', () async {
      await manager.enableReporting(initSentry: false);

      final FlutterErrorDetails errorDetails = FlutterErrorDetails(
        exception: Exception('Fatal error'),
        stack: StackTrace.current,
      );

      await manager.reportFatal(errorDetails);

      // Verify that captureEvent was called
      expect(mockSentryClient.captureEventCalls.length, 1);

      // Verify the captured event details
      final CaptureEventCall capturedCall =
          mockSentryClient.captureEventCalls.first;
      expect(capturedCall.event.throwable, errorDetails.exception);
      expect(capturedCall.stackTrace, errorDetails.stack);
      expect(capturedCall.scope, isNotNull);
    });

    group('reportFatal', () {
      test('captures fatal exception with Sentry', () async {
        await manager.enableReporting(initSentry: false);

        final FlutterErrorDetails errorDetails = FlutterErrorDetails(
          exception: Exception('Fatal error'),
          stack: StackTrace.current,
        );

        await manager.reportFatal(errorDetails);

        // Verify that captureEvent was called
        expect(mockSentryClient.captureEventCalls.length, 1);

        // Verify the captured event details
        final CaptureEventCall capturedCall =
            mockSentryClient.captureEventCalls.first;
        expect(capturedCall.event.throwable, errorDetails.exception);
        expect(capturedCall.stackTrace, errorDetails.stack);
        expect(capturedCall.scope, isNotNull);
      });

      test('includes information collector data when available', () async {
        await manager.enableReporting(initSentry: false);

        final FlutterErrorDetails errorDetails = FlutterErrorDetails(
          exception: Exception('Fatal error'),
          stack: StackTrace.current,
          informationCollector: () sync* {
            yield DiagnosticsProperty<String>('Test Info', 'This is a test');
            yield DiagnosticsProperty<String>(
              'More Info',
              'Additional information',
            );
          },
        );

        await manager.reportFatal(errorDetails);

        expect(mockSentryClient.captureEventCalls.length, 1);
        final CaptureEventCall capturedCall =
            mockSentryClient.captureEventCalls.first;

        // Verify that the Additional Information context was set
        expect(
          capturedCall.scope?.contexts['Additional Information'],
          containsPair('details', contains('Test Info: This is a test')),
        );
        expect(
          capturedCall.scope?.contexts['Additional Information'],
          containsPair(
            'details',
            contains('More Info: Additional information'),
          ),
        );
      });

      test('handles null informationCollector gracefully', () async {
        await manager.enableReporting(initSentry: false);

        final FlutterErrorDetails errorDetails = FlutterErrorDetails(
          exception: Exception('Fatal error'),
          stack: StackTrace.current,
          // informationCollector is null by default
        );

        await manager.reportFatal(errorDetails);

        expect(mockSentryClient.captureEventCalls.length, 1);
        final CaptureEventCall capturedCall =
            mockSentryClient.captureEventCalls.first;

        // Verify that the Additional Information context was not set
        expect(
          capturedCall.scope?.contexts['Additional Information'],
          isNull,
        );
      });
    });
  });

  group('Sentry is enabled or disabled', () {
    test('enableReporting enables Sentry', () async {
      await manager.enableReporting();
      expect(Sentry.isEnabled, true);
    });

    test('disableReporting disables Sentry', () async {
      await manager.enableReporting();
      await manager.disableReporting();
      expect(Sentry.isEnabled, false);
    });
  });

  group('SentryExceptionReportManager - captureMessage', () {
    test('captureMessage is called with correct parameters', () async {
      await manager.enableReporting(initSentry: false);

      final BaseLogMessage logMessage = BaseLogMessage(
        message: 'Test message',
        logLevel: LogLevel.error,
        time: DateTime.now(),
      );

      await manager.report(logMessage);

      expect(mockSentryClient.captureMessageCalls.length, 1);
      expect(
        mockSentryClient.captureMessageCalls.first.formatted,
        'Test message',
      );
      expect(
        mockSentryClient.captureMessageCalls.first.level,
        SentryLevel.error,
      );
    });

    test('captureMessage handles non-string messages', () async {
      await manager.enableReporting(initSentry: false);

      final BaseLogMessage logMessage = BaseLogMessage(
        message: Exception('Test exception'),
        logLevel: LogLevel.warning,
        time: DateTime.now(),
      );

      await manager.report(logMessage);

      expect(mockSentryClient.captureMessageCalls.length, 1);
      expect(
        mockSentryClient.captureMessageCalls.first.formatted,
        'Exception: Test exception',
      );
      expect(
        mockSentryClient.captureMessageCalls.first.level,
        SentryLevel.warning,
      );
    });

    test('captureMessage uses correct SentryLevel for each LogLevel', () async {
      await manager.enableReporting(initSentry: false);

      for (final LogLevel logLevel in LogLevel.values) {
        final BaseLogMessage logMessage = BaseLogMessage(
          message: 'Test ${logLevel.name}',
          logLevel: logLevel,
          time: DateTime.now(),
        );

        await manager.report(logMessage);

        expect(
          mockSentryClient.captureMessageCalls.length,
          LogLevel.values.indexOf(logLevel) + 1,
        );
        expect(
          mockSentryClient.captureMessageCalls.last.formatted,
          'Test ${logLevel.name}',
        );
        expect(
          mockSentryClient.captureMessageCalls.last.level?.name,
          logLevel.sentryLevel.name,
        );
      }
    });

    test('captureMessage handles additional context', () async {
      await manager.enableReporting(initSentry: false);

      final BaseLogMessage logMessage = BaseLogMessage(
        message: 'Test with context',
        logLevel: LogLevel.info,
        time: DateTime.now(),
      );

      final Map<String, dynamic> additionalContext = <String, dynamic>{
        'key1': 'value1',
        'key2': 42,
      };

      await manager.report(logMessage, additionalContext: additionalContext);

      expect(mockSentryClient.captureMessageCalls.length, 1);
      expect(
        mockSentryClient.captureMessageCalls.last.formatted,
        'Test with context',
      );
      expect(
        mockSentryClient.captureMessageCalls.last.level,
        SentryLevel.info,
      );

      additionalContext.forEach((String key, dynamic value) {
        expect(
          mockSentryClient.captureMessageCalls.last.scope?.contexts,
          containsPair(key, <String, dynamic>{'value': value}),
        );
      });
    });

    test('captureMessage handles empty additional context', () async {
      await manager.enableReporting(initSentry: false);

      final BaseLogMessage logMessage = BaseLogMessage(
        message: 'Test with empty context',
        logLevel: LogLevel.debug,
        time: DateTime.now(),
      );

      await manager.report(logMessage, additionalContext: <String, dynamic>{});

      expect(mockSentryClient.captureMessageCalls.length, 1);
      expect(
        mockSentryClient.captureMessageCalls.last.formatted,
        'Test with empty context',
      );
      expect(
        mockSentryClient.captureMessageCalls.last.level,
        SentryLevel.debug,
      );

      expect(
        mockSentryClient.captureMessageCalls.last.scope?.contexts.entries
            .where(
              (MapEntry<String, dynamic> entry) =>
                  entry.value is Map<String, dynamic> &&
                  (entry.value as Map<String, dynamic>).containsKey('value'),
            )
            .isEmpty,
        isTrue,
      );
    });

    test('captureException handles exception details', () async {
      await manager.enableReporting(initSentry: false);

      final BaseLogMessage logMessage = BaseLogMessage(
        message: 'Test report with error',
        logLevel: LogLevel.error,
        time: DateTime.now(),
        error: Exception('Test exception'),
        stackTrace: StackTrace.current,
      );

      await manager.report(logMessage, additionalContext: <String, dynamic>{});

      // Verify that captureEvent was called
      expect(mockSentryClient.captureEventCalls.length, 1);

      // Verify the captured event details
      final CaptureEventCall capturedCall =
          mockSentryClient.captureEventCalls.first;
      expect(capturedCall.event.throwable, logMessage.error);
      expect(capturedCall.stackTrace, logMessage.stackTrace);

      final BaseLogMessage withoutErrorLog = BaseLogMessage(
        message: 'Test report with error',
        logLevel: LogLevel.error,
        time: DateTime.now(),
        stackTrace: StackTrace.current,
      );

      await manager
          .report(withoutErrorLog, additionalContext: <String, dynamic>{});

      // Verify that captureEvent was called
      expect(mockSentryClient.captureEventCalls.length, 2);

      // Verify the captured event details
      final CaptureEventCall capturedCall2 =
          mockSentryClient.captureEventCalls.first;
      expect(capturedCall2.event.throwable, isException);
      expect(capturedCall2.stackTrace, logMessage.stackTrace);
    });
  });
}
