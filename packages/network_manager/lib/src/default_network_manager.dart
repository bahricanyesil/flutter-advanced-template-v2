// ignore_for_file: unused_element

import 'package:connectivity_manager/connectivity_manager.dart';
import 'package:dio/dio.dart' as dio;
import 'package:log_manager/log_manager.dart';
import 'package:network_manager/network_manager.dart';

/// A type definition for the base network manager class.
typedef INetworkManager = NetworkManager<DefaultErrorModel, dio.Options,
    dio.CancelToken, dio.Interceptor>;

/// The default network manager implementation.
/// This class extends the [NetworkManager] class and provides a concrete
/// implementation for handling network requests.
/// It is registered as a lazy singleton instance of the
/// [INetworkManager] interface.
final class DefaultNetworkManager
    extends NetworkManagerImpl<DefaultErrorModel> {
  /// Constructor for the [DefaultNetworkManager] class.
  DefaultNetworkManager(
    String baseUrl, {
    LogManager? logManager,
    ConnectivityManager? connectivityManager,
  }) : super(
          params: NetworkManagerParamsModel(
            baseOptions: defaultBaseOptions(baseUrl),
            interceptors: defaultInterceptors(logManager, connectivityManager),
            enableLogger: true,
          ),
        );

  /// Returns the default base options for the network manager.
  static dio.BaseOptions defaultBaseOptions(String baseUrl) => dio.BaseOptions(
        baseUrl: baseUrl,
        contentType: dio.Headers.jsonContentType,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      );

  /// Returns the default list of interceptors for the network manager.
  static List<dio.Interceptor> defaultInterceptors(
    LogManager? logManager,
    ConnectivityManager? connectivityManager,
  ) =>
      <dio.Interceptor>[
        if (connectivityManager != null)
          ConnectivityInterceptor(connectivityManager: connectivityManager),
        if (logManager != null) CustomLogInterceptor(logManager),
      ];
}
