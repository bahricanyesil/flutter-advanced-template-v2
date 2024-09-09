part of 'network_response_model.dart';

/// Represents a successful network response.
///
/// This class is used to encapsulate the data received
/// from a successful network request.
/// It extends the `NetworkResponse` class and provides
/// a constructor to initialize the data.
@immutable
final class NetworkSuccessModel<T, E> extends NetworkResponseModel<T, E> {
  /// Constructor for network response data.
  ///
  /// The `data` parameter is required and represents the data received
  /// from the network request.
  const NetworkSuccessModel({required T? data})
      : super(responseData: data, error: null, errorData: null);
}
