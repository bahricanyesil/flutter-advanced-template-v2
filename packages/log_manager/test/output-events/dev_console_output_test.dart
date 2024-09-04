import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';

import '../mocks/mock_console_logger.dart';

void main() {
  group('DevConsoleOutput', () {
    test('should log messages using the provided CustomConsoleLogger', () {
      final MockConsoleLogger mockLogger = MockConsoleLogger();
      final DevConsoleOutput devConsoleOutput = DevConsoleOutput(mockLogger);
      const String testMessage = 'Test log message';

      final OutputEvent outputEvent = OutputEvent(
        LogEvent(Level.debug, testMessage),
        <String>[testMessage],
      );

      devConsoleOutput.output(outputEvent);

      expect(mockLogger.loggedMessages, contains(testMessage));
    });

    test('should handle multiple lines of log output', () {
      final MockConsoleLogger mockLogger = MockConsoleLogger();
      final DevConsoleOutput devConsoleOutput = DevConsoleOutput(mockLogger);

      const String testMessage = 'Test log message';
      final OutputEvent outputEvent = OutputEvent(
        LogEvent(Level.debug, testMessage),
        <String>['Line 1', 'Line 2', 'Line 3'],
      );

      devConsoleOutput.output(outputEvent);

      expect(mockLogger.loggedMessages, contains('Line 1\nLine 2\nLine 3'));
    });
  });
}
