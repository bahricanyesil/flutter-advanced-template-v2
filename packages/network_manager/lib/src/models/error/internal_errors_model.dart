// ignore_for_file: prefer-match-file-name

part of '../network_response_model.dart';

/// Represents a timeout error that occurs during network operations.
///
/// This error is thrown when a network operation exceeds
/// the specified timeout duration.
/// It is a subclass of [NetworkErrorModel] and provides additional
/// information about the error.
///
/// Example usage:
/// ```dart
/// try {
///   // Perform network operation
/// } catch (e) {
///   if (e is TimeOutError) {
///     // Handle timeout error
///   }
/// }
/// ```
@immutable
sealed class TimeOutError<R, E> extends NetworkErrorModel<R, E> {
  const TimeOutError({
    required super.error,
    required super.errorData,
    required super.stackTrace,
    String? message,
  }) : super(
          message: message ?? 'Time out error',
        );
}

/// Represents an error that occurs when a connection times out.
///
/// This error is thrown when a network connection exceeds
/// the specified timeout duration
/// and the request cannot be completed within that time.
///
/// The [ConnectionTimeOutError] class extends the [TimeOutError]
/// class and provides
/// an optional [message] parameter to describe the connection error.
///
/// Example usage:
/// ```dart
/// try {
///   // Perform network request
/// } catch (e) {
///   if (e is ConnectionTimeOutError) {
///   }
/// }
/// ```
@immutable
final class ConnectionTimeOutError<R, E> extends TimeOutError<R, E> {
  /// Creates a new instance of [ConnectionTimeOutError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const ConnectionTimeOutError({
    required super.error,
    required super.errorData,
    required super.stackTrace,
    String? message,
  }) : super(
          message: message ?? 'Connection time out error',
        );
}

/// Represents a timeout error that occurs when sending a network request.
///
/// This error is thrown when the network request exceeds the specified
/// timeout duration.
/// The [message] parameter can be used to provide a custom error message that
/// describes the connection error.
@immutable
final class SendTimeOutError<R, E> extends TimeOutError<R, E> {
  /// Creates a new instance of [SendTimeOutError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const SendTimeOutError({
    required super.error,
    required super.errorData,
    required super.stackTrace,
    String? message,
  }) : super(
          message: message ?? 'Send time out error',
        );
}

/// Represents an error that occurs when a receive timeout error is
/// encountered during network communication.
///
/// This error is a subclass of [TimeOutError] and provides additional
/// information about the error.
/// The [message] property can be used to retrieve the error message
/// associated with the error.
@immutable
final class ReceiveTimeOutError<R, E> extends TimeOutError<R, E> {
  /// Creates a new instance of [ReceiveTimeOutError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const ReceiveTimeOutError({
    required super.error,
    required super.errorData,
    required super.stackTrace,
    super.message = 'Receive error',
  });
}

/// Represents an error that occurs when a request is cancelled.
///
/// This error is thrown when a network request is cancelled before
/// it can be completed.
/// It extends the [NetworkErrorModel] class and provides an optional [message]
/// parameter to describe the connection error.
@immutable
final class CancelledRequestError<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [CancelledRequestError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const CancelledRequestError({
    required super.error,
    required super.errorData,
    required super.stackTrace,
    String? message,
  }) : super(
          message: message ?? 'Cancelled request error',
        );
}

/// Represents an unknown error that occurred during a network operation.
///
/// This error is thrown when an unexpected error occurs
/// during a network request.
/// It extends the [NetworkErrorModel] class and provides an optional [message]
/// parameter to describe the connection error.
@immutable
final class UnknownError<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [UnknownError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const UnknownError({
    required super.error,
    required super.errorData,
    required super.stackTrace,
    String? message,
  }) : super(
          message: message ?? 'Unknown error',
        );
}

/// Represents an error that occurs when there is a connection issue.
///
/// This error is typically thrown when there is a problem establishing
/// or maintaining a network connection. It is a subclass of
/// [NetworkErrorModel] and provides additional functionality
/// specific to connection errors.
///
/// The [message] parameter is an optional error message
/// that describes the connection error.
///
/// Example usage:
/// ```dart
/// throw ConnectionError<String>(error: '500',
///   message: 'Connection timed out');
/// ```
@immutable
final class ConnectionError<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [ConnectionError].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const ConnectionError({
    required super.error,
    required super.errorData,
    required super.stackTrace,
    String? message,
  }) : super(
          message: message ?? 'Connection error',
        );
}

/// Represents an error that occurs when a bad response is received.
@immutable
final class NoConnectionError<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [NoConnectionError].
  const NoConnectionError({
    required super.error,
    required super.errorData,
    required super.stackTrace,
    String? message,
  }) : super(
          message: message ?? 'No internet connection',
        );
}

/// Network parse error that occurs when parsing network data.
final class NetworkParseError<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [NetworkParseError].
  const NetworkParseError({
    required super.error,
    required this.expectedType,
    required this.value,
    required super.stackTrace,
    super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Network parse error',
        );

  /// The expected type.
  final Type expectedType;

  /// The value that could not be parsed.
  final Object? value;

  @override
  String toString() =>
      '''UnsuccessfulParseError: Could not parse $value to type $expectedType.'\n$message''';
}
