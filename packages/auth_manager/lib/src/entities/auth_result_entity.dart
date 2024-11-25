import 'package:flutter/foundation.dart';

import '../enum/auth_error_type.dart';
import 'user_entity.dart';

/// Represents the result of an authentication operation.
@immutable
base class AuthResultEntity {
  /// Represents the result of an authentication operation.
  const AuthResultEntity({this.user, this.errorMessage, this.errorType});

  /// The user entity.
  final UserEntity? user;

  /// The error message.
  final String? errorMessage;

  /// The error type.
  final AuthErrorType? errorType;

  /// Whether the result has an error.
  bool get hasError => errorMessage != null || errorType != null;
}
