import 'package:dio/dio.dart';

/// An error thrown when a Dio connection error occurs.
class DioConnectionError extends DioException {
  /// Creates a [DioConnectionError] instance.
  DioConnectionError(RequestOptions options)
      : super(
          requestOptions: options,
          response: Response<Object?>(
            requestOptions: options,
            statusCode: 503,
            statusMessage: 'No internet connection',
          ),
        );

  @override
  String toString() => 'DioConnectionError: $message';
}
