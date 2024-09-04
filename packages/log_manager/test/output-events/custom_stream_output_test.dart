import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';

void main() {
  group('CustomStreamOutput', () {
    late CustomStreamOutput customStreamOutput;
    late StreamSubscription<BaseLogMessageModel>? subscription;
    late List<BaseLogMessageModel> receivedMessages;

    setUp(() {
      customStreamOutput = CustomStreamOutput();
      receivedMessages = <BaseLogMessageModel>[];
      subscription = null; // Initialize subscription to null
    });

    tearDown(() async {
      // Cancel subscription if it was initialized
      await subscription?.cancel();
      // Destroy the custom stream output
      await customStreamOutput.destroy();
    });

    test('should emit log messages to stream', () async {
      // Arrange
      final BaseLogMessageModel logMessage = BaseLogMessageModel(
        logLevel: LogLevels.info,
        message: 'Test message',
        time: DateTime.now(),
      );

      // Initialize subscription
      subscription =
          customStreamOutput.stream.listen((BaseLogMessageModel message) {
        receivedMessages.add(message);
      });

      // Act
      customStreamOutput.output(logMessage);

      // Wait for the stream to process the event
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(receivedMessages, contains(logMessage));
    });

    test('should not emit log messages when paused', () async {
      // Arrange
      final BaseLogMessageModel logMessage = BaseLogMessageModel(
        logLevel: LogLevels.info,
        message: 'Test message',
        time: DateTime.now(),
      );

      // Initialize subscription
      subscription =
          customStreamOutput.stream.listen((BaseLogMessageModel message) {
        receivedMessages.add(message);
      });

      // Pause the stream
      subscription?.pause();

      // Act
      customStreamOutput.output(logMessage);

      // Wait for a short period
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(receivedMessages, isEmpty);

      // Resume the stream and send the message again
      subscription?.resume();
      customStreamOutput.output(logMessage);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(receivedMessages, contains(logMessage));
    });

    test('should close the stream when destroyed', () async {
      // Arrange
      subscription =
          customStreamOutput.stream.listen((BaseLogMessageModel message) {
        receivedMessages.add(message);
      });

      // Act
      await customStreamOutput.destroy();

      // Assert
      // Check if the controller is closed and no further events are emitted
      expect(
        () => customStreamOutput.output(
          BaseLogMessageModel(
            logLevel: LogLevels.info,
            message: 'Test message',
            time: DateTime.now(),
          ),
        ),
        throwsA(isA<StateError>()),
        reason: 'Output should throw error after destroy',
      );
    });
  });
}
