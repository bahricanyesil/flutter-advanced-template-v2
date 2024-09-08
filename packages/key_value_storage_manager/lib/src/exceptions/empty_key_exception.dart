import 'package:flutter/foundation.dart';

/// Custom exception thrown when a key is empty.
@immutable
final class EmptyKeyException implements Exception {
  /// Constructor for EmptyKeyException.
  const EmptyKeyException({this.message = 'Key cannot be empty.'});

  /// The message for the exception.
  final String message;

  @override
  String toString() => 'EmptyKeyException: $message';
}
