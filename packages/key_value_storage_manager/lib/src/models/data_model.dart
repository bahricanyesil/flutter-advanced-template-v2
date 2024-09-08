/// An abstract interface class for network data.
abstract interface class DataModel<T> {
  /// Converts the object to a JSON string representation.
  ///
  /// Returns the JSON string representation of the object.
  String toJson();

  /// Converts the [DataModel] object to a [Map] representation.
  ///
  /// Returns a [Map] containing the key-value pairs of the object's properties.
  Map<String, dynamic> toMap();
}
