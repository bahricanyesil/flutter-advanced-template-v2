import 'package:flutter/foundation.dart';

/// Custom exception thrown when a type mismatch is detected.
@immutable
final class MismatchedTypeException implements Exception {
  /// Constructor for MismatchedTypeException.
  const MismatchedTypeException({
    required this.expectedType,
    required this.actualType,
  });

  /// The expected type.
  final Type expectedType;

  /// The actual type.
  final Type actualType;

  @override
  String toString() =>
      '''MismatchedTypeException: Expected type $expectedType, but found $actualType.''';
}
