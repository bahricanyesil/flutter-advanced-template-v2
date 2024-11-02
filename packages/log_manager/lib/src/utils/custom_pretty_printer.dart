import 'dart:convert';

import 'package:log_manager/src/utils/custom_log_extensions.dart';
import 'package:log_manager/src/utils/date_time_log_extensions.dart';
import 'package:logger/logger.dart';

import '../enums/log_levels.dart';

/// A custom pretty printer for the logger package.
class CustomPrettyPrinter extends LogPrinter {
  /// Creates a new instance of [CustomPrettyPrinter].
  CustomPrettyPrinter({
    this.stackTraceBeginIndex = 0,
    this.methodCount = 2,
    this.errorMethodCount = 8,
    this.lineLength = 100,
    this.printColors = true,
    this.printEmojis = true,
    this.printTime = false,
    this.excludeBox = const <LogLevels, bool>{},
    this.noBoxingByDefault = false,
    this.excludePaths = const <String>[],
    this.onlyErrorStackTrace = false,
  }) {
    _startTime ??= DateTime.now();

    final StringBuffer doubleDividerLine = StringBuffer();
    final StringBuffer singleDividerLine = StringBuffer();
    for (int i = 0; i < lineLength - 1; i++) {
      doubleDividerLine.write(_doubleDivider);
      singleDividerLine.write(_singleDivider);
    }

    _topBorder = '$_topLeftCorner$doubleDividerLine';
    _middleBorder = '$_middleCorner$singleDividerLine';
    _bottomBorder = '$_bottomLeftCorner$doubleDividerLine';

    _includeBox = <LogLevels, bool>{};
    for (final LogLevels l in LogLevels.values) {
      _includeBox[l] = !noBoxingByDefault;
    }
    excludeBox.forEach((LogLevels k, bool v) => _includeBox[k] = !v);
  }

  /// Index of the first stack trace line to be included in the logs.
  final int stackTraceBeginIndex;

  /// Number of methods to be included in the stack trace.
  final int? methodCount;

  /// Number of methods to be included in the stack trace in case of an error.
  final int? errorMethodCount;

  /// The maximum length of a line.
  final int lineLength;

  /// Whether to print the log level in color.
  final bool printColors;

  /// Whether to print the log level emoji.
  final bool printEmojis;

  /// Whether to print the time of the log.
  final bool printTime;

  /// A map of log levels to whether to exclude the box.
  final Map<LogLevels, bool> excludeBox;

  /// Whether to exclude the box by default.
  final bool noBoxingByDefault;

  /// A list of paths to exclude from the stack trace.
  final List<String> excludePaths;

  DateTime? _startTime;

  String _topBorder = '';
  String _middleBorder = '';
  String _bottomBorder = '';

  static const String _topLeftCorner = '┌';
  static const String _bottomLeftCorner = '└';
  static const String _middleCorner = '├';
  static const String _verticalLine = '│';
  static const String _doubleDivider = '─';
  static const String _singleDivider = '┄';

  /// Matches a stacktrace line as generated on Android/iOS devices.
  final RegExp _deviceStackTraceRegex = RegExp(r'#[0-9]+\s+(.+) \((\S+)\)');

  /// Matches a stacktrace line as generated by Flutter web.
  final RegExp _webStackTraceRegex = RegExp(r'^((packages|dart-sdk)/\S+/)');

  /// Matches a stacktrace line as generated by browser Dart.
  final RegExp _browserStackTraceRegex =
      RegExp(r'^(?:package:)?(dart:\S+|\S+)');

  late final Map<LogLevels, bool> _includeBox;

  /// Whether to only print the stack trace in case of an error.
  final bool onlyErrorStackTrace;

  @override
  List<String> log(LogEvent event) {
    final String messageStr = _stringifyMessage(event.message);
    String? stackTraceStr;
    final StackTrace stackTrace = event.stackTrace ?? StackTrace.current;
    final int stackTraceMethodCount =
        event.error != null ? (errorMethodCount ?? 1) : (methodCount ?? 1);
    if (stackTraceMethodCount > 0) {
      stackTraceStr = _formatStackTrace(stackTrace, stackTraceMethodCount);
    }
    final String? errorStr =
        event.error != null ? _stringifyError(event.error) : null;
    final String? timeStr = printTime && _startTime != null
        ? event.time.sinceDate(_startTime!)
        : null;

    final bool hasError =
        event.error != null || event.level.value <= LogLevels.error.value;
    final bool showStackTrace = !onlyErrorStackTrace || hasError;
    return _formatAndPrint(
      event.level.logLevel,
      messageStr,
      timeStr,
      errorStr,
      showStackTrace ? stackTraceStr : null,
    );
  }

  String? _formatStackTrace(StackTrace? stackTrace, int? methodCount) {
    if (stackTrace == null || ((methodCount ?? 0) <= 0)) return null;
    final List<String> lines =
        stackTrace.toString().split('\n').where(_filterStackTrace).toList();
    final List<String> formatted = lines
        .skip(stackTraceBeginIndex)
        .take(methodCount!)
        .map((String line) => _mapFormattedLine(line, lines.indexOf(line)))
        .toList();
    return formatted.isEmpty ? null : formatted.join('\n');
  }

  String _mapFormattedLine(String line, int index) =>
      '#$index   ${line.replaceFirst(RegExp(r'#\d+\s+'), '')}';

  bool _filterStackTrace(String line) =>
      !_discardDeviceStacktraceLine(line) &&
      !_discardWebStacktraceLine(line) &&
      !_discardBrowserStacktraceLine(line) &&
      !_isInExcludePaths(line) &&
      line.isNotEmpty;

  bool _isInExcludePaths(String segment) =>
      excludePaths.any((String element) => segment.contains(element));

  bool _discardDeviceStacktraceLine(String line) {
    final Match? match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) return false;
    final String segment = match.group(2)!;
    return segment.contains('package:logger') || _isInExcludePaths(segment);
  }

  bool _discardWebStacktraceLine(String line) {
    final Match? match = _webStackTraceRegex.matchAsPrefix(line);
    if (match == null) return false;
    final String segment = match.group(1)!;
    return segment.contains('packages/logger') ||
        segment.contains('dart-sdk/lib') ||
        _isInExcludePaths(segment);
  }

  bool _discardBrowserStacktraceLine(String line) {
    final Match? match = _browserStackTraceRegex.matchAsPrefix(line);
    if (match == null) return false;
    final String segment = match.group(1)!;
    return segment.contains('package:logger') ||
        segment.contains('dart:') ||
        _isInExcludePaths(segment);
  }

  Object _toEncodableFallback(Object? object) => object.toString();

  String _stringifyMessage(Object? message) {
    if (message is Map || message is Iterable) {
      final JsonEncoder encoder =
          JsonEncoder.withIndent('  ', _toEncodableFallback);
      return encoder.convert(message);
    } else {
      return message.toString();
    }
  }

  String _stringifyError(Object? error) {
    if (error is Map || error is Iterable) {
      final JsonEncoder encoder =
          JsonEncoder.withIndent('  ', _toEncodableFallback);
      return encoder.convert(error);
    } else {
      return error.toString();
    }
  }

  AnsiColor _getLogLevelAnsiColor(LogLevels level) =>
      printColors ? level.color : const AnsiColor.none();

  String _getEmoji(LogLevels level) => printEmojis ? '${level.emoji} ' : '';

  List<String> _formatAndPrint(
    LogLevels level,
    String message,
    String? time,
    String? error,
    String? stacktrace,
  ) {
    final List<String> buffer = <String>[];
    final String verticalLineAtLogLevel =
        _includeBox[level]! ? '$_verticalLine ' : '';
    final AnsiColor color = _getLogLevelAnsiColor(level);
    if (_includeBox[level]!) buffer.add(color(_topBorder));

    void addLines(String? content) {
      if (content != null) {
        for (final String line in content.split('\n')) {
          buffer.add(color('$verticalLineAtLogLevel$line'));
        }
        if (_includeBox[level]!) {
          buffer.add(color(_middleBorder));
        }
      }
    }

    addLines(error);
    addLines(stacktrace);
    if (printTime) addLines(time);

    final String emoji = _getEmoji(level);
    final List<String> messageList =
        message.split('\n').where((String e) => e.isNotEmpty).toList();
    for (final String line in messageList) {
      buffer.add(color('$verticalLineAtLogLevel$emoji$line'));
    }
    if (_includeBox[level]!) buffer.add(color(_bottomBorder));
    return buffer;
  }
}
