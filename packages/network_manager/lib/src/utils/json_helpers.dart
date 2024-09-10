import 'dart:convert';

/// A helper class for parsing JSON data.
///
/// This abstract class provides utility methods for parsing JSON data.
/// It cannot be instantiated and serves as a base class
/// for other helper classes.
abstract final class JsonHelpers {
  const JsonHelpers._();

  /// Safely encodes the given [data] into a JSON string.
  /// Returns the JSON string if successful, otherwise returns null.
  static String? safeJsonEncode(Object? data) {
    if (data == null) return null;

    if (data is String) {
      try {
        // Check if the string is already valid JSON
        jsonDecode(data);
        return data; // If it's valid JSON, return it as-is
      } catch (_) {
        // If it's not valid JSON, proceed with encoding
      }
    }

    try {
      return jsonEncode(data);
    } catch (e) {
      return null;
    }
  }

  /// Safely decodes a JSON string into a dynamic object.
  ///
  /// This function attempts to decode the given [data]
  /// string using [jsonDecode].
  /// If an exception occurs during the decoding process, it returns null.
  /// Otherwise, it returns the decoded dynamic object.
  static Object? safeJsonDecode(String data) {
    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }
}
