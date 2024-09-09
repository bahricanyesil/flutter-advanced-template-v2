import 'package:dio/dio.dart' as dio;

import 'constants/network_constants.dart';
import 'enums/method_types.dart';
import 'models/index.dart';
import 'network_manager.dart';
import 'utils/extensions/interceptor_extensions.dart';
import 'utils/initializer/mobile_desktop_initializer.dart'
    if (dart.library.html) 'utils/initializer/web_initializer.dart';
import 'utils/network_manager_helpers.dart';
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
  NetworkManagerImpl({required NetworkManagerParamsModel params}) {
    options = params.baseOptions;
    transformer = CustomBackgroundTransformers();
    _addCustomInterceptors(params.interceptors);
    httpClientAdapter = NetworkManagerInitializer.httpClientAdapter;
  }

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
    try {
      requestOptions =
          _setRequestOptions(requestOptions, requiresAuth, methodType);
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
    } on Exception catch (err, stackTrace) {
      return UnknownError<R, E>(
        error: err,
        errorData: null,
        stackTrace: stackTrace,
      );
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
    try {
      requestOptions =
          _setRequestOptions(requestOptions, requiresAuth, methodType);
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
    } on Exception catch (err, stackTrace) {
      return UnknownError<R, E>(
        error: err,
        errorData: null,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<NetworkResponseModel<ListResponseModel<int>, E>>
      downloadFile<T extends DataModel<T>>(
    String path,
    ProgressCallback? callback, {
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
        onReceiveProgress: callback,
      );
      return parseList<int>(response);
    } on dio.DioException catch (err) {
      return parseError<ListResponseModel<int>>(err);
    } on Exception catch (err, stackTrace) {
      return UnknownError<ListResponseModel<int>, E>(
        error: err,
        errorData: null,
        stackTrace: stackTrace,
      );
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
  Future<NetworkResponseModel<R, E>> uploadFile<FormDataT, R>(
    String path,
    FormDataT data, {
    Map<String, dynamic>? headers,
  }) {
    // TODO(bahrican): implement uploadFile
    throw UnimplementedError();
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
    } on Exception catch (err, stackTrace) {
      return UnknownError<dio.Response<Object?>, E>(
        error: err,
        errorData: null,
        stackTrace: stackTrace,
      );
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
  bool addInterceptor(dio.Interceptor newInterceptor) =>
      interceptors.addIfNotExists(newInterceptor);

  @override
  bool insertInterceptor(int index, dio.Interceptor newInterceptor) =>
      interceptors.insertIfNotExists(index, newInterceptor);

  @override
  bool removeInterceptor(dio.Interceptor removedInterceptor) =>
      interceptors.removeIfExist(removedInterceptor);

  @override
  List<dio.Interceptor> get allInterceptors => interceptors;

  void _addCustomInterceptors(List<dio.Interceptor> interceptors) =>
      addAllInterceptors(interceptors);
}
