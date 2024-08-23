import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:logger/logger.dart';

void main() {
  group('CustomPrettyPrinter', () {
    test('should initialize with default values', () {
      final CustomPrettyPrinter printer = CustomPrettyPrinter();

      expect(printer.stackTraceBeginIndex, 0);
      expect(printer.methodCount, 2);
      expect(printer.errorMethodCount, 8);
      expect(printer.lineLength, 100);
      expect(printer.printColors, true);
      expect(printer.printEmojis, true);
      expect(printer.printTime, false);
      expect(printer.excludeBox, <LogLevel, bool>{});
      expect(printer.noBoxingByDefault, false);
      expect(printer.excludePaths, <String>[]);
      expect(printer.onlyErrorStackTrace, false);
    });

    test('should format messages correctly', () {
      final CustomPrettyPrinter printer =
          CustomPrettyPrinter(printColors: false, printEmojis: false);
      final LogEvent logEvent = LogEvent(
        Level.debug,
        'Test message',
        time: DateTime.now(),
      );

      final String formatted = printer.log(logEvent).join('\n');

      // Verify that the message is formatted correctly without colors and emojis
      expect(formatted, contains('Test message'));
      expect(formatted, isNot(contains('🐛')));
    });

    test('should format stack traces correctly', () {
      final CustomPrettyPrinter printer =
          CustomPrettyPrinter(printColors: false);
      final StackTrace stackTrace = StackTrace.fromString('''
        #0main (package:my_app/main.dart:10:10)
        #1_startIsolate.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)
      ''');

      final LogEvent logEvent = LogEvent(
        Level.error,
        'Error occurred',
        stackTrace: stackTrace,
        time: DateTime.now(),
      );

      final String formatted = printer.log(logEvent).join('\n');
      // Adjust the test to check for the presence of stack trace lines within the formatted output
      expect(
        formatted,
        contains('#0main (package:my_app/main.dart:10:10)'),
      );
      expect(
        formatted,
        contains(
          '#1_startIsolate.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)',
        ),
      );
    });

    test('should handle log level colors and emojis correctly', () {
      final CustomPrettyPrinter printer = CustomPrettyPrinter();
      final LogEvent logEvent = LogEvent(
        Level.info,
        'Info message',
        time: DateTime.now(),
      );

      final String formatted = printer.log(logEvent).join('\n');
      final String cleanedFormatted = _stripAnsiCodes(formatted);

      // Verify that the log level emoji and color are included
      expect(cleanedFormatted, contains('│ ℹ️ Info message'));
    });
  });

  group('DefaultPrettyPrinter', () {
    test('should inherit properties from CustomPrettyPrinter', () {
      final DefaultPrettyPrinter printer = DefaultPrettyPrinter();

      // DefaultPrettyPrinter should inherit the default values from CustomPrettyPrinter
      expect(printer.printTime, false);
      expect(printer.onlyErrorStackTrace, true);
    });
  });
}

// Helper function to strip ANSI escape codes
String _stripAnsiCodes(String input) {
  final RegExp ansiEscapeCodePattern = RegExp(r'\x1B\[[0-9;]*m');
  return input.replaceAll(ansiEscapeCodePattern, '');
}
