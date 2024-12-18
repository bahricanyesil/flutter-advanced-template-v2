import 'package:flutter/foundation.dart';

import 'generic/default_error_model.dart';

part 'base_network_success_model.dart';
part 'error/internal_errors_model.dart';
part 'error/network_errors_model.dart';
part 'error/response_errors_model.dart';

/// Represents a generic network response.
///
/// This abstract class provides a blueprint for network responses.
/// It contains a generic type `T` to represent the response responseData.
/// The `responseData` property holds the response responseData of type `T`.
/// The `error` property holds any error occurred during the network request.
@immutable
class BaseNetworkResponseModel<R, E> {
  /// Constructor for network response.
  const BaseNetworkResponseModel({
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

  /// Returns the error message from the error data or the error itself.
  String? get errorMessage {
    if (errorData is DefaultErrorModel) {
      return (errorData! as DefaultErrorModel).message ?? error?.toString();
    }
    return error?.toString();
  }
}
