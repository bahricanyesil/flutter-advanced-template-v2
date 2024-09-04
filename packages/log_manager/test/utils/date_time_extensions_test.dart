import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/src/utils/date_time_log_extensions.dart';

void main() {
  group('DateTime Extensions', () {
    test('should return correct time since start', () {
      final DateTime startTime = DateTime(2024, 8, 23, 12);
      final DateTime endTime = DateTime(2024, 8, 23, 12, 1, 10, 250);

      final String result = endTime.sinceDate(startTime);

      expect(result, equals('12:01:10.250 (+0:01:10.250000)'));
    });

    test('should pad milliseconds with leading zeros', () {
      final DateTime startTime = DateTime(2024, 8, 23, 12);
      final DateTime endTime = DateTime(2024, 8, 23, 12, 0, 1, 5);

      final String result = endTime.sinceDate(startTime);

      expect(result, equals('12:00:01.005 (+0:00:01.005000)'));
    });

    test('should handle single-digit hours, minutes, and seconds', () {
      final DateTime startTime = DateTime(2024, 8, 23, 5, 4, 3);
      final DateTime endTime = DateTime(2024, 8, 23, 5, 5, 4, 123);

      final String result = endTime.sinceDate(startTime);

      expect(result, equals('05:05:04.123 (+0:01:01.123000)'));
    });
  });
}
