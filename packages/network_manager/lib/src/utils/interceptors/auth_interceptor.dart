// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';

import 'package:connectivity_manager/connectivity_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

import '../../constants/network_constants.dart';
import '../../default_network_manager.dart';
import '../../entities/token_entity.dart';
import '../../enums/token_types.dart';
import '../../repositories/token_repository.dart';

/// This class represents an interceptor that handles authentication
/// for network requests. It extends the [QueuedInterceptor] class.
@immutable
final class AuthInterceptor extends QueuedInterceptor {
  /// Creates a new authentication interceptor with the specified
  AuthInterceptor({
    required TokenRepository tokenRepository,
    LogManager? logger,
  })  : _tokenRepository = tokenRepository,
        _logger = logger;

  /// The token repository to handle the tokens.
  final TokenRepository _tokenRepository;

  /// The logger to log the events.
  final LogManager? _logger;

  static const List<int> _retryableStatusCodes = <int>[
    HttpStatus.unauthorized,
    HttpStatus.requestTimeout,
    HttpStatus.internalServerError,
    HttpStatus.badGateway,
    HttpStatus.serviceUnavailable,
    HttpStatus.gatewayTimeout,
    HttpStatus.clientClosedRequest,
    HttpStatus.networkConnectTimeoutError,
  ];

  DioException _refreshException(RequestOptions options) => DioException(
        requestOptions: options,
        error: 'Token could not be refreshed. No valid auth token.',
        response: Response<Object?>(
          statusMessage: 'Session expired please login',
          statusCode: 401,
          requestOptions: options,
        ),
      );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool isAuth = _requiresAuth(options);
    if (!isAuth) {
      options.headers.remove(NetworkConstants.authHeader);
      return handler.next(options);
    }

    TokenEntity? accessToken =
        await _tokenRepository.getToken(TokenTypes.accessToken);
    if (accessToken?.isExpired ?? true) {
      accessToken = await _refreshToken();
    }

    if (accessToken == null) {
      return handler.reject(_refreshException(options));
    } else {
      _setAuthHeader(accessToken, options);
      return handler.next(options);
    }
  }

  static void _setAuthHeader(TokenEntity? accessToken, RequestOptions options) {
    if (accessToken == null) return;
    final String authHeader =
        '''${NetworkConstants.protectedTokenPrefix} ${accessToken.token}''';
    options.headers[HttpHeaders.authorizationHeader] = authHeader;
  }

  Future<TokenEntity?> _refreshToken() async {
    _logger?.lDebug('Token expired. Refreshing token...');
    final TokenEntity? accessToken =
        await _tokenRepository.refreshAccessToken();
    if (accessToken == null) {
      await _logout();
      _logger?.lInfo('Token refresh failed');
    } else {
      _logger?.lInfo('Token refreshed successfully, new token: $accessToken');
    }
    return accessToken;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions options = err.requestOptions;

    final bool isAuthRequest = _requiresAuth(options);
    if (options.headers[NetworkConstants.retryCount] == 1) {
      if (isAuthRequest) return _logout(handler: handler, err: err);
      return handler.reject(err);
    }

    if (!isAuthRequest || !_isAuthError(err.response)) {
      final int? code = err.response?.statusCode;
      final bool isRetryable =
          _retryableStatusCodes.contains(code) || code == null;
      if (isRetryable) {
        return _retryRequest(err, handler);
      } else {
        return handler.next(err);
      }
    }
    final TokenEntity? accessToken = await _refreshToken();
    if (accessToken == null) {
      await _logout();
      return handler.reject(err);
    } else {
      return _retryRequest(err, handler, accessToken: accessToken);
    }
  }

  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler, {
    TokenEntity? accessToken,
  }) async {
    final RequestOptions reqOptions = err.requestOptions;
    try {
      final Response<Object?> response = await sendRetryRequest(
        reqOptions,
        accessToken: accessToken,
        tokenRepository: _tokenRepository,
      );
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.reject(e);
    }
  }

  /// Sends a retry request with the specified [reqOptions] and [accessToken].
  static Future<Response<Object?>> sendRetryRequest(
    RequestOptions reqOptions, {
    required TokenRepository tokenRepository,
    LogManager? logManager,
    ConnectivityManager? connectivityManager,
    TokenEntity? accessToken,
  }) async {
    final Object? oldCount = reqOptions.headers[NetworkConstants.retryCount];
    reqOptions.headers[NetworkConstants.retryCount] =
        (oldCount is int ? oldCount : 0) + 1;
    accessToken ??= await tokenRepository.getToken(TokenTypes.accessToken);
    _setAuthHeader(accessToken, reqOptions);
    final Dio retryDio =
        Dio(DefaultNetworkManager.defaultBaseOptions(reqOptions.baseUrl));
    final List<Interceptor> interceptors =
        DefaultNetworkManager.defaultInterceptors(
      logManager,
      connectivityManager,
    );
    retryDio.interceptors.addAll(interceptors);
    try {
      final Response<Object?> response = await retryDio.fetch(reqOptions);
      return response;
    } on Exception {
      rethrow;
    }
  }

  bool _requiresAuth(RequestOptions options) {
    final bool doesRequire =
        options.headers[NetworkConstants.requiresAuth] == true;
    options.headers.remove(NetworkConstants.requiresAuth);
    return doesRequire;
  }

  bool _isAuthError(Response<Object?>? response) =>
      response?.statusCode == HttpStatus.unauthorized;

  Future<void> _logout({
    ErrorInterceptorHandler? handler,
    DioException? err,
  }) async {
    await _tokenRepository.logout(hasToken: false);
    _logger?.lDebug('User logged out, session expired');
    if (handler == null || err == null) return;
    return handler.reject(err);
  }
}
