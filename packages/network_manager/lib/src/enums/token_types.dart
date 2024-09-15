import 'package:dart_mappable/dart_mappable.dart';

part 'token_types.mapper.dart';

/// Enum for token type.
@MappableEnum()
enum TokenTypes {
  /// Access token.
  accessToken('accessToken'),

  /// Refresh token.
  refreshToken('refreshToken'),

  /// Confirmation token for email.
  confirmToken('confirmToken');

  const TokenTypes(this.jsonKey);

  /// The JSON key for the token type.
  final String jsonKey;

  /// Returns whether the token type is refresh token.
  bool get isRefresh => this == refreshToken;
}
