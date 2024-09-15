import 'package:flutter/foundation.dart';

part 'error/internal_errors_model.dart';
part 'error/network_errors_model.dart';
part 'error/response_errors_model.dart';
part 'network_success_model.dart';

/// Represents a generic network response.
///
/// This abstract class provides a blueprint for network responses.
/// It contains a generic type `T` to represent the response responseData.
/// The `responseData` property holds the response responseData of type `T`.
/// The `error` property holds any error occurred during the network request.
@immutable
sealed class NetworkResponseModel<R, E> {
  /// Constructor for network response.
  const NetworkResponseModel({
    this.responseData,
    this.error,
    this.errorData,
  });

  /// The response responseData.
  final R? responseData;

  /// Any error that occurred during the network request.
  final Exception? error;

  /// Error responseData returned from the network request.
  final E? errorData;

  /// Returns true if the network response has an error, false otherwise.
  bool hasError({bool requiresData = true}) =>
      error != null || (requiresData && responseData == null);
}
