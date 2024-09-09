// ignore_for_file: prefer-match-file-name

part of '../network_response_model.dart';

/// Represents a timeout exception that occurs during network operations.
///
/// This exception is thrown when a network operation exceeds
/// the specified timeout duration.
/// It is a subclass of [NetworkErrorModel] and provides additional
/// information about the error.
///
/// Example usage:
/// ```dart
/// try {
///   // Perform network operation
/// } catch (e) {
///   if (e is TimeOutException) {
///     // Handle timeout error
///   }
/// }
/// ```
@immutable
sealed class TimeOutException<R, E> extends NetworkErrorModel<R, E> {
  const TimeOutException({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Time out error',
        );
}

/// Represents an exception that occurs when a connection times out.
///
/// This exception is thrown when a network connection exceeds
/// the specified timeout duration
/// and the request cannot be completed within that time.
///
/// The [ConnectionTimeOutException] class extends the [TimeOutException]
/// class and provides
/// an optional [message] parameter to describe the connection error.
///
/// Example usage:
/// ```dart
/// try {
///   // Perform network request
/// } catch (e) {
///   if (e is ConnectionTimeOutException) {
///   }
/// }
/// ```
@immutable
final class ConnectionTimeOutException<R, E> extends TimeOutException<R, E> {
  /// Creates a new instance of [ConnectionTimeOutException].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const ConnectionTimeOutException({
    required super.error,
    required super.errorData,
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
final class SendTimeOutException<R, E> extends TimeOutException<R, E> {
  /// Creates a new instance of [SendTimeOutException].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const SendTimeOutException({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Send time out error',
        );
}

/// Represents an exception that occurs when a receive timeout error is
/// encountered during network communication.
///
/// This exception is a subclass of [TimeOutException] and provides additional
/// information about the error.
/// The [message] property can be used to retrieve the error message
/// associated with the exception.
@immutable
final class ReceiveTimeOutException<R, E> extends TimeOutException<R, E> {
  /// Creates a new instance of [ReceiveTimeOutException].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const ReceiveTimeOutException({
    required super.error,
    required super.errorData,
    super.message = 'Receive error',
  });
}

/// Represents an exception that occurs when a request is cancelled.
///
/// This exception is thrown when a network request is cancelled before
/// it can be completed.
/// It extends the [NetworkErrorModel] class and provides an optional [message]
/// parameter to describe the connection error.
@immutable
final class CancelledRequestException<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [CancelledRequestException].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const CancelledRequestException({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Cancelled request error',
        );
}

/// Represents an unknown exception that occurred during a network operation.
///
/// This exception is thrown when an unexpected error occurs
/// during a network request.
/// It extends the [NetworkErrorModel] class and provides an optional [message]
/// parameter to describe the connection error.
@immutable
final class UnknownException<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [UnknownException].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const UnknownException({
    required super.error,
    required super.errorData,
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
/// throw ConnectionErrorException<String>(error: '500',
///   message: 'Connection timed out');
/// ```
@immutable
final class ConnectionErrorException<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [ConnectionErrorException].
  ///
  /// The [message] parameter is an optional error message
  /// that describes the connection error.
  const ConnectionErrorException({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'Connection error',
        );
}

/// Represents an error that occurs when a bad response is received.
@immutable
final class NoConnectionException<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [NoConnectionException].
  const NoConnectionException({
    required super.error,
    required super.errorData,
    String? message,
  }) : super(
          message: message ?? 'No internet connection',
        );
}

/// Network parse error exception that occurs when parsing network data.
final class NetworkParseException<R, E> extends NetworkErrorModel<R, E> {
  /// Creates a new instance of [NetworkParseException].
  const NetworkParseException({
    required super.error,
    required this.expectedType,
    required this.value,
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
      '''UnsuccessfulParseException: Could not parse $value to type $expectedType.'\n$message''';
}
