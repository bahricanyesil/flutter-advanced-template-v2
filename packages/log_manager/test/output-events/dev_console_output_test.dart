import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';

class MockConsoleLogger implements CustomConsoleLogger {
  final List<String> loggedMessages = <String>[];

  @override
  void log(String message) {
    loggedMessages.add(message);
  }
}

void main() {
  group('DevConsoleOutput', () {
    test('should log messages using the provided CustomConsoleLogger', () {
      // Arrange
      final MockConsoleLogger mockLogger = MockConsoleLogger();
      final DevConsoleOutput devConsoleOutput = DevConsoleOutput(mockLogger);
      const String testMessage = 'Test log message';

      final OutputEvent outputEvent = OutputEvent(
        LogEvent(Level.debug, testMessage),
        <String>[testMessage],
      );

      // Act
      devConsoleOutput.output(outputEvent);

      expect(mockLogger.loggedMessages, contains(testMessage));
    });

    test('should handle multiple lines of log output', () {
      // Arrange
      final MockConsoleLogger mockLogger = MockConsoleLogger();
      final DevConsoleOutput devConsoleOutput = DevConsoleOutput(mockLogger);

      const String testMessage = 'Test log message';
      final OutputEvent outputEvent = OutputEvent(
        LogEvent(Level.debug, testMessage),
        <String>['Line 1', 'Line 2', 'Line 3'],
      );

      // Act
      devConsoleOutput.output(outputEvent);

      // Assert
      expect(mockLogger.loggedMessages, contains('Line 1\nLine 2\nLine 3'));
    });
  });
}
