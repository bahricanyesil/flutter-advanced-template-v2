import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:logger/logger.dart';

void main() {
  group('LogLevel', () {
    test('should have correct enum values', () {
      expect(LogLevel.all.value, 1000);
      expect(LogLevel.trace.value, 600);
      expect(LogLevel.debug.value, 500);
      expect(LogLevel.info.value, 400);
      expect(LogLevel.warning.value, 300);
      expect(LogLevel.error.value, 200);
      expect(LogLevel.fatal.value, 100);
      expect(LogLevel.off.value, 0);
    });

    test('should compare log levels correctly', () {
      expect(LogLevel.all.compareTo(LogLevel.trace), greaterThan(0));
      expect(LogLevel.debug.compareTo(LogLevel.info), greaterThan(0));
      expect(LogLevel.warning.compareTo(LogLevel.error), greaterThan(0));
      expect(LogLevel.fatal.compareTo(LogLevel.off), greaterThan(0));
    });

    test('should have correct string representation', () {
      expect(
        LogLevel.all.toString(),
        'LogLevel(1000, 🔄, ${const AnsiColor.fg(0)})',
      );
      expect(
        LogLevel.trace.toString(),
        'LogLevel(600, 🔍, ${const AnsiColor.fg(4)})',
      );
      expect(
        LogLevel.debug.toString(),
        'LogLevel(500, 🐛, ${const AnsiColor.fg(244)})',
      );
      expect(
        LogLevel.info.toString(),
        'LogLevel(400, ℹ️, ${const AnsiColor.fg(2)})',
      );
      expect(
        LogLevel.warning.toString(),
        'LogLevel(300, ⚠️, ${const AnsiColor.fg(3)})',
      );
      expect(
        LogLevel.error.toString(),
        'LogLevel(200, ❌, ${const AnsiColor.fg(1)})',
      );
      expect(
        LogLevel.fatal.toString(),
        'LogLevel(100, 💣, ${const AnsiColor.fg(5)})',
      );
      expect(
        LogLevel.off.toString(),
        'LogLevel(0, 🚫, ${const AnsiColor.none()})',
      );
    });

    test('should have correct color representation', () {
      // Note: Adjust the expected values to match the actual output
      expect(LogLevel.all.color.toString(), const AnsiColor.fg(0).toString());
      expect(LogLevel.trace.color.toString(), const AnsiColor.fg(4).toString());
      expect(
        LogLevel.debug.color.toString(),
        const AnsiColor.fg(244).toString(),
      );
      expect(LogLevel.info.color.toString(), const AnsiColor.fg(2).toString());
      expect(
        LogLevel.warning.color.toString(),
        const AnsiColor.fg(3).toString(),
      );
      expect(LogLevel.error.color.toString(), const AnsiColor.fg(1).toString());
      expect(LogLevel.fatal.color.toString(), const AnsiColor.fg(5).toString());
      expect(LogLevel.off.color.toString(), const AnsiColor.none().toString());
    });
  });
}
