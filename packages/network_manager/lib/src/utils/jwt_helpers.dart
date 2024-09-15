import 'dart:convert';

/// A helper class for JWT token operations.
abstract final class JwtHelpers {
  const JwtHelpers._();

  /// JWT token decoder.
  static Map<String, Object?>? decode(String token) {
    try {
      final List<String> splitToken = token.split('.');
      if (splitToken.length != 3) {
        throw const FormatException('Invalid token format for JWT.');
      }
      final String payloadBase64 = splitToken[1];
      final String normalizedPayload = base64.normalize(payloadBase64);
      final String payloadString =
          utf8.decode(base64.decode(normalizedPayload));
      final Object? decodedPayload = jsonDecode(payloadString);
      if (decodedPayload is Map<String, Object?>) {
        return decodedPayload;
      } else {
        throw const FormatException('Invalid token format for JWT.');
      }
    } catch (error) {
      return null;
    }
  }

  /// JWT token expiration date getter with default value.
  static DateTime expDateWDefault(String? token) {
    final DateTime? expirationDate = getExpirationDate(token);
    return expirationDate ?? DateTime.now().subtract(const Duration(days: 300));
  }

  /// JWT token expiration date getter.
  static DateTime? getExpirationDate(String? token) {
    if (token == null) return null;
    final Map<String, dynamic>? decodedToken = decode(token);
    final Object? expiration = decodedToken?['exp'];
    if (expiration is! int) return null;
    return DateTime.fromMillisecondsSinceEpoch(expiration * 1000);
  }

  /// JWT token expiration status checker.
  static bool isExpired(String token, {DateTime? expireDate}) {
    final DateTime? expirationDate = expireDate ?? getExpirationDate(token);
    if (expirationDate == null) return true;
    final DateTime compareDate =
        DateTime.now().subtract(const Duration(minutes: 1));
    return expirationDate.toUtc().isBefore(compareDate.toUtc());
  }
}
