import 'dart:io';

import '../../models/base_data_model.dart';
import 'network_manager_helpers.dart';

/// Extension on `int` to provide utility methods for
/// working with HTTP status codes.
extension StatusCodeHelpers<E extends BaseDataModel<E>>
    on NetworkManagerHelpers<E> {
  /// Returns a boolean value indicating whether the status code
  /// is a success status code.
  bool isSuccessStatusCode(int statusCode) =>
      statusCode >= HttpStatus.ok && statusCode <= HttpStatus.multipleChoices;

  /// Returns a boolean value indicating whether the status code
  /// is a client error status code.
  bool isClientErrorStatusCode(int statusCode) =>
      statusCode >= HttpStatus.badRequest &&
      statusCode <= HttpStatus.upgradeRequired;

  /// Returns a boolean value indicating whether the status code
  /// is a server error status code.
  bool isServerErrorStatusCode(int statusCode) =>
      statusCode >= HttpStatus.internalServerError &&
      statusCode <= HttpStatus.networkConnectTimeoutError;
}
