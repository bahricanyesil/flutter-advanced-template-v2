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

      // Verify that the message is formatted correctly
      //without colors and emojis
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
      // Adjust the test to check for the presence of stack trace lines
      // within the formatted output
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
      final String removedBorderOutput = formattedOutput.replaceAll('│ ', '');

      expect(removedBorderOutput, contains(encodedMessage));
    });

    test('should format JSON in message correctly', () {
      final Map<String, dynamic> message = <String, dynamic>{'key': 'value'};
      final LogEvent logEvent = LogEvent(
        Level.debug,
        message,
        error: Exception('test exception'),
        time: DateTime.now(),
      );

      final String outputRes = printer.log(logEvent).join('\n');
      final String formattedOutput = _stripAnsiCodes(outputRes);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');

      final String encodedMessage = encoder.convert(message);
      final StringBuffer expectedBuffer = StringBuffer();
      for (final String line in encodedMessage.split('\n')) {
        expectedBuffer.writeln('│ 🐛 $line');
      }

      expect(formattedOutput, contains(expectedBuffer.toString()));
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

      // Check if the formatted output contains or
      //excludes based on excludePaths
      expect(formatted1, isNot(contains('package:logger/src/logger.dart')));
      expect(formatted2, contains('other_package/src/logger.dart'));
    });

    test('should handle error formatting correctly', () {
      final LogEvent logEvent = LogEvent(
        Level.error,
        'test message',
        error: Exception('test exception'),
      );

      final List<String> output = printer.log(logEvent);

      // Check if the output includes the string representation of the error
      expect(output.join('\n'), contains('Exception: test exception'));
    });
    test('should format stack trace correctly, filtering web stack trace lines',
        () {
      // Create a log event with a sample stack trace
      final LogEvent logEvent = LogEvent(
        Level.error,
        'Test error message',
        stackTrace: StackTrace.fromString(
            'packages/another_package/another_file.dart:101\n'
            'package:log_manager/src/utils/custom_pretty_printer.dart:202\n'),
      );

      // Get the log output
      final List<String> logOutput = printer.log(logEvent);

      // Join lines for comparison
      final String formattedOutput = logOutput.join('\n');

      // Define discarded lines that should not be present in the output
      const String discardedLine1 = 'dart-sdk/lib/some_lib.dart:456';
      const String discardedLine2 =
          'packages/another_package/another_file.dart:101';

      // Assert that discarded lines are not present
      expect(formattedOutput, isNot(contains(discardedLine1)));
      expect(formattedOutput, isNot(contains(discardedLine2)));
    });

    test('should use _toEncodableFallback when encoding JSON', () {
      final dynamic message = <String, String Function()>{
        'key': () => 'value',
      }; // Use a non-serializable object to trigger fallback

      // Log a message to trigger _stringifyMessage
      final List<String> logOutput =
          printer.log(LogEvent(Level.debug, message));
      final String formattedOutput = logOutput.join('\n');
      const String expected = '''│ 🐛   "key": "Closure: () => String"''';

      expect(formattedOutput, contains(expected));
    });
  });

  group('DefaultPrettyPrinter', () {
    test('should inherit properties from CustomPrettyPrinter', () {
      final DefaultPrettyPrinter printer = DefaultPrettyPrinter();

      // DefaultPrettyPrinter should inherit the default values
      //from CustomPrettyPrinter
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
