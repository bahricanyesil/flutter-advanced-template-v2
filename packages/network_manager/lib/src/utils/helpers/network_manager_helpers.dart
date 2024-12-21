// ignore_for_file: require_trailing_commas

import 'dart:io';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:dio/dio.dart' as dio;
import 'package:key_value_storage_manager/key_value_storage_manager.dart'
    as local_storage_manager;
import 'package:network_manager/src/exceptions/mismatched_type_exception.dart';
import 'package:network_manager/src/utils/helpers/status_code_helpers.dart';

import '../../models/index.dart';
import 'data_mapper_helpers.dart';
import 'json_helpers.dart';

/// A mixin that provides helper methods for network managers.
mixin NetworkManagerHelpers<E extends BaseDataModel<E>> {
  /// Parses the success response from the network and
  /// returns a [BaseNetworkSuccessModel] object.
  ///
  /// The [response] parameter is the response received from the network.
  /// It is used to parse the response data into the desired model.
  ///
  /// Returns a [BaseNetworkSuccessModel] object with the parsed data.
  BaseNetworkResponseModel<R, E> parseSuccess<R>(
      dio.Response<Object?> response) {
    if (isSuccessStatusCode(response.statusCode ?? HttpStatus.notFound)) {
      R? parseRes = fromJsonHelper<R>(response);
      if (R is dio.Response) parseRes = response as R;
      if (parseRes == null) {
        return _genericError<R>(
          MismatchedTypeException(expectedType: R, actualType: Null),
          response,
          message: 'Response data is null.',
          stackTrace: StackTrace.current,
        );
      }
      return BaseNetworkSuccessModel<R, E>(data: parseRes);
    } else {
      return _genericError<R>(
        dio.DioException(
            requestOptions: response.requestOptions, response: response),
        response,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Parses the response data into a [BaseNetworkSuccessModel] containing
  /// a [ListResponseModel] of type [R].
  ///
  /// The [response] parameter is the response received from the
  /// network request.
  ///
  /// Returns a [BaseNetworkSuccessModel] with a [ListResponseModel] containing
  /// the parsed list data.
  ///
  /// Returns an [Exception] if the response data is not a list.
  /// Returns a [dio.DioException] if the response status code is not
  /// a success status code.
  BaseNetworkResponseModel<ListResponseModel<R>, E> parseList<R>(
      dio.Response<Object?> response) {
    final List<Object?>? listData = _checkList(response);
    if (listData == null) {
      final Object? responseData = response.data;
      return _genericError<ListResponseModel<R>>(
        MismatchedTypeException(
            expectedType: List, actualType: responseData.runtimeType),
        response,
        stackTrace: StackTrace.current,
      );
    } else {
      final List<R> parsedList =
          local_storage_manager.DataParserHelpers.parseIterable<R>(listData)
              .toList();
      if (isSuccessStatusCode(response.statusCode ?? HttpStatus.notFound)) {
        return BaseNetworkSuccessModel<ListResponseModel<R>, E>(
            data: ListResponseModel<R>(dataList: parsedList));
      } else {
        return _genericError<ListResponseModel<R>>(
          dio.DioException(
              requestOptions: response.requestOptions, response: response),
          response,
          stackTrace: StackTrace.current,
        );
      }
    }
  }

  /// Parses the DioException and returns an instance of
  /// INetworkErrorModel<R> based on the exception type.
  ///
  /// The [err] parameter is the DioException to be parsed.
  ///
  /// Returns an instance of INetworkErrorModel<R> based on the exception type.
  NetworkErrorModel<R, E> parseError<R>(dio.DioException err) {
    final String? m = _errorMessage(err);
    try {
      final E? d = fromJsonHelper<E>(err.response);
      final StackTrace s = err.stackTrace;

      if (err is DioConnectionError) {
        return NoConnectionError<R, E>(
            error: err, message: m, errorData: d, stackTrace: s);
      }
      switch (err.type) {
        case dio.DioExceptionType.connectionTimeout:
          return ConnectionTimeOutError<R, E>(
              error: err, message: m, errorData: d, stackTrace: s);
        case dio.DioExceptionType.sendTimeout:
          return SendTimeOutError<R, E>(
              error: err, message: m, errorData: d, stackTrace: s);
        case dio.DioExceptionType.receiveTimeout:
          return ReceiveTimeOutError<R, E>(
              error: err, message: m, errorData: d, stackTrace: s);
        case dio.DioExceptionType.cancel:
          return CancelledRequestError<R, E>(
              error: err, message: m, errorData: d, stackTrace: s);
        case dio.DioExceptionType.badCertificate:
          return BadCertificateError<R, E>(
              error: err, message: m, errorData: d, stackTrace: s);
        case dio.DioExceptionType.connectionError:
          return ConnectionError<R, E>(
              error: err, message: m, errorData: d, stackTrace: s);
        case dio.DioExceptionType.badResponse:
          return _badResponseError(err, m, d);
        case dio.DioExceptionType.unknown:
          return UnknownError<R, E>(
              error: err, message: m, errorData: d, stackTrace: s);
      }
    } catch (e, s) {
      return NetworkParseError<R, E>(
        expectedType: E,
        value: err.response?.data,
        error: err,
        message: m,
        stackTrace: s,
      );
    }
  }

  NetworkErrorModel<R, E> _badResponseError<R>(
      dio.DioException err, String? m, E? d) {
    final StackTrace s = err.stackTrace;
    switch (err.response?.statusCode) {
      case 400:
        return BadRequestError<R, E>(
            error: err, message: m, errorData: d, stackTrace: s);
      case 401:
        return UnauthorizedError<R, E>(
            error: err, message: m, errorData: d, stackTrace: s);
      case 404:
        return NotFoundError<R, E>(
            error: err, message: m, errorData: d, stackTrace: s);
      case 409:
        return ConflictError<R, E>(
            error: err, message: m, errorData: d, stackTrace: s);
      case 500:
        return ServerError<R, E>(
            error: err, message: m, errorData: d, stackTrace: s);
      default:
        return _genericError<R>(err, err.response, errorData: d, stackTrace: s);
    }
  }

  String? _errorMessage(dio.DioException err) =>
      err.response?.statusMessage ?? err.message;

  /// Converts the response data from a Dio response to an
  /// instance of the specified data model.
  ///
  /// The [response] parameter represents the Dio response containing
  /// the data to be converted.
  ///
  /// Returns the converted data model instance, or null if
  /// the response data is null.
  R? fromJsonHelper<R>(dio.Response<Object?>? response) {
    final MapperBase<Object>? mapper = MapperContainer.globals.get(R);
    Object? encodedData = response?.data;
    if (mapper != null) {
      try {
        encodedData = mapper.encodeValue(response?.data);
      } catch (e) {
        // No action needed
      }
    }
    final String? responseData = JsonHelpers.safeJsonEncode(encodedData);
    if (responseData != null) {
      return DataMapperHelpers.safeFromJson<R>(responseData);
    } else {
      return null;
    }
  }

  /// Checks if the response data is a list.
  List<Object?>? _checkList(dio.Response<Object?> response) =>
      response.data is Iterable<Object?>
          ? (response.data! as Iterable<Object?>).toList()
          : null;

  GenericBadRequestError<T, E> _genericError<T>(
    Exception error,
    dio.Response<Object?>? response, {
    required StackTrace stackTrace,
    E? errorData,
    String? message,
  }) =>
      GenericBadRequestError<T, E>(
        error: error,
        errorData: errorData,
        message: message,
        statusCode: response?.statusCode,
        stackTrace: stackTrace,
      );
}
