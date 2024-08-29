/// An abstract class that provides an interface for managing device and package
/// information.
///
/// This class defines methods and properties for retrieving various details
/// about the device and the application package. Implementations of this class
/// should provide platform-specific logic to fetch this information.
abstract interface class DevicePackageManager {
  /// Initializes the device package manager.
  ///
  /// This method should be called before using any other methods of this class.
  /// It may perform necessary setup operations.
  Future<void> init();

  /// Retrieves detailed information about the device.
  ///
  /// Returns a [AppDeviceInfo] object containing
  /// various device-specific details.
  Future<AppDeviceInfo> getDeviceInfo();

  /// Retrieves information about the application package.
  ///
  /// Returns a [AppPackageInfo] object containing
  /// details about the app package.
  Future<AppPackageInfo> getPackageInfo();

  /// Returns the name of the operating system running on the device.
  String? get deviceOS;

  /// Returns the version of the operating system running on the device.
  Future<String?> get deviceOSVersion;

  /// Returns `true` if the current device is an iPad, otherwise returns `false`
  Future<bool> get isIpad;

  /// Returns the unique device id for the current device.
  Future<String?> get uniqueDeviceId;

  /// Returns the app name.
  String? get appName;

  /// Returns the package name.
  String? get packageName;

  /// Returns the app version.
  String? get version;

  /// Returns the build number.
  String? get buildNumber;
}

/// A model class representing device information.
final class AppDeviceInfo {
  /// Creates a [AppDeviceInfo] instance.
  const AppDeviceInfo({
    required this.id,
    required this.model,
    required this.os,
    required this.osVersion,
    required this.isIpad,
  });

  /// The unique identifier for the device.
  final String id;

  /// The model name or number of the device.
  final String? model;

  /// The name of the operating system running on the device.
  final String os;

  /// The version of the operating system running on the device.
  final String? osVersion;

  /// Returns `true` if the current device is an iPad,
  /// otherwise returns `false`.
  final bool isIpad;
}

/// A model class representing application package information.
final class AppPackageInfo {
  /// Creates a [AppPackageInfo] instance.
  const AppPackageInfo({
    this.appName,
    this.packageName,
    this.version,
    this.buildNumber,
  });

  /// The name of the application.
  final String? appName;

  /// The package name.
  final String? packageName;

  /// The version of the application.
  final String? version;

  /// The build number of the application.
  final String? buildNumber;
}
