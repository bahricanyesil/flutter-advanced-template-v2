import 'package:dio/dio.dart' as dio;

/// Extension on [dio.Interceptor] to provide additional functionality.
extension InterceptorExtensions on dio.Interceptor {
  /// Checks if the current interceptor is equal to the [other] interceptor.
  ///
  /// Returns `true` if the hash code and runtime type of the interceptors
  /// are equal, `false` otherwise.
  bool isEqual(dio.Interceptor other) =>
      hashCode == other.hashCode && runtimeType == other.runtimeType;
}

/// Extension on [List<dio.Interceptor>] to provide additional functionality
/// related to interceptors.
extension ListInterceptorExtensions on List<dio.Interceptor> {
  /// Checks if the given [interceptor] exists in the list.
  bool exists(dio.Interceptor interceptor) => any(
        (dio.Interceptor oldInterceptor) => oldInterceptor.isEqual(interceptor),
      );

  /// Adds the [interceptor] to the list if it does not already exist.
  bool addIfNotExists(dio.Interceptor interceptor) {
    final bool isExist = exists(interceptor);
    if (!isExist) add(interceptor);
    return !isExist;
  }

  /// Inserts the [interceptor] at the given [index]
  /// if it does not already exist.
  bool insertIfNotExists(int index, dio.Interceptor interceptor) {
    if (index < 0 || index > length) return false;
    final bool isExist = exists(interceptor);
    if (!isExist) insert(index, interceptor);
    return !isExist;
  }

  /// Adds all the interceptors from the [newInterceptorList]
  /// to the current list of interceptors, if they do not already exist.
  ///
  /// The [newInterceptorList] is filtered to only include interceptors
  /// that do not already exist in the current list.
  ///
  /// Example usage:
  /// ```dart
  /// List<dio.Interceptor> newInterceptors = [...];
  /// addAllIfNotExists(newInterceptors);
  /// ```
  void addAllIfNotExists(List<dio.Interceptor> newInterceptorList) => addAll(
        newInterceptorList.where(
          (dio.Interceptor newInterceptor) => !exists(newInterceptor),
        ),
      );

  /// Removes the given [interceptor] if it exists in the list.
  ///
  /// The [interceptor] parameter is the interceptor to be removed.
  /// Returns void.
  bool removeIfExist(dio.Interceptor interceptor) {
    final int index = indexWhere(
      (dio.Interceptor oldInterceptor) => oldInterceptor.isEqual(interceptor),
    );
    if (index != -1) removeAt(index);
    return index != -1;
  }
}
