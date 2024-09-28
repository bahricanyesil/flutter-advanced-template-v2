import 'package:dio/dio.dart' as dio;
import 'package:network_manager/network_manager.init.dart';

import 'constants/network_constants.dart';
import 'enums/method_types.dart';
import 'models/index.dart';
import 'network_manager.dart';
import 'utils/adapter/io_adapter.dart'
    if (dart.library.html) 'utils/adapter/web_adapter.dart';
import 'utils/extensions/interceptor_extensions.dart';
import 'utils/helpers/network_manager_helpers.dart';
import 'utils/transformers/custom_background_transformers.dart';

/// A class that manages network requests using the Dio library.
///
/// This class implements the [NetworkManager] interface and provides
/// methods for sending network requests, downloading files, and uploading files
/// It also allows adding and removing headers, and provides access
/// to the list of interceptors used for request/response handling.
///
/// Example usage:
/// ```dart
/// final networkManagerImpl = NetworkManagerImpl(options: dio.BaseOptions(baseUrl: 'https://api.example.com'));
/// final response = await networkManagerImpl.send('/users', requestModel: UserRequestModel(name: 'John Doe'), methodType: MethodTypes.post);
/// ```
base class NetworkManagerImpl<E extends DataModel<E>>
    with dio.DioMixin, NetworkManagerHelpers<E>
    implements
        NetworkManager<E, dio.Options, dio.CancelToken, dio.Interceptor> {
  /// Constructor for the [NetworkManagerImpl] class.
  /// It takes a [NetworkManagerParamsModel] object as a parameter.
  NetworkManagerImpl({
    required NetworkManagerParamsModel params,
    dio.HttpClientAdapter? clientAdapter,
  }) {
    initializeMappers();
    options = params.baseOptions;
    transformer = CustomBackgroundTransformers();
    _addCustomInterceptors(params.interceptors);
    httpClientAdapter =
        clientAdapter ?? NetworkManagerAdapter.httpClientAdapter;
  }

  /// Sends a request to the specified path with the given body and method type.
  ///
  /// The [path] parameter is the path to send the request to.
  /// The [body] parameter is the body of the request.
  /// The [methodType] parameter is the method type of the request.
  /// The [urlSuffix] parameter is the suffix of the URL.
  /// The [queryParameters] parameter is the query parameters of the request.
  /// The [requestOptions] parameter is the request options.
  /// The [cacheExpiration] parameter is the cache expiration.
  /// The [onSendProgress] parameter is the on send progress.
  /// The [onReceiveProgress] parameter is the on receive progress.
  /// The [cancelToken] parameter is the cancel token.
  /// The [requiresAuth] parameter is the requires auth.
  ///
  /// Note: DioMixin always assures that the exception is a DioException.
  /// Even if the exception is not a DioException, it will be converted
  /// to a DioException. Therefore, the parseError method will always
  /// receive a DioException.
  @override
  Future<NetworkResponseModel<R, E>>
      sendRequest<T extends DataModel<T>, R extends DataModel<R>>(
    String path, {
    required T body,
    required MethodTypes methodType,
    String? urlSuffix,
    Map<String, dynamic>? queryParameters,
    dio.Options? requestOptions,
    Duration? cacheExpiration,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    dio.CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    requestOptions =
        _setRequestOptions(requestOptions, requiresAuth, methodType);
    try {
      final dio.Response<Object?> response = await request(
        _createUrl(path, urlSuffix),
        data: body.toJson(),
        options: requestOptions,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return parseSuccess<R>(response);
    } on dio.DioException catch (err) {
      return parseError<R>(err);
    }
  }

  String _createUrl(String path, String? urlSuffix) =>
      path + (urlSuffix == null ? '' : '/$urlSuffix');

  @override
  Future<NetworkResponseModel<R, E>> requestWithoutBody<R extends DataModel<R>>(
    String path, {
    required MethodTypes methodType,
    String? urlSuffix,
    Map<String, dynamic>? queryParameters,
    dio.Options? requestOptions,
    Duration? cacheExpiration,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    dio.CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    requestOptions =
        _setRequestOptions(requestOptions, requiresAuth, methodType);
    try {
      final dio.Response<Object?> response = await request(
        _createUrl(path, urlSuffix),
        options: requestOptions,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return parseSuccess<R>(response);
    } on dio.DioException catch (err) {
      return parseError<R>(err);
    }
  }

  @override
  Future<NetworkResponseModel<ListResponseModel<int>, E>>
      downloadFile<T extends DataModel<T>>(
    String path, {
    T? body,
    MethodTypes? method,
    dio.Options? requestOptions,
    Map<String, dynamic>? queryParameters,
    dio.CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  }) async {
    requestOptions = _setRequestOptions(
      requestOptions,
      requiresAuth,
      method,
      responseType: dio.ResponseType.bytes,
    );
    try {
      final dio.Response<List<int>> response = await request<List<int>>(
        path,
        data: body?.toJson(),
        options: requestOptions,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return parseList<int>(response);
    } on dio.DioException catch (err) {
      return parseError<ListResponseModel<int>>(err);
    }
  }

  dio.Options? _setRequestOptions(
    dio.Options? requestOptions,
    bool requiresAuth,
    MethodTypes? method, {
    dio.ResponseType responseType = dio.ResponseType.json,
  }) {
    final dio.Options newOptions = requestOptions ?? dio.Options();
    // ignore: cascade_invocations
    newOptions.headers = requestOptions?.headers ?? <String, dynamic>{};
    newOptions.headers?[NetworkConstants.requiresAuth] = requiresAuth;
    newOptions
      ..method = (method ?? MethodTypes.get).name
      ..responseType = responseType;
    return newOptions;
  }

  @override
  Future<NetworkResponseModel<R, E>>
      uploadFile<FormDataT, R extends DataModel<R>>(
    String path,
    FormDataT data, {
    dio.Options? requestOptions,
    ProgressCallback? onSendProgress,
    dio.CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    requestOptions =
        _setRequestOptions(requestOptions, requiresAuth, MethodTypes.post);
    try {
      final dio.Response<Object?> response = await post(
        path,
        data: data,
        options: requestOptions,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return parseSuccess<R>(response);
    } on dio.DioException catch (err) {
      return parseError<R>(err);
    }
  }

  /// Basic dio request method.
  Future<NetworkResponseModel<dio.Response<Object?>, E>> dioRequest(
    String path, {
    required MethodTypes methodType,
    Object? data,
    String? urlSuffix,
    Map<String, dynamic>? queryParameters,
    dio.Options? requestOptions,
    Duration? cacheExpiration,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    dio.CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    requestOptions =
        _setRequestOptions(requestOptions, requiresAuth, methodType);
    try {
      final dio.Response<Object?> response = await request<Object?>(
        _createUrl(path, urlSuffix),
        data: data,
        options: requestOptions,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return NetworkSuccessModel<dio.Response<Object?>, E>(data: response);
    } on dio.DioException catch (err) {
      return parseError<dio.Response<Object?>>(err);
    }
  }

  @override
  void addBaseHeader(MapEntry<String, String> entry) =>
      options.headers[entry.key] = entry.value;

  @override
  Map<String, dynamic> get allHeaders => options.headers;

  @override
  void removeHeader(String key) => options.headers.remove(key);

  @override
  void clearHeader() => options.headers.clear();

  @override
  void addAllInterceptors(List<dio.Interceptor> newInterceptorList) =>
      interceptors.addAllIfNotExists(newInterceptorList);

  @override
  bool insertInterceptor(dio.Interceptor newInterceptor, {int? index}) =>
      interceptors.insertIfNotExists(newInterceptor, index: index);

  @override
  bool removeInterceptor(dio.Interceptor removedInterceptor) =>
      interceptors.removeIfExist(removedInterceptor);

  @override
  List<dio.Interceptor> get allInterceptors => interceptors;

  void _addCustomInterceptors(List<dio.Interceptor> interceptors) =>
      addAllInterceptors(interceptors);
}
