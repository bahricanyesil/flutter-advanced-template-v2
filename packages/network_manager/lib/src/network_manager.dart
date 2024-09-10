import 'enums/method_types.dart';
import 'models/index.dart';

/// A typedef representing a progress callback function.
///
/// The [ProgressCallback] function takes two parameters: [count] and [total].
/// It is used to track the progress of a network operation, where [count]
/// represents the current progress and [total] represents the total progress.
typedef ProgressCallback = void Function(int count, int total);

/// The interface for a network manager.
///
/// This interface defines the contract for a network manager that
/// handles network requests and responses.
/// It provides methods for sending network requests, managing cache,
/// downloading files, uploading files,
/// adding and removing headers, and more.
///
/// Implementations of this interface should provide concrete
/// implementations for each method.
abstract interface class NetworkManager<E, OptionsT, CancelTokenT,
    InterceptorT> {
  /// Sends a network request and returns the response.
  ///
  /// The [path] parameter specifies the endpoint path for the request.
  /// The [methodType] parameter specifies the HTTP method type for the request.
  /// The [urlSuffix] parameter is an optional suffix to be appended to the URL.
  /// The [queryParameters] parameter is a map of query parameters
  /// to be included in the request.
  /// The [requestOptions] parameter is an optional object that provides
  /// additional options for the request.
  /// The [cacheExpiration] parameter specifies the duration for which
  /// the response should be cached.
  /// The [onReceiveProgress] parameter is a callback function that
  /// is called when progress is received.
  /// The [cancelToken] parameter is an optional token that
  /// can be used to cancel the request.
  ///
  /// Returns a [Future] that resolves to an [NetworkResponseModel]
  /// object containing the response data.
  Future<NetworkResponseModel<R, E>>
      sendRequest<T extends DataModel<T>, R extends DataModel<R>>(
    String path, {
    required T body,
    required MethodTypes methodType,
    String? urlSuffix,
    Map<String, dynamic>? queryParameters,
    OptionsT? requestOptions,
    Duration? cacheExpiration,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelTokenT? cancelToken,
    bool requiresAuth = true,
  });

  /// Sends a network request without a request body.
  ///
  /// The [path] parameter specifies the path of the API endpoint.
  /// The [methodType] parameter specifies the HTTP method type of the request.
  /// The [urlSuffix] parameter specifies an optional suffix to be appended
  /// to the URL.
  /// The [queryParameters] parameter specifies optional query parameters
  /// to be included in the request.
  /// The [requestOptions] parameter specifies optional request options.
  /// The [cacheExpiration] parameter specifies the duration for which
  /// the response should be cached.
  /// The [onReceiveProgress] parameter specifies a callback
  /// for receiving progress updates.
  /// The [cancelToken] parameter specifies a token for canceling the request.
  ///
  /// Returns a [Future] that resolves to an [NetworkResponseModel]
  /// containing the response data. The type parameter [R] specifies the type
  /// of the response data, which should implement [DataModel].
  Future<NetworkResponseModel<R, E>> requestWithoutBody<R extends DataModel<R>>(
    String path, {
    required MethodTypes methodType,
    String? urlSuffix,
    Map<String, dynamic>? queryParameters,
    OptionsT? requestOptions,
    Duration? cacheExpiration,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelTokenT? cancelToken,
    bool requiresAuth = true,
  });

  /// Downloads a file from the specified path with additional options.
  ///
  /// The [path] parameter specifies the path of the file to download.
  /// The [callback] parameter is an optional callback function
  /// that is called when progress is received.
  /// The [method] parameter specifies the HTTP method type for the request.
  /// The [requestOptions] parameter provides additional options for the request
  /// The [body] parameter is the request payload data.
  ///
  /// Returns a [Future] that resolves to a [NetworkResponseModel]
  /// object containing the downloaded file data.
  Future<NetworkResponseModel<ListResponseModel<int>, E>>
      downloadFile<T extends DataModel<T>>(
    String path,
    ProgressCallback? callback, {
    T? body,
    MethodTypes? method,
    OptionsT? requestOptions,
    Map<String, dynamic>? queryParameters,
    CancelTokenT? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
  });

  /// Uploads a file to the specified path.
  ///
  /// The [path] parameter specifies the path to upload the file.
  /// The [data] parameter is the [FormDataT]
  /// The [requestOptions] parameter is the [OptionsT]
  /// The [onSendProgress] parameter is the [ProgressCallback]
  /// The [cancelToken] parameter is the [CancelTokenT]
  /// The [requiresAuth] parameter is the [bool]
  Future<NetworkResponseModel<R, E>>
      uploadFile<FormDataT, R extends DataModel<R>>(
    String path,
    FormDataT data, {
    OptionsT? requestOptions,
    ProgressCallback? onSendProgress,
    CancelTokenT? cancelToken,
    bool requiresAuth = true,
  });

  /// Adds a base header to be included in all requests.
  ///
  /// The [entry] parameter is the header key-value pair to be added.
  void addBaseHeader(MapEntry<String, String> entry);

  /// Gets all the headers currently set.
  ///
  /// Returns a map of all the headers.
  Map<String, dynamic> get allHeaders;

  /// Removes a header with the specified key.
  ///
  /// The [key] parameter is the key of the header to be removed.
  void removeHeader(String key);

  /// Clears all the headers.
  void clearHeader();

  /// Adds a list of interceptors to the network manager.
  ///
  /// The [newInterceptorList] parameter is a list of objects that implement
  /// the [InterceptorT] interface.
  /// Interceptors can be used to intercept and modify network requests
  /// and responses.
  /// They are executed in the order they are added.
  /// Adds a list of interceptors to the network manager.
  void addAllInterceptors(List<InterceptorT> newInterceptorList);

  /// Adds an interceptor to the network manager.
  ///
  /// The [newInterceptor] parameter is of type [InterceptorT]
  /// and represents the interceptor to be added.
  bool addInterceptor(InterceptorT newInterceptor);

  /// Inserts an interceptor at the specified index.
  /// The [index] parameter is the index at which to insert the interceptor.
  /// The [newInterceptor] parameter is the interceptor to be inserted.
  /// Returns `true` if the interceptor was successfully inserted,
  /// `false` otherwise.
  /// If the index is out of bounds, the interceptor is not inserted.
  /// If the interceptor already exists, it is not inserted.
  /// If the interceptor is successfully inserted, returns `true`.
  bool insertInterceptor(int index, InterceptorT newInterceptor);

  /// Removes the specified interceptor from the network manager.
  ///
  /// The [deletedInterceptor] parameter is the interceptor to be removed.
  bool removeInterceptor(InterceptorT deletedInterceptor);

  /// Gets the interceptors used by the network manager.
  ///
  /// Returns an [InterceptorT] object that contains the interceptors.
  List<InterceptorT> get allInterceptors;
}
