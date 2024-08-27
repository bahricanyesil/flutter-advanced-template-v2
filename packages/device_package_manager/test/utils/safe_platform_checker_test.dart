import 'package:device_package_manager/src/utils/safe_platform_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SafePlatformChecker', () {
    tearDown(() {
      // Reset the override after each test
      debugDefaultTargetPlatformOverride = null;
    });

    test('operatingSystem returns correct value', () {
      expect(SafePlatformChecker.operatingSystem, isNotEmpty);
    });

    <String, TargetPlatform>{
      'android': TargetPlatform.android,
      'ios': TargetPlatform.iOS,
      'windows': TargetPlatform.windows,
      'macos': TargetPlatform.macOS,
      'linux': TargetPlatform.linux,
      'fuchsia': TargetPlatform.fuchsia,
    }.forEach((String platformName, TargetPlatform platform) {
      test('is$platformName returns true when platform is $platformName', () {
        debugDefaultTargetPlatformOverride = platform;
        expect(SafePlatformChecker.operatingSystem, platformName);
      });
    });
  });
}
