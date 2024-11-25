/// Enum representing different types of authentication errors
enum AuthErrorType {
  /// User cancelled the sign-in process
  userCancelled,

  /// Invalid credentials provided
  invalidCredentials,

  /// Network error occurred
  networkError,

  /// Token retrieval failed
  tokenError,

  /// User not found
  userNotFound,

  /// Email already in use
  emailAlreadyInUse,

  /// Invalid email format
  invalidEmail,

  /// Weak password
  weakPassword,

  /// Operation not allowed
  operationNotAllowed,

  /// Too many requests
  tooManyRequests,

  /// Unknown error
  unknown,
}
