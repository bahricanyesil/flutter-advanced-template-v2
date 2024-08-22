/// Custom extensions on [String] class.
extension AdvancedTemplateLoggerStringExtensions on String {
  /// Returns `true` if this [String] contains the [other] [String] ignoring
  /// case, otherwise returns `false`.
  bool containsIgnoreCase(String other) =>
      toLowerCase().contains(other.toLowerCase());

  /// Returns `true` if this [String] equals the [other] [String] ignoring
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}
