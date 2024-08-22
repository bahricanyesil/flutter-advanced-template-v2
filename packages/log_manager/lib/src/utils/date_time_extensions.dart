/// Extension on [DateTime] class to provide additional functionality.
extension DateTimeExtensions on DateTime {
  /// Returns a formatted string to indicate the time since the start time.
  String sinceDate(DateTime startTime) {
    final String h = _twoDigits(hour);
    final String min = _twoDigits(minute);
    final String sec = _twoDigits(second);
    final String ms = _threeDigits(millisecond);
    final String timeSinceStart = difference(startTime).toString();
    return '$h:$min:$sec.$ms (+$timeSinceStart)';
  }

  String _threeDigits(int n) {
    if (n >= 100) return '$n';
    if (n >= 10) return '0$n';
    return '00$n';
  }

  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';
}
