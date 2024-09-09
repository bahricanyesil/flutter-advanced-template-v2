/// [NetworkConstants] contains the constants for the network manager.
abstract final class NetworkConstants {
  /// Basic authentication token prefix
  static const String basicAuthTokenPrefix = 'Basic';

  /// Protected authentication token prefix
  static const String protectedTokenPrefix = 'Bearer';

  /// Protected authentication header prefix for the API
  static const String authHeader = 'Authorization';

  /// The key for the header that requires authentication
  static const String requiresAuth = 'requires_auth';

  /// The key for the header that requires retry count
  static const String retryCount = 'retry_count';
}
