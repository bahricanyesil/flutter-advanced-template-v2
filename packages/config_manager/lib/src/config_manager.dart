import 'package:config_manager/config_manager.dart';
import 'package:flutter/foundation.dart';

/// A class that represents the configuration for initializing the application.
///
/// The [ConfigManager] class provides a way to configure the initialization
/// of the application by specifying the [T]
/// to use based on the current environment.
///
/// The [envConfig] property returns the configured [T] instance.
/// If the [ConfigManager] is not initialized, an exception is thrown.
@immutable
final class ConfigManager<T extends BaseEnv> {
  /// Sets up the application initialization configuration.
  ///
  /// The [envConfig] parameter is an optional [T] object
  /// that specifies the configuration for the application.
  /// If [envConfig] is not provided, the configuration will
  /// be determined based on the current build mode.
  ///
  /// Example usage:
  /// ```dart
  /// ConfigManager.setUp();
  /// ```
  ConfigManager({
    required T prodConfig,
    T? devConfig,
    T? stagingConfig,
  }) {
    if (kDebugMode) {
      _envConfig = switch (flavor) {
        FlavorTypes.prod => prodConfig,
        FlavorTypes.dev => devConfig ?? prodConfig,
        FlavorTypes.staging => stagingConfig ?? prodConfig,
      };
    } else {
      _envConfig = prodConfig;
    }
  }

  late final T _envConfig;

  /// Get application environment item value
  T get envConfig => _envConfig;

  /// Returns the [FlavorTypes] based on the value of the 'FLUTTER_APP_FLAVOR'
  /// environment variable.
  static FlavorTypes get flavor {
    const String flavorStr = String.fromEnvironment('FLUTTER_APP_FLAVOR');
    final FlavorTypes foundFlavor = FlavorTypes.values.findByName(flavorStr);
    return foundFlavor;
  }
}
