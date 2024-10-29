// ignore_for_file: prefer-match-file-name

part of '../base_network_response_model.dart';

/// Represents an abstract class for network response errors.
///
/// This class provides a base structure for handling network response errors.
/// It contains an [Exception] object that represents the error occurred
/// during the network request.
@immutable
sealed class NetworkErrorModel<T, E> extends BaseNetworkResponseModel<T, E> {
  /// Constructor for network response errors.
  const NetworkErrorModel({
    required Exception super.error,
    required super.errorData,
    required this.message,
    required this.stackTrace,
    this.statusCode,
  });

  /// Status code of the network error.
  final int? statusCode;

  /// The error message that describes the network error.
  final String message;

  /// The stack trace of the network error.
  final StackTrace stackTrace;
}
