# Device Package Manager

The `device_package_manager` module provides a unified interface for accessing device and package information in Flutter applications. This module is designed to facilitate the retrieval of device-specific data and application package details.

## Features

- **Get Device Info:** Retrieve detailed information about the device.
- **Get Package Info:** Access application package details.
- **Cross-Platform Support:** Works on both Android and iOS platforms.

## Installation

To use the `device_package_manager` module in your Flutter project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  device_package_manager:
    path: ../packages/device_package_manager
```

## Usage

Here's a basic example of how to use the `device_package_manager` module:

### Import the Module

```dart
import 'package:device_package_manager/device_package_manager.dart';
```

### Initialize `DevicePackageManager`

```dart
final DevicePackageManager devicePackageManager = DevicePackageManagerImpl();
await devicePackageManager.init();
```

### Get Device Information

```dart
Map<String, dynamic> deviceInfo = await devicePackageManager.getDeviceInfo();
print('Device Model: ${deviceInfo['model']}');
print('Device OS: ${deviceInfo['os']}');
```

### Get Package Information

```dart
PackageInfo packageInfo = await devicePackageManager.getPackageInfo();
print('App Version: ${packageInfo.version}');
print('Build Number: ${packageInfo.buildNumber}');
```

For more detailed usage instructions and advanced features, please refer to the documentation.
