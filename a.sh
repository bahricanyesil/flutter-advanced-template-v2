#!/bin/bash

# Create package directory
mkdir -p packages/device_package_manager
cd packages/device_package_manager

# Initialize package
flutter create --template=package .

# Update pubspec.yaml
cat > pubspec.yaml << EOL
name: device_package_manager
description: A module to manage device and package information for Flutter apps.
version: 0.0.1
publish_to: none

environment:
  sdk: ^3.5.0
  flutter: ">=1.17.0"

dependencies:
  flutter:
    sdk: flutter
  device_info_plus: ^9.1.2
  package_info_plus: ^5.0.1
  log_manager:
    path: ../log_manager

dev_dependencies:
  flutter_test:
    sdk: flutter
  lint_rules:
    path: ../lint_rules
  mocktail: ^1.0.4
EOL

# Create src directory
mkdir -p lib/src

# Create device_package_manager.dart
cat > lib/src/device_package_manager.dart << EOL
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:log_manager/log_manager.dart';

abstract class DevicePackageManager {
  const DevicePackageManager({LogManager? logManager}) : _logManager = logManager;

  final LogManager? _logManager;

  LogManager? get logManager => _logManager;

  Future<void> init();

  Future<Map<String, dynamic>> getDeviceInfo();

  Future<PackageInfo> getPackageInfo();

  String get deviceId;

  String get deviceModel;

  String get deviceOS;

  String get deviceOSVersion;

  String get appVersion;

  String get appBuildNumber;
}
EOL

# Create device_package_manager_impl.dart
cat > lib/src/device_package_manager_impl.dart << EOL
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:log_manager/log_manager.dart';

import 'device_package_manager.dart';

class DevicePackageManagerImpl extends DevicePackageManager {
  DevicePackageManagerImpl({LogManager? logManager}) : super(logManager: logManager);

  late DeviceInfoPlugin _deviceInfo;
  late PackageInfo _packageInfo;

  @override
  Future<void> init() async {
    _deviceInfo = DeviceInfoPlugin();
    _packageInfo = await PackageInfo.fromPlatform();
    logManager?.lInfo('Device Package Manager initialized');
  }

  @override
  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (Platform.isAndroid) {
      return _getAndroidDeviceInfo();
    } else if (Platform.isIOS) {
      return _getIOSDeviceInfo();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    return {
      'id': androidInfo.id,
      'model': androidInfo.model,
      'os': 'Android',
      'osVersion': androidInfo.version.release,
    };
  }

  Future<Map<String, dynamic>> _getIOSDeviceInfo() async {
    final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
    return {
      'id': iosInfo.identifierForVendor,
      'model': iosInfo.model,
      'os': 'iOS',
      'osVersion': iosInfo.systemVersion,
    };
  }

  @override
  Future<PackageInfo> getPackageInfo() async {
    return _packageInfo;
  }

  @override
  String get deviceId => _getDeviceId();

  String _getDeviceId() {
    if (Platform.isAndroid) {
      return _deviceInfo.androidInfo.then((info) => info.id);
    } else if (Platform.isIOS) {
      return _deviceInfo.iosInfo.then((info) => info.identifierForVendor ?? '');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  String get deviceModel => _getDeviceModel();

  String _getDeviceModel() {
    if (Platform.isAndroid) {
      return _deviceInfo.androidInfo.then((info) => info.model);
    } else if (Platform.isIOS) {
      return _deviceInfo.iosInfo.then((info) => info.model);
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  String get deviceOS => Platform.isAndroid ? 'Android' : 'iOS';

  @override
  String get deviceOSVersion => _getDeviceOSVersion();

  String _getDeviceOSVersion() {
    if (Platform.isAndroid) {
      return _deviceInfo.androidInfo.then((info) => info.version.release);
    } else if (Platform.isIOS) {
      return _deviceInfo.iosInfo.then((info) => info.systemVersion);
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  String get appVersion => _packageInfo.version;

  @override
  String get appBuildNumber => _packageInfo.buildNumber;
}
EOL

# Update main library file
cat > lib/device_package_manager.dart << EOL
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
EOL

# Create test file
cat > test/device_package_manager_test.dart << EOL
import 'package:device_package_manager/device_package_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockLogManager extends Mock implements LogManager {}

void main() {
  late DevicePackageManagerImpl devicePackageManager;
  late MockLogManager mockLogManager;

  setUp(() {
    mockLogManager = MockLogManager();
    devicePackageManager = DevicePackageManagerImpl(logManager: mockLogManager);
  });

  test('init method initializes DevicePackageManager correctly', () async {
    await devicePackageManager.init();
    verify(() => mockLogManager.lInfo('Device Package Manager initialized')).called(1);
  });

  // Add more tests for other methods and properties
}
EOL

# Create analysis_options.yaml
cat > analysis_options.yaml << EOL
include: ../lint_rules/analysis_options.yaml
EOL

# Create README.md
cat > README.md << EOL
# Device Package Manager

The \`device_package_manager\` module provides a unified interface for accessing device and package information in Flutter applications. This module is designed to facilitate the retrieval of device-specific data and application package details.

## Features

- **Get Device Info:** Retrieve detailed information about the device.
- **Get Package Info:** Access application package details.
- **Cross-Platform Support:** Works on both Android and iOS platforms.

## Installation

To use the \`device_package_manager\` module in your Flutter project, add it to your \`pubspec.yaml\` file:

\`\`\`yaml
dependencies:
  device_package_manager:
    path: ../packages/device_package_manager
\`\`\`

## Usage

Here's a basic example of how to use the \`device_package_manager\` module:

### Import the Module

\`\`\`dart
import 'package:device_package_manager/device_package_manager.dart';
\`\`\`

### Initialize \`DevicePackageManager\`

\`\`\`dart
final DevicePackageManager devicePackageManager = DevicePackageManagerImpl();
await devicePackageManager.init();
\`\`\`

### Get Device Information

\`\`\`dart
Map<String, dynamic> deviceInfo = await devicePackageManager.getDeviceInfo();
print('Device Model: \${deviceInfo['model']}');
print('Device OS: \${deviceInfo['os']}');
\`\`\`

### Get Package Information

\`\`\`dart
PackageInfo packageInfo = await devicePackageManager.getPackageInfo();
print('App Version: \${packageInfo.version}');
print('Build Number: \${packageInfo.buildNumber}');
\`\`\`

For more detailed usage instructions and advanced features, please refer to the documentation.
EOL

# Create LICENSE file
cat > LICENSE << EOL
MIT License

Copyright (c) 2024 Your Organization

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOL

# Create CHANGELOG.md
cat > CHANGELOG.md << EOL
## 0.0.1

* Initial release of the Device Package Manager.
* Implemented basic device and package information retrieval.
* Added support for Android and iOS platforms.
EOL

echo "DevicePackageManager package created successfully with all necessary files!"