import 'package:exception_report_manager/src/firebase_exception_report_manager.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

class MockLogManager extends Mock implements LogManager {
  @override
  Stream<BaseLogMessage> get logStream => const Stream<BaseLogMessage>.empty();
}

class FakeBaseLogMessage extends Fake implements BaseLogMessage {}

class FakeFlutterErrorDetails extends Fake implements FlutterErrorDetails {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => '';
}

void main() {
  late FirebaseCrashlyticsReportManager manager;
  late MockFirebaseCrashlytics mockCrashlytics;
  late MockLogManager mockLogManager;

  setUpAll(() {
    registerFallbackValue(FakeBaseLogMessage());
    registerFallbackValue(FakeFlutterErrorDetails());
  });

  setUp(() {
    mockCrashlytics = MockFirebaseCrashlytics();
    mockLogManager = MockLogManager();
    manager = FirebaseCrashlyticsReportManager(
      logManager: mockLogManager,
      crashlytics: mockCrashlytics,
    );

    // Common stub for all tests
    when(() => mockCrashlytics.setCrashlyticsCollectionEnabled(any<bool>()))
        .thenAnswer((_) => Future<void>.value());
  });

  group('FirebaseCrashlyticsReportManager', () {
    test('enableReporting enables Crashlytics collection', () async {
      await manager.enableReporting();
      verify(() => mockCrashlytics.setCrashlyticsCollectionEnabled(true))
          .called(1);
    });

    test('disableReporting disables Crashlytics collection', () async {
      await manager.disableReporting();
      verify(() => mockCrashlytics.setCrashlyticsCollectionEnabled(false))
          .called(1);
    });

    group('report', () {
      late BaseLogMessage testLog;

      setUp(() {
        testLog = BaseLogMessage(
          logLevel: LogLevel.error,
          message: 'Test error',
          error: Exception('Test'),
          stackTrace: StackTrace.current,
        );

        when(
          () => mockCrashlytics.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: any<String>(named: 'reason'),
            fatal: any<bool>(named: 'fatal'),
            information: any<List<Object>>(named: 'information'),
          ),
        ).thenAnswer((_) => Future<void>.value());
      });

      test('records error when reporting is enabled', () async {
        when(() => mockCrashlytics.isCrashlyticsCollectionEnabled)
            .thenReturn(true);

        await manager.enableReporting();
        final bool result = await manager.report(testLog);

        expect(result, isTrue);
        verify(
          () => mockCrashlytics.recordError(
            testLog.error,
            testLog.stackTrace,
            reason: testLog.message,
            information: <Object>['logLevel: ${testLog.logLevel}'],
          ),
        ).called(1);
      });

      test('does not record error when reporting is disabled', () async {
        when(() => mockCrashlytics.isCrashlyticsCollectionEnabled)
            .thenReturn(false);

        await manager.disableReporting();
        final bool result = await manager.report(testLog);

        expect(result, isFalse);
        verifyNever(
          () => mockCrashlytics.recordError(
            any<dynamic>(),
            any(),
            reason: any<dynamic>(named: 'reason'),
            fatal: any(named: 'fatal'),
            information: any(named: 'information'),
          ),
        );
      });

      test('includes additionalContext when provided', () async {
        when(() => mockCrashlytics.isCrashlyticsCollectionEnabled)
            .thenReturn(true);
        final Map<String, dynamic> additionalContext = <String, dynamic>{
          'key': 'value',
        };

        await manager.enableReporting();
        await manager.report(testLog, additionalContext: additionalContext);

        verify(
          () => mockCrashlytics.recordError(
            testLog.error,
            testLog.stackTrace,
            reason: testLog.message,
            information: <Object>[
              'logLevel: ${testLog.logLevel}',
              'key: value',
            ],
          ),
        ).called(1);
      });
    });

    group('reportFatal', () {
      late FlutterErrorDetails errorDetails;

      setUp(() {
        errorDetails = FlutterErrorDetails(
          exception: Exception('Fatal error'),
          stack: StackTrace.current,
          library: 'test_library',
        );

        when(() => mockCrashlytics.recordFlutterFatalError(any()))
            .thenAnswer((_) async {});
        when(
          () => mockCrashlytics.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: any<String>(named: 'reason'),
            fatal: any<bool>(named: 'fatal'),
            information: any<List<Object>>(named: 'information'),
          ),
        ).thenAnswer((_) => Future<void>.value());
      });

      test('records fatal error when reporting is enabled', () async {
        when(() => mockCrashlytics.isCrashlyticsCollectionEnabled)
            .thenReturn(true);

        await manager.enableReporting();
        await manager.reportFatal(errorDetails);

        verify(() => mockCrashlytics.recordFlutterFatalError(errorDetails))
            .called(1);
      });

      test('does not record fatal error when reporting is disabled', () async {
        when(() => mockCrashlytics.isCrashlyticsCollectionEnabled)
            .thenReturn(false);

        await manager.disableReporting();
        await manager.reportFatal(errorDetails);

        verifyNever(() => mockCrashlytics.recordFlutterFatalError(any()));
      });
    });

    test('enabledReporting returns correct value', () async {
      when(() => mockCrashlytics.isCrashlyticsCollectionEnabled)
          .thenReturn(true);
      await manager.enableReporting();
      expect(manager.enabledReporting, isTrue);

      when(() => mockCrashlytics.isCrashlyticsCollectionEnabled)
          .thenReturn(false);
      expect(manager.enabledReporting, isFalse);
    });
  });
}
