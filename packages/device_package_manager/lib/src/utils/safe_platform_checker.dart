import 'package:flutter/foundation.dart';

/// A utility class for safely checking the current platform.
///
/// This class provides static getters to determine the current platform
/// and operating system without directly accessing platform-specific APIs.
/// It uses Flutter's [defaultTargetPlatform] and [kIsWeb]
/// constant for safe checks.
abstract final class SafePlatformChecker {
  /// Returns true if the app is running on the web.
  static bool get isWeb => kIsWeb;

  /// Returns true if the app is running on Android.
  static bool get isAndroid =>
      !isWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Returns true if the app is running on iOS.
  static bool get isIOS =>
      !isWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Returns true if the app is running on Windows.
  static bool get isWindows =>
      !isWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// Returns true if the app is running on macOS.
  static bool get isMacOS =>
      !isWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Returns true if the app is running on Linux.
  static bool get isLinux =>
      !isWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// Returns true if the app is running on Fuchsia.
  static bool get isFuchsia =>
      !isWeb && defaultTargetPlatform == TargetPlatform.fuchsia;

  /// Returns a string representation of the current operating system.
  ///
  /// Possible return values are:
  /// - 'Web'
  /// - 'Android'
  /// - 'iOS'
  /// - 'Windows'
  /// - 'macOS'
  /// - 'Linux'
  /// - 'Fuchsia'
  /// - 'Unknown' (if the platform cannot be determined)
  static String get operatingSystem {
    if (isWeb) return 'Web';  
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    if (isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }
}
