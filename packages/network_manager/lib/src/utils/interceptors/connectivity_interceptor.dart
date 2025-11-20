import 'package:connectivity_manager/connectivity_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:network_manager/src/models/index.dart';

/// A custom interceptor that extends the [Interceptor] class.
@immutable
final class ConnectivityInterceptor extends Interceptor {
  /// Creates a [ConnectivityInterceptor] instance.
  const ConnectivityInterceptor({required this.connectivityManager});

  /// The connectivity manager used to check for network connection.
  final ConnectivityManager connectivityManager;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool hasConnection = await connectivityManager.hasConnection();
    if (!hasConnection) {
      return handler.reject(DioConnectionError(options));
    }
    return handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    return handler.next(err);
  }
}
