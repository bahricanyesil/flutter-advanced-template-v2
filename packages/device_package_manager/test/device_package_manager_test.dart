import 'package:device_package_manager/device_package_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_device_package_manager.dart';

void main() {
  group('DevicePackageManager', () {
    late MockDevicePackageManager manager;

    setUp(() {
      manager = MockDevicePackageManager();
    });

    test('init method is called', () async {
      when(() => manager.init()).thenAnswer((_) async {
        return;
      });
      await manager.init();
      verify(() => manager.init()).called(1);
    });

    test('getDeviceInfo returns AppDeviceInfo', () async {
      const AppDeviceInfo appDeviceInfo = AppDeviceInfo(
        id: '123',
        model: 'Test Model',
        os: 'Test OS',
        osVersion: '1.0',
        isIpad: false,
      );
      when(() => manager.getDeviceInfo())
          .thenAnswer((_) async => appDeviceInfo);

      final AppDeviceInfo result = await manager.getDeviceInfo();
      expect(result, equals(appDeviceInfo));
    });

    test('getPackageInfo returns AppPackageInfo', () async {
      const AppPackageInfo appPackageInfo = AppPackageInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '1.0.0',
        buildNumber: '1',
      );
      when(() => manager.getPackageInfo())
          .thenAnswer((_) async => appPackageInfo);

      final AppPackageInfo result = await manager.getPackageInfo();
      expect(result, equals(appPackageInfo));
    });

    test('deviceOS returns correct value', () {
      when(() => manager.deviceOS).thenReturn('Test OS');
      expect(manager.deviceOS, equals('Test OS'));
    });
  });
}
