import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:log_manager/src/logger_build_mode.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_build_mode.dart';
import 'mocks/mock_custom_test_platform_dispatcher.dart';
import 'mocks/mock_logger.dart';
import 'mocks/mock_logger_wrapper.dart';
import 'mocks/mock_stream_output.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoggerLogManager', () {
    late MockBuildMode mockBuildMode;
    late MockLoggerWrapper mockLoggerWrapper;
    late MockLogger mockLogger;
    late MockStreamOutput mockStreamOutput;
    late LoggerLogManager logManager;

    setUp(() {
      mockBuildMode = MockBuildMode();
      mockLoggerWrapper = MockLoggerWrapper();
      mockLogger = MockLogger();
      mockStreamOutput = MockStreamOutput();
      logManager = LoggerLogManager(
        logger: mockLogger,
        streamOutput: mockStreamOutput,
        outputWrapper: mockLoggerWrapper,
        buildMode: mockBuildMode,
      );
    });

    test('initializes LoggerLogManager correctly', () {
      expect(logManager, isNotNull);
      expect(logManager.loggingEnabled, isTrue);
    });

    test('logs at different levels', () {
      logManager
        ..lTrace('Trace message')
        ..lDebug('Debug message')
        ..lInfo('Info message')
        ..lWarning('Warning message')
        ..lError('Error message')
        ..lFatal('Fatal error message');

      verify(() => mockLogger.t('Trace message')).called(1);
      verify(() => mockLogger.d('Debug message')).called(1);
      verify(() => mockLogger.i('Info message')).called(1);
      verify(() => mockLogger.w('Warning message')).called(1);
      verify(() => mockLogger.e('Error message')).called(1);
      verify(() => mockLogger.f('Fatal error message')).called(1);
    });

    test('emits messages to stream', () async {
      final List<BaseLogMessageModel> logMessages = <BaseLogMessageModel>[];
      logManager.logStream.listen(logMessages.add);

      const BaseLogMessageModel logMessage = BaseLogMessageModel(
        message: 'Info message',
        logLevel: LogLevels.info,
      );
      logManager.streamOutput.output(logMessage);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(logMessages, isNotEmpty);
      expect(logMessages.first.message, 'Info message');
    });

    test('handles Flutter errors and platform dispatch errors', () async {
      final FlutterErrorDetails flutterErrorDetails = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );
      final MockCustomTestPlatformDispatcher customPlatformDispatcher =
          MockCustomTestPlatformDispatcher(
        platformDispatcher: PlatformDispatcher.instance,
      );
      // ignore: cascade_invocations
      customPlatformDispatcher.onError = (Object error, StackTrace stack) {
        /// Original dispatcher on error callback.
        return true;
      };

      logManager.setFlutterErrorHandlers(dispatcher: customPlatformDispatcher);

      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      FlutterError.onError!(flutterErrorDetails);

      verify(
        () => mockLogger.e(
          'Flutter Error: ${flutterErrorDetails.exception}',
          error: flutterErrorDetails.exception,
          stackTrace: flutterErrorDetails.stack,
        ),
      ).called(1);

      final StackTrace s = StackTrace.fromString('stackTraceString');
      const String errorMessage = 'Test error';

      customPlatformDispatcher.onError?.call(errorMessage, s);

      verify(
        () => customPlatformDispatcher.onError?.call(errorMessage, s),
      ).called(1);

      FlutterError.onError = originalOnError;
    });

    test('setUp method initializes LogManager correctly', () {
      when(() => mockBuildMode.isReleaseMode).thenReturn(false);
      const BaseLogOptionsModel options = BaseLogOptionsModel(showTime: false);

      final LoggerLogManager newLogManager = logManager.setUp<LoggerLogManager>(
        (LogManager logManager) => LoggerLogManager(logger: mockLogger),
        options,
      );

      verifyNever(() => mockLogger.t(any));
      expect(newLogManager.loggingEnabled, isTrue);

      newLogManager.disableLogging();
      expect(newLogManager.loggingEnabled, isFalse);
    });

    test('close method cleans up resources', () async {
      await logManager.close();

      verify(mockStreamOutput.destroy).called(1);
      verify(mockLogger.close).called(1);
    });

    test('disableLogging method disables logging', () {
      // Set up
      logManager
        ..enableLogging()

        // Act
        ..disableLogging();

      // Verify logging is disabled
      expect(logManager.loggingEnabled, isFalse);

      // Act
      logManager.lInfo('This message should not be logged.');

      // Verify that logging methods are not called
      verifyNever(() => mockLogger.i('This message should not be logged.'));
    });

    test('''
setUp disables logging in release mode
        if options.logInRelease is false''', () {
      when(() => mockBuildMode.isReleaseMode).thenReturn(true);

      final LoggerLogManager newLogManager =
          logManager.setUp<LoggerLogManager>((_) => logManager);

      // Verify disableLogging was called
      expect(newLogManager.loggingEnabled, false);
    });

    test('''
setUp enables logging if not in
        release mode or options.logInRelease is true''', () {
      when(() => mockBuildMode.isReleaseMode).thenReturn(false);

      final LoggerLogManager newLogManager =
          logManager.setUp<LoggerLogManager>((_) => logManager);

      // Verify disableLogging was called
      expect(newLogManager.loggingEnabled, true);
    });

    test('Stream output listener listens messages successfully', () async {
      final Set<VoidCallback> callers = <VoidCallback>{};
      const BaseLogMessageModel baseMessage = BaseLogMessageModel(
        message: 'Test message',
        logLevel: LogLevels.info,
      );
      when(() => mockLoggerWrapper.addOutputListener(any()))
          .thenAnswer((Invocation invocation) {
        // Capture the argument passed to addOutputListener
        final OutputCallback listener =
            invocation.positionalArguments[0] as OutputCallback;

        // Add it to the callers list
        final LogEvent logEvent = LogEvent(Level.info, baseMessage.message);
        final List<String> output = CustomPrettyPrinter().log(logEvent);
        final OutputEvent outputEvent = OutputEvent(logEvent, output);
        callers.add(() => listener(outputEvent));
      });

      when(() => logManager.lInfo(any())).thenAnswer((_) {
        for (final VoidCallback caller in callers) {
          caller();
        }
      });

      // Set up
      final List<BaseLogMessageModel> logMessages = <BaseLogMessageModel>[];
      logManager.logStream.listen(logMessages.add);

      // Enable logging
      logManager
        ..enableLogging()

        // Trigger a log message
        ..lInfo('Test message');

      // Wait for the log message to be processed
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify the message was processed
      expect(logMessages, isNotEmpty);
      expect(logMessages.first.message, 'Test message');

      // Disable logging
      logManager.disableLogging();

      // Clear the log messages list
      logMessages.clear();

      // Trigger another log message
      logManager.lInfo('Another test message');

      // Wait for the log message to be processed
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify the message was not processed
      expect(logMessages, isEmpty);
    });
  });

  group('LoggerBuildMode', () {
    late LoggerBuildMode buildModeImpl;

    setUp(() {
      buildModeImpl = LoggerBuildModeImpl();
    });

    test('should return kReleaseMode for isReleaseMode', () {
      expect(buildModeImpl.isReleaseMode, equals(kReleaseMode));
    });
  });
}
