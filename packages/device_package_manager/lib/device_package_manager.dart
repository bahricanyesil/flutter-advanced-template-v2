/// Library for device and package manager that
/// provides a unified interface for accessing device and package information.
///
/// This library provides an abstract class DevicePackageManager that
/// defines the methods for retrieving device and package information.
///
/// The library also provides a concrete implementation of the
/// DevicePackageManager interface using device_info_plus and package_info_plus.
/// This implementation is available in the DevicePackageManagerImpl class.
library device_package_manager;

export 'src/device_package_manager.dart';
export 'src/device_package_manager_impl.dart';
