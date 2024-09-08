/// A typedef representing a custom parser function.
///
/// The [CustomFromStringParser] function takes a [String] source as input
/// and returns a [R] value.
/// It is used to parse strings into nullable double values.
typedef CustomFromStringParser<R> = R? Function(String source);

/// A typedef representing a custom parser function.
typedef CustomParser<R, T> = R? Function(T? source);

/// Extension on [Iterable] to provide additional functionality.
extension IterableExtensions<T> on Iterable<T?> {
  /// Maps the elements of this iterable to a new iterable of type [R].
  Iterable<R> mapToIterable<R>(CustomParser<R, T> customParser) =>
      map<R?>((T? element) => element == null ? null : customParser(element))
          .whereNotNull();

  /// Maps the elements of this iterable to a typed list of type [R].
  ///
  /// The [CustomFromStringParser] parameter is an optional custom parser
  /// function that converts each element to type [R].
  /// If [CustomFromStringParser] is not provided and the type of [R]
  /// is not [String], an assertion error will be thrown.
  ///
  /// Returns a new list containing the mapped elements of type [R].
  /// Any null elements are filtered out before returning the list.
  Iterable<R> mapFromStringIterable<R>({
    CustomFromStringParser<R>? customFromStringParser,
  }) =>
      map<R?>((T? element) {
        assert(
          customFromStringParser != null || R == String,
          'A custom parser must be '
          'provided if the type of the returned list is not String.',
        );
        if (customFromStringParser == null) return element.toString() as R;
        return customFromStringParser(element.toString());
      }).whereNotNull();

  /// Returns an iterable containing only the non-null elements of this iterable
  ///
  /// The returned iterable is lazily evaluated, meaning that the elements are
  /// computed on demand as they are accessed. The order of the elements in the
  /// returned iterable is the same as the original iterable.
  ///
  /// Example:
  /// ```dart
  /// final list = [1, null, 3, null, 5];
  /// final nonNullList = list.whereNotNull();
  /// ```
  ///
  /// Throws an [Error] if the iterable contains elements of different types.
  ///
  /// Complexity: O(n), where n is the number of elements in the iterable.
  Iterable<T> whereNotNull() sync* {
    for (final T? element in this) {
      if (element != null) yield element;
    }
  }
}
