import 'package:flutter/foundation.dart';

import 'package:network_manager/src/enums/token_types.dart';
import 'package:network_manager/src/utils/helpers/jwt_helpers.dart';

/// Represents a token entity contains the token with their expiration date.
@immutable
base class TokenEntity {
  /// Creates a token entity.
  const TokenEntity({
    required this.token,
    required this.expires,
    required this.type,
  });

  /// Token value for accessing the API.
  final String token;

  /// The date and time when the access token expires.
  final DateTime expires;

  /// The type of the token.
  final TokenTypes type;

  /// Returns true if the token is expired.
  bool get isExpired => JwtHelpers.isExpired(token, expireDate: expires);
}
