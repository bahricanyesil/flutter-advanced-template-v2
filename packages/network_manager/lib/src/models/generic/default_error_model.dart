import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/foundation.dart';

import '../data_model.dart';
import 'default_data_model.dart';

part 'default_error_model.mapper.dart';

/// Represents a default error model.
///
/// This model is used to represent errors in the network response.
/// It implements the [DataModel] interface.
@MappableClass(hook: DefaultErrorHook())
@immutable
final class DefaultErrorModel
    with DefaultErrorModelMappable
    implements DataModel<DefaultErrorModel> {
  /// Creates a new instance of [DefaultErrorModel] with the given [message],
  /// and [resultCode].
  const DefaultErrorModel({this.message, this.resultCode});

  /// The message of the error.
  final String? message;

  /// The result code of the error.
  final String? resultCode;
}

/// A hook class used for decoding and mapping default error models.
/// This hook is responsible for handling the decoding process before
/// the actual decoding takes place. It extracts the necessary information
/// from the input value and returns a modified version of it.
@immutable
final class DefaultErrorHook extends MappingHook {
  /// Creates a new instance of [DefaultErrorHook].
  const DefaultErrorHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is Map<String, dynamic>) {
      const String resultCodeKey = 'resultCode';
      Object? resultMessage = value['resultMessage'] ?? value['message'];
      resultMessage ??= value['message'];
      late final String localizedMessage;
      // TODO(bahrican): Replace with dynamically determined value
      const LanguageTypes language = LanguageTypes.en;
      if (resultMessage is Map<String, dynamic>) {
        localizedMessage = resultMessage[language.code].toString();
      } else {
        localizedMessage = resultMessage.toString();
      }
      return <String, dynamic>{
        'message': localizedMessage,
        'resultCode': value[resultCodeKey],
      };
    }
    return value;
  }
}
