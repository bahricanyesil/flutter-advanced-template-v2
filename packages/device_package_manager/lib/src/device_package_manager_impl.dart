import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'device_package_manager.dart';
import 'utils/safe_platform_checker.dart';

/// Implementation of the [DevicePackageManager] interface.
///
/// This implementation uses [DeviceInfoPlugin] and [PackageInfo] to
/// get device and package information.
base class DevicePackageManagerImpl implements DevicePackageManager {
  DevicePackageManagerImpl._({
    required DeviceInfoPlugin deviceInfo,
    required PackageInfo packageInfo,
  })  : _deviceInfo = deviceInfo,
        _packageInfo = packageInfo {
    _baseDeviceInfo = _initializeDeviceInfo();
  }

  /// Creates a [DevicePackageManagerImpl] instance.
  ///
  /// [deviceInfo] is the [DeviceInfoPlugin] instance to use.
  /// If not provided, a new instance will be created.
  static Future<DevicePackageManagerImpl> create({
    DeviceInfoPlugin? deviceInfo,
  }) async {
    final DeviceInfoPlugin deviceInfoInstance =
        deviceInfo ?? DeviceInfoPlugin();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return DevicePackageManagerImpl._(
      deviceInfo: deviceInfoInstance,
      packageInfo: packageInfo,
    );
  }

  final DeviceInfoPlugin _deviceInfo;
  final PackageInfo _packageInfo;
  late final Future<BaseDeviceInfo> _baseDeviceInfo;

  Future<BaseDeviceInfo> _initializeDeviceInfo() =>
      switch (SafePlatformChecker.operatingSystem) {
        'web' => _deviceInfo.webBrowserInfo,
        'android' => _deviceInfo.androidInfo,
        'ios' => _deviceInfo.iosInfo,
        'windows' => _deviceInfo.windowsInfo,
        'macos' => _deviceInfo.macOsInfo,
        'linux' => _deviceInfo.linuxInfo,
        _ => throw UnsupportedError(
            'Unsupported platform: ${SafePlatformChecker.operatingSystem}',
          ),
      };

  @override
  Future<void> init() async => _baseDeviceInfo;

  @override
  Future<AppDeviceInfo> getDeviceInfo() async {
    final BaseDeviceInfo deviceInfo = await _baseDeviceInfo;
    final String id = (await uniqueDeviceId) ?? '';
    final bool isIpad = await this.isIpad;

    return AppDeviceInfo(
      id: id,
      model: _getModelName(deviceInfo),
      os: deviceOS,
      osVersion: await deviceOSVersion,
      isIpad: isIpad,
    );
  }

  String _getModelName(BaseDeviceInfo deviceInfo) => switch (deviceInfo) {
        AndroidDeviceInfo() => deviceInfo.model,
        IosDeviceInfo() => deviceInfo.model,
        WebBrowserInfo() => deviceInfo.browserName.name,
        WindowsDeviceInfo() => deviceInfo.computerName,
        MacOsDeviceInfo() => deviceInfo.model,
        LinuxDeviceInfo() => deviceInfo.name,
        _ => 'Unknown',
      };

  @override
  Future<AppPackageInfo> getPackageInfo() async {
    return AppPackageInfo(
      appName: appName ?? '',
      packageName: packageName ?? '',
      version: version ?? '',
      buildNumber: buildNumber ?? '',
    );
  }

  @override
  String get deviceOS => SafePlatformChecker.operatingSystem;

  @override
  Future<String> get deviceOSVersion async => _getDeviceOSVersion();

  Future<String> _getDeviceOSVersion() async {
    final BaseDeviceInfo deviceInfo = await _baseDeviceInfo;
    return switch (deviceInfo) {
      AndroidDeviceInfo() => deviceInfo.version.release,
      IosDeviceInfo() => deviceInfo.systemVersion,
      WebBrowserInfo() => deviceInfo.userAgent ?? 'Unknown',
      WindowsDeviceInfo() => deviceInfo.productName,
      MacOsDeviceInfo() => deviceInfo.osRelease,
      LinuxDeviceInfo() => deviceInfo.prettyName,
      _ => throw UnsupportedError('Unsupported platform for OS version'),
    };
  }

  @override
  Future<bool> get isIpad async {
    final BaseDeviceInfo deviceInfo = await _baseDeviceInfo;
    if (deviceInfo is IosDeviceInfo) {
      return deviceInfo.model.toLowerCase().contains('ipad');
    }
    return false;
  }

  @override
  Future<String?> get uniqueDeviceId async {
    final BaseDeviceInfo deviceInfo = await _baseDeviceInfo;
    return switch (deviceInfo) {
      WebBrowserInfo() => deviceInfo.userAgent,
      AndroidDeviceInfo() => deviceInfo.id,
      IosDeviceInfo() => deviceInfo.identifierForVendor,
      WindowsDeviceInfo() => deviceInfo.deviceId,
      MacOsDeviceInfo() => deviceInfo.systemGUID,
      LinuxDeviceInfo() => deviceInfo.machineId,
      _ => null,
    };
  }

  @override
  String? get appName => _packageInfo.appName;

  @override
  String? get packageName => _packageInfo.packageName;

  @override
  String? get version => _packageInfo.version;

  @override
  String? get buildNumber => _packageInfo.buildNumber;
}
