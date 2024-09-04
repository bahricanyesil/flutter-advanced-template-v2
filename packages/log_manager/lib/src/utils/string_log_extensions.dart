/// Custom extensions on [String] class.
extension StringLogExtensions on String {
  /// Returns `true` if this [String] contains the [other] [String] ignoring
  /// case, otherwise returns `false`.
  bool containsIgnoreCase(String other) =>
      toLowerCase().contains(other.toLowerCase());
}
