import 'package:connectivity_manager/connectivity_manager.dart';
import 'package:dio/dio.dart' as dio;
import 'package:log_manager/log_manager.dart';
import 'package:network_manager/network_manager.dart';

/// This class represents a manager for token network operations.
/// It extends the [NetworkManager] class and handles
/// network requests related to tokens.
///
/// The [TokenNetworkManager] class is responsible for managing the network
/// configuration, including the base URL, content type, and timeouts. It also
/// adds custom interceptors for logging and handling connectivity issues.
///
/// This class is marked as `@visibleForTesting` to allow access for testing
/// purposes. It is also annotated with `@LazySingleton` to ensure a single
/// instance is used throughout the application.
final class TokenNetworkManager extends NetworkManagerImpl<DefaultErrorModel> {
  /// Constructor for the [TokenNetworkManager] class.
  TokenNetworkManager(
    String baseUrl, {
    LogManager? logManager,
    ConnectivityManager? connectivityManager,
  }) : super(
          params: NetworkManagerParamsModel(
            baseOptions: dio.BaseOptions(
              baseUrl: baseUrl,
              contentType: dio.Headers.jsonContentType,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
            ),
            interceptors: <dio.Interceptor>[
              if (connectivityManager != null)
                ConnectivityInterceptor(
                  connectivityManager: connectivityManager,
                ),
              if (logManager != null) CustomLogInterceptor(logManager),
            ],
            enableLogger: true,
          ),
        );
}
