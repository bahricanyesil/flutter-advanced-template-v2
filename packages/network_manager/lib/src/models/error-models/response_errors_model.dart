// ignore_for_file: prefer-match-file-name

part of '../network_response_model.dart';

/// Represents an error that occurs when a bad request is made to the server
///
/// This error is typically thrown when the server receives a request
/// that it cannot process due to invalid parameters or missing data.
/// The [message] property provides a descriptive
/// error message for the bad request.
///
/// Example usage:
/// ```dart
/// throw BadRequestError(message: 'Invalid request');
/// ```
@immutable
final class BadRequestError<T, E> extends NetworkErrorModel<T, E> {
  /// Creates a new instance of [BadRequestError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const BadRequestError({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Bad request error',
          statusCode: 400,
        );
}

/// Represents an error that occurs when a request is unauthorized.
///
/// This error is thrown when the server responds with a status
/// code of 401 (Unauthorized).
/// It extends the [NetworkErrorModel] class and provides
/// additional information about the error.
/// The [UnauthorizedError] class is generic, allowing you to specify
/// the type of data associated with the error.
///
/// Example usage:
/// ```dart
/// throw UnauthorizedError<String>(error: 'Invalid token');
/// ```
@immutable
final class UnauthorizedError<T, E> extends NetworkErrorModel<T, E> {
  /// Creates a new instance of [UnauthorizedError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const UnauthorizedError({
    required super.error,
    super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Unauthorized error, token is invalid',
          statusCode: 401,
        );
}

/// Represents a network error indicating that the requested
/// resource was not found.
///
/// This error occurs when the server returns a 404 status code.
/// The [message] parameter can be used to provide a custom error message.
/// The [statusCode] property is set to 404 by default.
@immutable
final class NotFoundError<T, E> extends NetworkErrorModel<T, E> {
  /// Creates a new instance of [NotFoundError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const NotFoundError({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Not found error',
          statusCode: 404,
        );
}

/// Represents a conflict error that occurs during network communication.
///
/// This error is thrown when there is a conflict between
/// the client and the server.
/// It extends the [NetworkErrorModel] class and provides additional
/// functionality specific to conflict errors.
///
/// The [ConflictError] class is generic, allowing you to specify the type
/// of data associated with the error.
/// The generic type parameter [T] represents the type of data associated with
/// the error.
///
/// Example usage:
/// ```dart
/// try {
///   // Perform network operation
/// } on ConflictError<Data> catch (e) {
///   // Handle conflict error
/// }
/// ```
@immutable
final class ConflictError<T, E> extends NetworkErrorModel<T, E> {
  /// Creates a new instance of [ConflictError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const ConflictError({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Conflict error error',
          statusCode: 409,
        );
}

/// Represents an error that occurs when there is a bad certificate error
/// during a network request.
///
/// This error is thrown when the server's SSL certificate is invalid or
/// cannot be trusted.
/// It extends the [NetworkErrorModel] class and provides
/// additional information about the error.
///
/// The [message] parameter is an optional error message that describes the
/// connection error.
/// If no message is provided, the default message "Bad certificate error"
/// is used.
///
/// The [statusCode] property is set to 495, indicating a bad certificate error.
@immutable
final class BadCertificateError<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [BadCertificateError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const BadCertificateError({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Bad certificate error',
          statusCode: 495,
        );
}

/// Represents a server error that occurred during a network request.
///
/// This error is thrown when the server returns a
/// status code of 500 (Internal Server Error).
/// The [message] parameter can be used to provide additional
/// information about the error.
///
/// Example usage:
/// ```dart
/// throw ServerError<String>(message: 'Failed to fetch data');
/// ```
@immutable
final class ServerError<T, E> extends NetworkErrorModel<T, E> {
  /// Creates a new instance of [ServerError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const ServerError({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Internal server error',
          statusCode: 500,
        );
}

/// Represents a generic bad request error in the network response.
///
/// This error is thrown when a bad request is encountered
/// in the network response.
/// It extends the [NetworkErrorModel] class and provides additional
/// information such as the error message and status code.
///
/// Example usage:
/// ```dart
/// try {
///   // Make a network request
/// } catch (e) {
///   if (e is GenericBadRequestError) {
///     // Handle the bad request error
///   }
/// }
/// ```
@immutable
final class GenericBadRequestError<T, E> extends NetworkErrorModel<T, E> {
  /// A custom error representing a generic bad request error.
  ///
  /// This error is thrown when a bad request is made to the server.
  /// It extends the [NetworkErrorModel] class and provide
  ///  a default error message.
  ///
  /// The [error] and [statusCode] parameters are required,
  /// while the [message] parameter is optional.
  /// If the [message] parameter is not provided, a default
  /// error message of 'Generic bad request error' is used.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// throw GenericBadRequestError(
  ///   error: 'Invalid request',
  ///   statusCode: 400,
  ///   message: 'The request made was invalid.',
  /// );
  /// ```
  const GenericBadRequestError({
    required super.error,
    required super.errorData,
    required super.statusCode,
    String? message,
  }) : super(
          message: message ?? 'Generic bad request error',
        );
}
