import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:logger/logger.dart';

void main() {
  group('LogEvent Extensions', () {
    test('should convert LogEvent to BaseLogMessage', () {
      final LogEvent logEvent = LogEvent(
        Level.off,
        'Test message',
        error: 'Test error',
        stackTrace: StackTrace.current,
        time: DateTime.now(),
      );

      final BaseLogMessage logMessage = logEvent.logMessage;

      expect(logMessage.logLevel, LogLevel.off);
      expect(logMessage.message, 'Test message');
      expect(logMessage.error, 'Test error');
      expect(logMessage.stackTrace, logEvent.stackTrace);
      expect(logMessage.time, logEvent.time);
    });
  });
}
