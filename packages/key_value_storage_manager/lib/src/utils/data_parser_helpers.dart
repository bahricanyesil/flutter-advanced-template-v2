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

  /// Gets a list of given type from the dynamic data.
  static Iterable<R> parseIterable<R>(Iterable<Object?> dynamicData) {
    if (dynamicData is Iterable<R>) return dynamicData;
    return dynamicData.mapFromStringIterable<R>(
      customFromStringParser: _customPrimitiveParser<R>(),
    );
  }

  static CustomFromStringParser<R>? _customPrimitiveParser<R>() {
    switch (R) {
      case String:
        return null;
      case int:
        return (String s) => int.tryParse(s) as R?;
      case double:
        return (String s) => double.tryParse(s) as R?;
      case bool:
        return (String s) => bool.tryParse(s) as R?;
    }
    throw const UnsupportedTypeException(
      supportedTypes: _supportedPrimitiveTypes,
    );
  }

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
    if (e is List) {
      final List<Object?> list = e;
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
    throw UnsuccessfulParseException(expectedType: T, value: e);
  }

  /// Checks if the given type is supported.
  static bool isSupportedPrimitive<T>() => _supportedPrimitiveTypes.contains(T);
}
