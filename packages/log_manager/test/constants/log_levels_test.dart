import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';

void main() {
  group('LogLevels', () {
    test('should have correct enum values', () {
      expect(LogLevels.all.value, 1000);
      expect(LogLevels.trace.value, 600);
      expect(LogLevels.debug.value, 500);
      expect(LogLevels.info.value, 400);
      expect(LogLevels.warning.value, 300);
      expect(LogLevels.error.value, 200);
      expect(LogLevels.fatal.value, 100);
      expect(LogLevels.off.value, 0);
    });

    test('should compare log levels correctly', () {
      expect(LogLevels.all.compareTo(LogLevels.trace), greaterThan(0));
      expect(LogLevels.debug.compareTo(LogLevels.info), greaterThan(0));
      expect(LogLevels.warning.compareTo(LogLevels.error), greaterThan(0));
      expect(LogLevels.fatal.compareTo(LogLevels.off), greaterThan(0));
    });

    test('should have correct string representation', () {
      expect(
        LogLevels.all.toString(),
        'LogLevels(1000, 🔄, ${const AnsiColor.fg(0)})',
      );
      expect(
        LogLevels.trace.toString(),
        'LogLevels(600, 🔍, ${const AnsiColor.fg(4)})',
      );
      expect(
        LogLevels.debug.toString(),
        'LogLevels(500, 🐛, ${const AnsiColor.fg(244)})',
      );
      expect(
        LogLevels.info.toString(),
        'LogLevels(400, ℹ️, ${const AnsiColor.fg(2)})',
      );
      expect(
        LogLevels.warning.toString(),
        'LogLevels(300, ⚠️, ${const AnsiColor.fg(3)})',
      );
      expect(
        LogLevels.error.toString(),
        'LogLevels(200, ❌, ${const AnsiColor.fg(1)})',
      );
      expect(
        LogLevels.fatal.toString(),
        'LogLevels(100, 💣, ${const AnsiColor.fg(5)})',
      );
      expect(
        LogLevels.off.toString(),
        'LogLevels(0, 🚫, ${const AnsiColor.none()})',
      );
    });

    test('should have correct color representation', () {
      // Note: Adjust the expected values to match the actual output
      expect(LogLevels.all.color.toString(), const AnsiColor.fg(0).toString());
      expect(
        LogLevels.trace.color.toString(),
        const AnsiColor.fg(4).toString(),
      );
      expect(
        LogLevels.debug.color.toString(),
        const AnsiColor.fg(244).toString(),
      );
      expect(LogLevels.info.color.toString(), const AnsiColor.fg(2).toString());
      expect(
        LogLevels.warning.color.toString(),
        const AnsiColor.fg(3).toString(),
      );
      expect(
        LogLevels.error.color.toString(),
        const AnsiColor.fg(1).toString(),
      );
      expect(
        LogLevels.fatal.color.toString(),
        const AnsiColor.fg(5).toString(),
      );
      expect(LogLevels.off.color.toString(), const AnsiColor.none().toString());
    });
  });
}
