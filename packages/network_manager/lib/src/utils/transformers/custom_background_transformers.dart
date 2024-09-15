import 'package:dio/dio.dart';

/// A custom transformer that extends [BackgroundTransformer].
/// This transformer is used to handle request and response transformations.
final class CustomBackgroundTransformers extends BackgroundTransformer {
  /// Transforms the request options before sending them to the server.
  /// If the data in the request options is a Iterable<String>,
  /// it throws a DioException.
  /// Otherwise, it calls the super class's transformRequest method.
  /// Returns a Future<String> representing the transformed request.
  @override
  Future<String> transformRequest(RequestOptions options) async {
    if (options.data is Iterable<String>) {
      throw DioException(
        error: "Can't send List to sever directly",
        requestOptions: options,
      );
    } else {
      return super.transformRequest(options);
    }
  }

  /// Transforms the response by adding a custom background transformer.
  ///
  /// This method is called during the network request/response process to transform the response.
  /// It adds a custom background transformer to the request options.
  ///
  /// The [options] parameter represents the request options.
  /// The [responseBody] parameter represents the response body.
  ///
  /// Returns a [Future] that resolves to the transformed response.
  @override
  Future<Object?> transformResponse(
    RequestOptions options,
    ResponseBody responseBody,
  ) async {
    options.extra['self'] = 'XX';
    return super.transformResponse(options, responseBody);
  }
}
