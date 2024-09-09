import 'package:collection/collection.dart';

/// Enum representing different HTTP method types.
///
/// The available method types are:
/// - GET: Represents the HTTP GET method.
/// - POST: Represents the HTTP POST method.
/// - PUT: Represents the HTTP PUT method.
/// - DELETE: Represents the HTTP DELETE method.
/// - PATCH: Represents the HTTP PATCH method.
enum MethodTypes {
  /// Enum representing different HTTP request methods.
  /// HTTP GET method.
  get,

  /// HTTP POST method.
  post,

  /// HTTP PUT method.
  put,

  /// HTTP DELETE method.
  delete,

  /// HTTP PATCH method.
  patch,
}

/// Extension methods for the [MethodTypes] enum.
extension MethodTypeListExt on List<MethodTypes> {
  /// Finds the [MethodTypes] enum value that matches the given [name].
  MethodTypes? find(String name) {
    return firstWhereOrNull(
      (MethodTypes methodType) => methodType.name == name,
    );
  }
}
