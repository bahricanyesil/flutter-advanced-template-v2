import 'package:flutter/foundation.dart';

import 'package:network_manager/src/entities/token_entity.dart';
import 'package:network_manager/src/enums/token_types.dart';

/// A repository interface for managing tokens (e.g. access, refresh, etc.).
@immutable
abstract interface class TokenRepository {
  /// Gets the access token from the local database.
  Future<void> setToken(TokenEntity tokenEntity);

  /// Sets the access token to the local database.
  Future<TokenEntity?> getToken(TokenTypes tokenType);

  /// Deletes the access token from the local database.
  Future<void> deleteToken(TokenTypes tokenType);

  /// Refreshes the access token.
  Future<TokenEntity?> refreshAccessToken();

  /// Logs out the user.
  Future<void> logout({bool hasToken = true});
}
