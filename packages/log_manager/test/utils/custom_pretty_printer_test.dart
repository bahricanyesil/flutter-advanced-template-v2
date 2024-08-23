import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:log_manager/src/utils/date_time_extensions.dart';
import 'package:logger/logger.dart';

void main() {
  group('CustomPrettyPrinter', () {
    late DateTime startTime;
    late CustomPrettyPrinter printer;

    setUp(() {
      startTime = DateTime.now();
      printer = CustomPrettyPrinter(printTime: true);
    });

    test('should initialize with default values', () {
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

    test('should format time since start correctly', () {
      final DateTime eventTime = DateTime.now();
      final LogEvent logEvent = LogEvent(
        Level.debug,
        'Test message',
        time: eventTime,
      );

      final String formatted = printer.log(logEvent).join('\n');
      final String sinceDateString = eventTime.sinceDate(startTime);
      final String ignoreEnd =
          sinceDateString.substring(0, sinceDateString.lastIndexOf('.'));

      // Adjust the test to check the presence of the formatted time since start
      expect(formatted, contains(ignoreEnd));
    });

    test('should format JSON correctly', () {
      final Map<String, dynamic> message = <String, dynamic>{'key': 'value'};
      final LogEvent logEvent = LogEvent(
        Level.debug,
        'Test JSON message',
        error: message,
        time: DateTime.now(),
      );

      final String outputRes = printer.log(logEvent).join('\n');
      final String formattedOutput = _stripAnsiCodes(outputRes);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');

      final String encodedMessage = encoder.convert(message);
      final String expected = encodedMessage;
      final String removedBorderOutput = formattedOutput.replaceAll('│ ', '');

      expect(removedBorderOutput, contains(expected));
    });

    test('should exclude paths based on excludePaths', () {
      final List<String> excludePaths = <String>[
        'package:logger/src/logger.dart',
        'dart-sdk/lib/core.dart',
      ];
      printer = CustomPrettyPrinter(excludePaths: excludePaths);

      final LogEvent logEvent1 = LogEvent(
        Level.debug,
        'Test message',
        stackTrace: StackTrace.fromString('''
          #0package:logger/src/logger.dart:10:10
        '''),
        time: DateTime.now(),
      );

      final LogEvent logEvent2 = LogEvent(
        Level.debug,
        'Test message',
        stackTrace: StackTrace.fromString('''
          #0other_package/src/logger.dart:10:10
        '''),
        time: DateTime.now(),
      );

      final String formatted1 = printer.log(logEvent1).join('\n');
      final String formatted2 = printer.log(logEvent2).join('\n');

      // Check if the formatted output contains or excludes based on excludePaths
      expect(formatted1, isNot(contains('package:logger/src/logger.dart')));
      expect(formatted2, contains('other_package/src/logger.dart'));
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
String _stripAnsiCodes(String text) {
  final RegExp ansiEscapeCode = RegExp(r'\x1B\[[0-9;]*m');
  return text.replaceAll(ansiEscapeCode, '');
}
