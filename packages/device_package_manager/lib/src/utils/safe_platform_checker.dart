import 'package:flutter/foundation.dart';

/// A utility class for safely checking the current platform.
///
/// This class provides static getters to determine the current platform
/// and operating system without directly accessing platform-specific APIs.
/// It uses Flutter's [defaultTargetPlatform] and [kIsWeb]
/// constant for safe checks.
abstract interface class SafePlatformChecker {
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
  /// - 'web'
  /// - 'android'
  /// - 'ios'
  /// - 'windows'
  /// - 'macos'
  /// - 'linux'
  /// - 'fuchsia'
  /// - 'unknown'
  static String get operatingSystem {
    if (isWeb) return 'web';
    if (isAndroid) return 'android';
    if (isIOS) return 'ios';
    if (isWindows) return 'windows';
    if (isMacOS) return 'macos';
    if (isLinux) return 'linux';
    if (isFuchsia) return 'fuchsia';
    return 'unknown';
  }
}
