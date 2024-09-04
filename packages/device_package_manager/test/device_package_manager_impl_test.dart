import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_package_manager/device_package_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'mocks/mock_device_info_plugin.dart';
import 'mocks/mock_package_info.dart';

const String _baseOS = 'TestBaseOS';
const int _sdkInt = 30;
const String _release = '11';
const String _codename = 'R';
const String _incremental = '123456';
const int _previewSdkInt = 0;
const String _securityPatch = '2023-05-01';

void main() {
  group('DevicePackageManagerImpl', () {
    late DevicePackageManagerImpl manager;
    late MockDeviceInfoPlugin mockDeviceInfo;
    late MockPackageInfo mockPackageInfo;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '1',
        installerStore: 'test',
      );

      mockDeviceInfo = MockDeviceInfoPlugin();
      mockPackageInfo = MockPackageInfo();
      when(() => mockDeviceInfo.androidInfo).thenAnswer(
        (_) async => AndroidDeviceInfo.fromMap(_androidFakeDeviceInfo),
      );

      when(() => mockPackageInfo.appName).thenReturn('Test App');
      when(() => mockPackageInfo.packageName).thenReturn('com.test.app');
      when(() => mockPackageInfo.version).thenReturn('1.0.0');
      when(() => mockPackageInfo.buildNumber).thenReturn('1');

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      manager =
          await DevicePackageManagerImpl.create(deviceInfo: mockDeviceInfo);
    });

    test('init method initializes device info', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await manager.init();
      verify(() => mockDeviceInfo.androidInfo).called(1);
    });

    test('getDeviceInfo returns correct AppDeviceInfo', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final AppDeviceInfo deviceInfo = await manager.getDeviceInfo();
      expect(deviceInfo.id, equals('test_id'));
      expect(deviceInfo.model, equals('Test Model'));
      expect(deviceInfo.os, equals('android'));
      expect(deviceInfo.osVersion, equals('11'));
    });

    test('getPackageInfo returns correct AppPackageInfo', () async {
      final AppPackageInfo packageInfo = await manager.getPackageInfo();
      expect(packageInfo.appName, equals('Test App'));
      expect(packageInfo.packageName, equals('com.test.app'));
      expect(packageInfo.version, equals('1.0.0'));
      expect(packageInfo.buildNumber, equals('1'));
    });

    test('deviceOS returns correct value', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(manager.deviceOS, equals('android'));
    });

    test('isIpad returns true for iPad model', () async {
      final MockDeviceInfoPlugin newMockDeviceInfo = MockDeviceInfoPlugin();

      when(() => newMockDeviceInfo.iosInfo).thenAnswer(
        (_) async => IosDeviceInfo.fromMap(
          _iosFakeDeviceInfoMap,
        ),
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final DevicePackageManagerImpl iosManager =
          await DevicePackageManagerImpl.create(deviceInfo: newMockDeviceInfo);
      expect(await iosManager.isIpad, isTrue);
    });
  });
}

Map<String, dynamic> get _iosFakeDeviceInfoMap => <String, dynamic>{
      'name': 'Test Device',
      'systemName': 'Test OS',
      'systemVersion': '11',
      'model': 'iPad Pro',
      'localizedModel': 'iPad Pro',
      'identifierForVendor': '1234567890',
      'isPhysicalDevice': true,
      'utsname': <String, dynamic>{
        'sysname': 'Test OS',
        'nodename': 'Test Device',
        'release': '11',
        'version': '11',
        'machine': 'iPad Pro',
      },
    };

Map<String, dynamic> get _androidFakeDeviceInfo {
  return <String, dynamic>{
    'id': 'test_id',
    'model': 'Test Model',
    'version': <String, dynamic>{
      'baseOS': _baseOS,
      'sdkInt': _sdkInt,
      'release': _release,
      'codename': _codename,
      'incremental': _incremental,
      'previewSdkInt': _previewSdkInt,
      'securityPatch': _securityPatch,
    },
    'board': 'test_board',
    'bootloader': 'test_bootloader',
    'brand': 'test_brand',
    'device': 'test_device',
    'display': 'test_display',
    'fingerprint': 'test_fingerprint',
    'hardware': 'test_hardware',
    'host': 'test_host',
    'manufacturer': 'test_manufacturer',
    'product': 'test_product',
    'supportedAbis': <String>['test_abi'],
    'systemFeatures': <String>['test_feature'],
    'tags': 'test_tag',
    'type': 'test_type',
    'isPhysicalDevice': true,
    'displaySizeInches': 5.5,
    'displayWidthPx': 1080,
    'displayHeightPx': 1920,
    'displayMetrics': <String, dynamic>{
      'widthPx': 1080.0,
      'heightPx': 1920.0,
      'xDpi': 480.0,
      'yDpi': 480.0,
    },
    'serialNumber': 'test_serial_number',
  };
}
