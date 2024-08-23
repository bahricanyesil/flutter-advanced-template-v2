import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:log_manager/src/logger_log_manager.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockLogger extends Mock implements Logger {
  @override
  Future<void> close() async =>
      super.noSuchMethod(Invocation.method(#close, <Object?>[]));
}

class MockStreamOutput extends Mock implements CustomStreamOutput {
  final StreamController<BaseLogMessage> _controller =
      StreamController<BaseLogMessage>.broadcast();

  @override
  Stream<BaseLogMessage> get stream => _controller.stream;

  @override
  void output(BaseLogMessage message) => _controller.add(message);

  @override
  Future<void> destroy() async =>
      super.noSuchMethod(Invocation.method(#destroy, <Object?>[]));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      final List<BaseLogMessage> logMessages = <BaseLogMessage>[];
      logManager.logStream.listen(logMessages.add);

      const BaseLogMessage logMessage =
          BaseLogMessage(message: 'Info message', logLevel: LogLevel.info);
      logManager.streamOutput.output(logMessage);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(logMessages, isNotEmpty);
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
        () => mockLogger.e(
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

      verifyNever(() => mockLogger.t(any));
      expect(logManager.loggingEnabled, isTrue);
    });

    test('close method cleans up resources', () async {
      await logManager.close();

      verify(() => mockStreamOutput.destroy()).called(1);
      verify(() => mockLogger.close()).called(1);
    });
  });
}
