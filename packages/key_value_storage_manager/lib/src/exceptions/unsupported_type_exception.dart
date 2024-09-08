import 'package:flutter/foundation.dart';

/// Exception thrown when a type is not supported.
@immutable
final class UnsupportedTypeException implements Exception {
  /// Constructor for UnsupportedTypeException.
  const UnsupportedTypeException({
    required this.supportedTypes,
    this.customMessage,
  });

  /// The list of supported types.
  final List<Type> supportedTypes;

  /// The custom message for the exception.
  final String? customMessage;

  @override
  String toString() =>
      """UnsupportedTypeException: Supported types are $supportedTypes\n${customMessage ?? ''}""";
}
