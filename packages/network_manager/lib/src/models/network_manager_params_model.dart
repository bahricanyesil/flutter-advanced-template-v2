import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// The [NetworkManagerParamsModel] class holds
/// the parameters for the NetworkManager
@immutable
final class NetworkManagerParamsModel {
  /// The [NetworkManagerParamsModel] constructor requires the [baseOptions] and
  const NetworkManagerParamsModel({
    required this.baseOptions,
    this.interceptors = const <Interceptor>[],
    this.enableLogger = false,
  });

  /// The [baseOptions] is used to configure the [Dio] instance.
  final BaseOptions baseOptions;

  /// The [interceptors] are used to intercept the request and response.
  final List<Interceptor> interceptors;

  /// The [enableLogger] is used to enable or disable the logger.
  final bool enableLogger;
}
