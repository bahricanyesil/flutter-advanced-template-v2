// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:log_manager/src/logger_log_manager.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockLogger extends Mock implements Logger {
  @override
  Future<void> close() async => super.noSuchMethod(
        Invocation.method(#close, <Object?>[]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      );
}

class MockStreamOutput extends Mock implements CustomStreamOutput {
  final StreamController<BaseLogMessage> _controller =
      StreamController<BaseLogMessage>.broadcast();

  @override
  Stream<BaseLogMessage> get stream => _controller.stream;

  @override
  void output(BaseLogMessage message) {
    _controller.add(message); // Simulate emitting the log message
  }

  @override
  Future<void> destroy() async => super.noSuchMethod(
        Invocation.method(#destroy, <Object?>[]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      );
}

void main() {
  // Initialize Flutter bindings before running any tests
  TestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  group('LoggerLogManager', () {
    late MockLogger mockLogger;
    late MockStreamOutput mockStreamOutput;
    late LoggerLogManager logManager;

    setUp(() {
      mockLogger = MockLogger();
      mockStreamOutput = MockStreamOutput();
      logManager =
          LoggerLogManager(logger: mockLogger, streamOutput: mockStreamOutput);
    });

    test('initializes LoggerLogManager correctly', () {
      expect(logManager, isNotNull);
      expect(logManager.loggingEnabled, isTrue);
    });

    test('logs at different levels', () {
      logManager.lTrace('Trace message');
      logManager.lDebug('Debug message');
      logManager.lInfo('Info message');
      logManager.lWarning('Warning message');
      logManager.lError('Error message');
      logManager.lFatal('Fatal error message');

      verify(mockLogger.t('Trace message')).called(1);
      verify(mockLogger.d('Debug message')).called(1);
      verify(mockLogger.i('Info message')).called(1);
      verify(mockLogger.w('Warning message')).called(1);
      verify(mockLogger.e('Error message')).called(1);
      verify(mockLogger.f('Fatal error message')).called(1);
    });
    
    test('emits messages to stream', () async {
      final List<BaseLogMessage> logMessages = <BaseLogMessage>[];

      logManager.logStream.listen(logMessages.add);

      // Simulate adding a log message
      const BaseLogMessage logMessage = BaseLogMessage(
        message: 'Info message',
        logLevel: LogLevel.info,
      );

      logManager.streamOutput.output(logMessage);

      // Give it some time to process
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify the log messages list is populated
      expect(logMessages.isNotEmpty, isTrue);
      expect(logMessages.first.message, 'Info message');
    });

    test('handles Flutter errors', () async {
      final FlutterErrorDetails flutterErrorDetails = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );

      logManager.setFlutterErrorHandlers();

      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      FlutterError.onError!(flutterErrorDetails);

      verify(
        mockLogger.e(
          'Flutter Error: ${flutterErrorDetails.exception}',
          error: flutterErrorDetails.exception,
          stackTrace: flutterErrorDetails.stack,
        ),
      ).called(1);

      FlutterError.onError = originalOnError;
    });

    test('setUp method initializes LogManager correctly', () {
      const BaseLogOptions options = BaseLogOptions(showTime: false);

      logManager.setUp<LoggerLogManager>(
        (LogManager logManager) => LoggerLogManager(logger: mockLogger),
        options,
      );

      // Verify initialization logic, e.g., logging state or options
      verifyNever(
        mockLogger.t(any),
      ); // No logs should be output in release mode
      expect(logManager.loggingEnabled, isTrue);
    });

    test('close method cleans up resources', () async {
      await logManager.close();

      verify(mockStreamOutput.destroy()).called(1);
      verify(mockLogger.close()).called(1);
    });
  });
}
