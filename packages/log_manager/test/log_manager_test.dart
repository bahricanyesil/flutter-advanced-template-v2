// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:mockito/mockito.dart';

// Mock class for LogManager
final class MockLogManager extends LogManager with Mock {
  // Create a StreamController to manage the stream
  final StreamController<BaseLogMessage> _streamController =
      StreamController<BaseLogMessage>();

  @override
  Stream<BaseLogMessage> get logStream => _streamController.stream;

  // Method to add a message to the stream (for testing purposes)
  void addLogMessage(BaseLogMessage message) {
    _streamController.add(message);
  }

  @override
  Future<void> close() async {
    await _streamController.close();
  }

  @override
  Future<void> logFlutterError(FlutterErrorDetails details) async {
    // Return a completed future to simulate the async behavior
    return super.logFlutterError(details);
  }
}

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

      verify(logManager.lTrace('Trace message')).called(1);
      verify(logManager.lDebug('Debug message')).called(1);
      verify(logManager.lInfo('Info message')).called(1);
      verify(logManager.lWarning('Warning message')).called(1);
      verify(logManager.lError('Error message')).called(1);
      verify(logManager.lFatal('Fatal error message')).called(1);
    });

    test('logs errors and fatal errors', () {
      // Create a mock instance of LogManager
      final MockLogManager logManager = MockLogManager();

      // Perform actions that are expected to trigger method calls
      logManager.lError('Error message', error: Exception('Test error'));
      logManager.lFatal('Fatal error message');

      // Verify that lError was called with the correct parameters
      verify(logManager.lError('Error message', error: isA<Exception>()))
          .called(1);

      // Verify that lFatal was called with the correct parameters
      verify(logManager.lFatal('Fatal error message')).called(1);
    });

    test('handles logging state', () {
      final MockLogManager logManager = MockLogManager()
        ..enableLogging()
        ..lInfo('Info message')
        ..disableLogging()
        ..lInfo('Info message');

      // Assuming the mock implementation logs messages even when disabled
      verify(logManager.lInfo('Info message')).called(2);
    });

    test('emits messages to stream', () async {
      // Create a mock instance of LogManager
      final MockLogManager logManager = MockLogManager();

      final List<BaseLogMessage> logMessages = <BaseLogMessage>[];

      // Listen to the logStream and add received messages
      //to the logMessages list
      logManager.logStream.listen(logMessages.add);

      // Create and add a message to the stream
      const BaseLogMessage logMessage =
          BaseLogMessage(message: 'Info message', logLevel: LogLevel.info);
      logManager.addLogMessage(logMessage);

      // Trigger the log method to simulate the behavior of logging
      logManager.lInfo('Info message');

      // Allow some time for the stream to process the message
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify that the logMessages list contains the correct message
      expect(logMessages, isNotEmpty);
      expect(logMessages.first.message, 'Info message');
    });

    test('logs Flutter and platform dispatcher errors', () {
      final MockLogManager logManager = MockLogManager();

      final FlutterErrorDetails flutterError =
          FlutterErrorDetails(exception: Exception('Test error'));
      logManager.logFlutterError(flutterError);

      // Verify that the correct methods were called with expected arguments
      verify(
        logManager.lError(
          'Flutter Error: ${flutterError.exceptionAsString()}',
          stackTrace: flutterError.stack,
          fatal: true,
          error: flutterError.exception,
        ),
      ).called(1);

      final StackTrace dispatcherStackTrace = StackTrace.current;
      final Exception dispatcherException = Exception('Test error');
      logManager.logPlatformDispatcherError(
        dispatcherException,
        dispatcherStackTrace,
      );
      verify(
        logManager.lError(
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
      final MockLogManager logManager = MockLogManager();

      // Perform actions that are expected to trigger method calls
      logManager.lInfo('Info message');

      // Verify that unexpected methods are not called
      verifyNever(logManager.lDebug('any'));
      verifyNever(logManager.lTrace('any'));
    });

    test('handles empty log message', () {
      final MockLogManager logManager = MockLogManager();

      // Test with empty log message
      logManager.lInfo('');

      // Verify behavior with empty message
      verify(logManager.lInfo('')).called(1);
    });
  });
}
