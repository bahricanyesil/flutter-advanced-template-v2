import 'dart:convert';

import '../exceptions/index.dart';
import 'extensions/iterable_extensions.dart';

/// This class provides helper methods for parsing dynamic data.
/// It is an abstract class and cannot be instantiated.
abstract final class DataParserHelpers {
  const DataParserHelpers._();
  static const List<Type> _supportedPrimitiveTypes = <Type>[
    String,
    int,
    double,
    bool,
    List<String>,
    List<int>,
    List<double>,
    List<bool>,
  ];

  /// Parses primitive and model types.
  static T? parsePrimitive<T>(Object e) {
    assert(isSupportedPrimitive<T>(), 'Type $T is not supported.');
    T? parsedPrimitive;
    switch (T) {
      case String:
        parsedPrimitive = e.toString() as T?;
      case int:
        parsedPrimitive = int.tryParse(e.toString()) as T?;
      case double:
        parsedPrimitive = double.tryParse(e.toString()) as T?;
      case bool:
        parsedPrimitive = bool.tryParse(e.toString()) as T?;
    }
    if (parsedPrimitive != null) return parsedPrimitive;

    final UnsuccessfulParseException unsuccessfulParseException =
        UnsuccessfulParseException(expectedType: T, value: e);

    final String stringE = e.toString();
    try {
      final Object? decoded = json.decode(stringE);
      if (decoded is List) {
        final List<Object?> list = decoded;
        Iterable<Object?>? iterable;
        if (T == List<String>) {
          iterable = list.mapFromStringIterable<String>();
        } else if (T == List<int>) {
          iterable = list.mapFromStringIterable<int>(
            customFromStringParser: int.tryParse,
          );
        } else if (T == List<double>) {
          iterable = list.mapFromStringIterable<double>(
            customFromStringParser: double.tryParse,
          );
        } else if (T == List<bool>) {
          iterable = list.mapFromStringIterable<bool>(
            customFromStringParser: bool.tryParse,
          );
        }
        if (iterable != null) return iterable.toList() as T;
      }
    } catch (e) {
      rethrow;
    }
    throw unsuccessfulParseException;
  }

  /// Checks if the given type is supported.
  static bool isSupportedPrimitive<T>() => _supportedPrimitiveTypes.contains(T);
}
