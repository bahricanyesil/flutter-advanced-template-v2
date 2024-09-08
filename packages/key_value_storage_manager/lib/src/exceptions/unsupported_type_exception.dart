import 'package:flutter/foundation.dart';

/// Exception thrown when a type is not supported.
@immutable
final class UnsupportedTypeException implements Exception {
  /// Constructor for UnsupportedTypeException.
  const UnsupportedTypeException({
    required this.supportedTypes,
    required this.type,
    this.customMessage,
  });

  /// The list of supported types.
  final List<Type> supportedTypes;

  /// The type that is not supported.
  final Type type;

  /// The custom message for the exception.
  final String? customMessage;

  @override
  String toString() =>
      """UnsupportedTypeException: Type $type is not supported. Supported types are $supportedTypes${customMessage == null ? '' : '\n$customMessage'}""";
}
