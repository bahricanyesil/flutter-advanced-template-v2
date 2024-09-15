/// Enum representing different flavorTypess of the application.
///
/// The flavorTypess include:
/// - `dev`: Development flavorTypes
/// - `staging`: Staging flavorTypes
/// - `prod`: Production flavorTypes
enum FlavorTypes {
  /// Development flavorTypes
  dev('dev'),

  /// staging flavorTypes
  staging('staging'),

  /// Production flavorTypes
  prod('prod');

  const FlavorTypes(this.value);

  /// The name of the flavorTypes.
  final String value;
}

/// Extension methods for the [FlavorTypes] list enum.
extension FlavorTypesListHelperExtensions on List<FlavorTypes> {
  /// Finds the [FlavorTypes] with the given [name] if it exists.
  FlavorTypes findByName(String name) => firstWhere(
        (FlavorTypes e) => e.name.toLowerCase() == name.toLowerCase(),
        orElse: () => FlavorTypes.dev,
      );
}

/// Extension methods for the [FlavorTypes] enum.
extension FlavorTypesExtensions on FlavorTypes {
  /// Returns whether the current flavorTypes is a test flavorTypes.
  bool get isTest => this == FlavorTypes.dev || this == FlavorTypes.staging;
}
