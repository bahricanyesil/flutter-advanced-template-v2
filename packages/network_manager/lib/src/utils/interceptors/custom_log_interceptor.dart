import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

/// CustomLogInterceptor is a custom interceptor that
/// logs the request and response details.
@immutable
final class CustomLogInterceptor extends Interceptor {
  /// CustomLogInterceptor constructor takes [LogManager] as a parameter.
  const CustomLogInterceptor(
    this._logger, {
    this.showTimeout = false,
    this.maxBodyLength = 400,
  });
  final LogManager _logger;

  /// Whether to show the timeout in the logs.
  final bool showTimeout;

  /// The maximum length of the response body to be logged.
  final int maxBodyLength;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String requestMessage =
        '*** Request ***\n${_formatRequestDetails(options)}';
    _logger.lDebug(requestMessage);
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) async {
    final String responseMessage =
        '*** Response ***\n${_formatResponseDetails(response)}';
    _logger.lDebug(responseMessage);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    String errorMessage =
        '*** DioError ***\nuri: ${err.requestOptions.formattedUri}\n$err';
    if (err.response != null) {
      errorMessage += _formatResponseDetails(err.response!);
    }
    _logger.lError(errorMessage);
    handler.next(err);
  }

  String _formatRequestDetails(RequestOptions options) {
    return '''
uri: ${options.formattedUri}
method: ${options.method}
${options.headers.isNotEmpty ? '\nheaders: ${options.headers}' : ''}
${(options.connectTimeout != null && showTimeout) ? '\nconnectTimeout: ${options.connectTimeout}' : ''}
${(options.sendTimeout != null && showTimeout) ? '\nsendTimeout: ${options.sendTimeout}' : ''}
${(options.receiveTimeout != null && showTimeout) ? '\nreceiveTimeout: ${options.receiveTimeout}' : ''}
${options.extra.isNotEmpty ? '\nextra: ${options.extra}' : ''}
${options.data != null ? '\ndata: ${options.data}' : ''}
''';
  }

  String _formatResponseDetails(Response<Object?> response) {
    return '''
uri: ${response.requestOptions.formattedUri}
statusCode: ${response.statusCode}
${response.isRedirect == true ? '\nredirect: ${response.realUri}' : ''}
${(maxBodyLength > 0) ? 'data: ${_formatJson(response.data)}' : ''}
''';
  }

  String _formatJson(Object? data) {
    try {
      final String jsonData = jsonEncode(data);
      final Object? decodedData = jsonDecode(jsonData);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(decodedData);

      if (jsonString.length > maxBodyLength) {
        jsonString = '${jsonString.substring(0, maxBodyLength)}...';
      }

      return jsonString;
    } catch (_) {
      return data.toString();
    }
  }
}

/// Custom extensions on [RequestOptions].
extension RequestOptExtensions on RequestOptions {
  /// Returns the formatted URI.
  String get formattedUri => Uri.decodeFull(uri.toString());
}
