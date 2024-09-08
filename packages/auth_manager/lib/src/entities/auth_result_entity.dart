import 'package:flutter/foundation.dart';

import 'user_entity.dart';

/// Represents the result of an authentication operation.
@immutable
base class AuthResultEntity {
  /// Represents the result of an authentication operation.
  const AuthResultEntity({this.user, this.errorMessage});

  /// The user entity.
  final UserEntity? user;

  /// The error message.
  final String? errorMessage;
}
