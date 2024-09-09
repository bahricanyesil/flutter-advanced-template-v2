import 'package:dart_mappable/dart_mappable.dart';
import 'package:log_manager/log_manager.dart';

import '../exceptions/unsuccessful_parse_exception.dart';
import 'json_helpers.dart';

/// This class provides helper methods for data mapping.
abstract final class DataMapperHelpers {
  const DataMapperHelpers._();

  /// The function to convert the JSON to the required type.
  static T? safeFromJson<T>(String? json, {LogManager? logManager}) {
    if (json == null) return null;
    try {
      final MapperBase<Object>? mapper = MapperContainer.globals.get(T);
      if (mapper == null) return null;
      Object? jsonMap = JsonHelpers.safeJsonDecode(json);
      if (jsonMap is! Map) {
        logManager?.lError(
          '''DataMapperHelpers.safeFromJson: Error while decoding to $T: $jsonMap''',
        );
        jsonMap = <String, dynamic>{'resultMessage': jsonMap, 'resultCode': 0};
      }
      return mapper.decodeValue<T>(jsonMap);
    } catch (e, stackTrace) {
      logManager?.lError(
        '''DataMapperHelpers.safeFromJson: Error while decoding JSON to $T: $e''',
      );
      Error.throwWithStackTrace(
        UnsuccessfulParseException(expectedType: T, value: json),
        stackTrace,
      );
    }
  }

  /// The function to convert the object to JSON.
  static const int copyEqualsStringify =
      GenerateMethods.copy | GenerateMethods.equals | GenerateMethods.stringify;
}
