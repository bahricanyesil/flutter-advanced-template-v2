import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_log_manager.dart';

void main() {
  group('LogManager', () {
    test('logs at different levels', () {
      final MockLogManager logManager = MockLogManager()
        ..lTrace('Trace message')
        ..lDebug('Debug message')
        ..lInfo('Info message')
        ..lWarning('Warning message')
        ..lError('Error message')
        ..lFatal('Fatal error message');

      verify(() => logManager.lTrace('Trace message')).called(1);
      verify(() => logManager.lDebug('Debug message')).called(1);
      verify(() => logManager.lInfo('Info message')).called(1);
      verify(() => logManager.lWarning('Warning message')).called(1);
      verify(() => logManager.lError('Error message')).called(1);
      verify(() => logManager.lFatal('Fatal error message')).called(1);
    });

    test('logs errors and fatal errors', () {
      final MockLogManager logManager = MockLogManager()
        ..lError('Error message', error: Exception('Test error'))
        ..lFatal('Fatal error message');

      verify(() => logManager.lError('Error message', error: isA<Exception>()))
          .called(1);
      verify(() => logManager.lFatal('Fatal error message')).called(1);
    });

    test('handles logging state', () {
      final MockLogManager logManager = MockLogManager()
        ..enableLogging()
        ..lInfo('Info message')
        ..disableLogging()
        ..lInfo('Info message');

      verify(() => logManager.lInfo('Info message')).called(2);
    });

    test('emits messages to stream', () async {
      final MockLogManager logManager = MockLogManager();
      final List<BaseLogMessageModel> logMessages = <BaseLogMessageModel>[];

      logManager.logStream.listen(logMessages.add);

      const BaseLogMessageModel logMessage = BaseLogMessageModel(
        message: 'Info message',
        logLevel: LogLevels.info,
      );
      logManager.addLogMessage(logMessage);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(logMessages, isNotEmpty);
      expect(logMessages.first.message, 'Info message');
    });

    test('logs Flutter and platform dispatcher errors', () {
      final MockLogManager logManager = MockLogManager();
      final FlutterErrorDetails flutterError =
          FlutterErrorDetails(exception: Exception('Test error'));

      logManager.logFlutterError(flutterError);

      final TextTreeRenderer renderer = TextTreeRenderer(
        wrapWidthProperties: 100,
        maxDescendentsTruncatableNode: 5,
      );
      final String message = renderer
          .render(
            flutterError.toDiagnosticsNode(style: DiagnosticsTreeStyle.error),
          )
          .trimRight();

      verify(
        () => logManager.lError(
          'Flutter Error: $message',
          stackTrace: flutterError.stack,
          fatal: true,
          error: flutterError.exception,
        ),
      ).called(1);

      final Exception dispatcherException = Exception('Test error');
      final StackTrace dispatcherStackTrace = StackTrace.current;

      logManager.logPlatformDispatcherError(
        dispatcherException,
        dispatcherStackTrace,
      );

      verify(
        () => logManager.lError(
          'Platform Dispatcher Error: $dispatcherException',
          error: dispatcherException,
          stackTrace: dispatcherStackTrace,
        ),
      ).called(1);
    });

    test('loggingEnabled state control', () {
      final MockLogManager logManager = MockLogManager();

      expect(logManager.loggingEnabled, isTrue);

      logManager.disableLogging();
      expect(logManager.loggingEnabled, isFalse);

      logManager.enableLogging();
      expect(logManager.loggingEnabled, isTrue);
    });

    test('verify no unexpected method calls', () {
      final MockLogManager logManager = MockLogManager()..lInfo('Info message');

      verifyNever(() => logManager.lDebug('any'));
      verifyNever(() => logManager.lTrace('any'));
    });

    test('handles empty log message', () {
      final MockLogManager logManager = MockLogManager()..lInfo('');

      verify(() => logManager.lInfo('')).called(1);
    });
  });

  group('BaseLogMessageX', () {
    test('isWarningOrError returns true for warning and error levels', () {
      expect(
        const BaseLogMessageModel(
          message: 'Warning',
          logLevel: LogLevels.warning,
        ).isWarningOrError,
        isTrue,
      );
      expect(
        const BaseLogMessageModel(message: 'Error', logLevel: LogLevels.error)
            .isWarningOrError,
        isTrue,
      );
      expect(
        const BaseLogMessageModel(message: 'Fatal', logLevel: LogLevels.fatal)
            .isWarningOrError,
        isTrue,
      );
    });

    test('isWarningOrError returns false for info and debug levels', () {
      expect(
        const BaseLogMessageModel(message: 'Info', logLevel: LogLevels.info)
            .isWarningOrError,
        isFalse,
      );
      expect(
        const BaseLogMessageModel(message: 'Debug', logLevel: LogLevels.debug)
            .isWarningOrError,
        isFalse,
      );
    });
  });
}
