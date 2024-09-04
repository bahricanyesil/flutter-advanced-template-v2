// ignore_for_file: deprecated_member_use, no-empty-block

import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// [PlatformDispatcher] that wraps another [PlatformDispatcher] and
/// allows faking of some properties for testing purposes.
///
/// See also:
///
///   * [TestFlutterView], which wraps a [FlutterView] for testing and
///     mocking purposes.
class CustomTestPlatformDispatcher implements PlatformDispatcher {
  /// Constructs a [CustomTestPlatformDispatcher] that
  /// defers all behavior to the given
  /// [PlatformDispatcher] unless explicitly overridden for test purposes.
  CustomTestPlatformDispatcher({
    required PlatformDispatcher platformDispatcher,
  }) : _platformDispatcher = platformDispatcher;

  /// The [PlatformDispatcher] that is wrapped by
  /// this [CustomTestPlatformDispatcher].
  final PlatformDispatcher _platformDispatcher;

  @override
  ErrorCallback? get onError => _platformDispatcher.onError;
  @override
  set onError(ErrorCallback? value) {
    _platformDispatcher.onError = value;
  }

  @override
  VoidCallback? onAccessibilityFeaturesChanged;

  @override
  FrameCallback? onBeginFrame;

  @override
  VoidCallback? onDrawFrame;

  @override
  VoidCallback? onFrameDataChanged;

  @override
  KeyDataCallback? onKeyData;

  @override
  VoidCallback? onLocaleChanged;

  @override
  VoidCallback? onMetricsChanged;

  @override
  VoidCallback? onPlatformBrightnessChanged;

  @override
  VoidCallback? onPlatformConfigurationChanged;

  @override
  PlatformMessageCallback? onPlatformMessage;

  @override
  PointerDataPacketCallback? onPointerDataPacket;

  @override
  TimingsCallback? onReportTimings;

  @override
  SemanticsActionEventCallback? onSemanticsActionEvent;

  @override
  VoidCallback? onSemanticsEnabledChanged;

  @override
  VoidCallback? onSystemFontFamilyChanged;

  @override
  VoidCallback? onTextScaleFactorChanged;

  @override
  ViewFocusChangeCallback? onViewFocusChange;

  @override
  AccessibilityFeatures get accessibilityFeatures => throw UnimplementedError();

  @override
  bool get alwaysUse24HourFormat => throw UnimplementedError();

  @override
  bool get brieflyShowPassword => throw UnimplementedError();

  @override
  Locale? computePlatformResolvedLocale(List<Locale> supportedLocales) {
    throw UnimplementedError();
  }

  @override
  String get defaultRouteName => throw UnimplementedError();

  @override
  Iterable<Display> get displays => throw UnimplementedError();

  @override
  FrameData get frameData => throw UnimplementedError();

  @override
  ByteData? getPersistentIsolateData() {
    throw UnimplementedError();
  }

  @override
  FlutterView? get implicitView => throw UnimplementedError();

  @override
  String get initialLifecycleState => throw UnimplementedError();

  @override
  Locale get locale => throw UnimplementedError();

  @override
  List<Locale> get locales => throw UnimplementedError();

  @override
  bool get nativeSpellCheckServiceDefined => throw UnimplementedError();

  @override
  Brightness get platformBrightness => throw UnimplementedError();

  @override
  void registerBackgroundIsolate(RootIsolateToken token) {}

  @override
  void requestDartPerformanceMode(DartPerformanceMode mode) {}

  @override
  void requestViewFocusChange({
    required int viewId,
    required ViewFocusState state,
    required ViewFocusDirection direction,
  }) {}

  @override
  double scaleFontSize(double unscaledFontSize) {
    throw UnimplementedError();
  }

  @override
  void scheduleFrame() {}

  @override
  void scheduleWarmUpFrame({
    required VoidCallback beginFrame,
    required VoidCallback drawFrame,
  }) {}

  @override
  bool get semanticsEnabled => throw UnimplementedError();

  @override
  void sendPlatformMessage(
    String name,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) {}

  @override
  void sendPortPlatformMessage(
    String name,
    ByteData? data,
    int identifier,
    SendPort port,
  ) {}

  @override
  void setIsolateDebugName(String name) {}

  @override
  bool get supportsShowingSystemContextMenu => throw UnimplementedError();

  @override
  String? get systemFontFamily => throw UnimplementedError();

  @override
  double get textScaleFactor => throw UnimplementedError();

  @override
  void updateSemantics(SemanticsUpdate update) {}

  @override
  FlutterView? view({required int id}) {
    throw UnimplementedError();
  }

  @override
  Iterable<FlutterView> get views => throw UnimplementedError();
}
