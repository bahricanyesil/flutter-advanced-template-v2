import 'package:connectivity_manager/connectivity_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

import '../../models/index.dart';

/// A custom interceptor that extends the [Interceptor] class.
@immutable
final class BaseInterceptor extends Interceptor {
  /// Creates a [BaseInterceptor] instance.
  const BaseInterceptor({
    required this.connectivityManager,
    required this.logManager,
  });

  /// The connectivity manager used to check for network connection.
  final ConnectivityManager connectivityManager;

  /// The logger manager used to log errors.
  final LogManager logManager;

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
