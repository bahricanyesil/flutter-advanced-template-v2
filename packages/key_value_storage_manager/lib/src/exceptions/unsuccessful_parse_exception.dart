import 'package:flutter/foundation.dart';

/// Custom exception thrown when a parse operation is unsuccessful.
@immutable
final class UnsuccessfulParseException implements Exception {
  /// Constructor for UnsuccessfulParseException.
  const UnsuccessfulParseException({
    required this.expectedType,
    required this.value,
    this.customMessage,
  });

  /// The expected type.
  final Type expectedType;

  /// The value that could not be parsed.
  final Object? value;

  /// The custom message for the exception.
  final String? customMessage;

  @override
  String toString() =>
      '''UnsuccessfulParseException: Could not parse $value to type $expectedType.${customMessage == null ? '' : '\n$customMessage'}''';
}
