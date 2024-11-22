import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:key_value_storage_manager/key_value_storage_manager.dart';
import 'package:log_manager/log_manager.dart';

import 'analytics_manager.dart';

/// A manager class that handles analytics using Firebase Analytics.
/// This class implements the [AnalyticsManager] interface and
/// extends the [WidgetsBindingObserver] class.
/// It provides methods for initializing the analytics, logging events,
/// and logging screen views.
@immutable
class FirebaseAnalyticsManager extends AnalyticsManager
    with WidgetsBindingObserver {
  const FirebaseAnalyticsManager._(
    this._analytics,
    LogManager? logManager,
    this._keyValueStorageManager,
  ) : super(logManager: logManager);

  final FirebaseAnalytics _analytics;
  final KeyValueStorageManager? _keyValueStorageManager;

  static const String _analyticsEnabledKey = 'analytics_enabled';

  /// Creates a new instance of [FirebaseAnalyticsManager].
  ///
  /// [analyticsParam] - The FirebaseAnalytics instance.
  /// [logManager] - The LogManager instance.
  /// [keyValueStorageManager] - The KeyValueStorageManager instance.
  static Future<FirebaseAnalyticsManager> create(
    FirebaseAnalytics analyticsParam, {
    LogManager? logManager,
    KeyValueStorageManager? keyValueStorageManager,
  }) async {
    final FirebaseAnalyticsManager instance = FirebaseAnalyticsManager._(
      analyticsParam,
      logManager,
      keyValueStorageManager,
    );
    await instance.init();
    return instance;
  }

  /// Initializes the analytics by logging the app open event
  /// and adding the observer to [WidgetsBinding].
  @override
  Future<void> init() async {
    await enableAnalytics();
    await logAppOpen();
    _bindLifecycleListener();
    logManager?.lInfo('Firebase Analytics Manager initialized');
  }

  /// Disposes the observer from [WidgetsBinding].
  @override
  void dispose() {
    _unbindLifecycleListener();
    logManager?.lInfo('Firebase Analytics Manager disposed');
  }

  void _bindLifecycleListener() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _unbindLifecycleListener() {
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Handles changes in the app lifecycle state.
  /// Logs events when the app is resumed or paused.
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await logEvent(AnalyticsManager.resumedAppEventKey);
      case AppLifecycleState.paused:
        await logEvent(AnalyticsManager.backgroundEventKey);
      default:
        break;
    }
  }

  /// Checks if analytics is enabled by checking the key value storage
  /// and the platform support.
  Future<bool> isAnalyticsEnabled() async {
    try {
      final bool isEnabled =
          _keyValueStorageManager?.read<bool>(_analyticsEnabledKey) ?? true;
      if (!isEnabled) {
        logManager?.lInfo('Analytics is disabled via storage');
        return false;
      }

      final bool isSupported = await _analytics.isSupported();
      if (!isSupported) {
        logManager?.lInfo('Analytics is not supported on this platform');
        return false;
      }

      return true;
    } catch (e) {
      logManager?.lError('Failed to check analytics status: $e');
      return false;
    }
  }

  @override
  Future<void> enableAnalytics() async {
    try {
      await _keyValueStorageManager?.write<bool>(
        key: _analyticsEnabledKey,
        value: true,
      );
      await _analytics.setAnalyticsCollectionEnabled(true);
      logManager?.lInfo('Analytics enabled');
    } catch (e) {
      logManager?.lError('Failed to enable analytics: $e');
    }
  }

  @override
  Future<void> disableAnalytics() async {
    try {
      await _keyValueStorageManager?.write<bool>(
        key: _analyticsEnabledKey,
        value: false,
      );
      await _analytics.setAnalyticsCollectionEnabled(false);
      logManager?.lInfo('Analytics disabled');
    } catch (e) {
      logManager?.lError('Failed to disable analytics: $e');
    }
  }

  @override
  Future<void> logAppOpen() async {
    await _executeAnalyticsOperation(
      operationName: 'logAppOpen',
      operation: () async {
        await _analytics.logAppOpen();
        await super.logAppOpen();
      },
    );
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _executeAnalyticsOperation(
      operationName: 'logEvent($name)',
      operation: () async {
        await _analytics.logEvent(name: name, parameters: parameters);
        await super.logEvent(name, parameters: parameters);
      },
    );
  }

  @override
  Future<void> logScreenView(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    await _executeAnalyticsOperation(
      operationName: 'logScreenView($name)',
      operation: () async {
        await _analytics.logScreenView(screenName: name);
        await super.logScreenView(name, parameters: parameters);
      },
    );
  }

  @override
  Future<void> onLogIn({
    String loginMethod = 'email',
    Map<String, Object>? parameters,
  }) async {
    await _executeAnalyticsOperation(
      operationName: 'onLogIn($loginMethod)',
      operation: () async {
        await _analytics.logLogin(
          loginMethod: loginMethod,
          parameters: parameters,
        );
        await super.onLogIn(loginMethod: loginMethod, parameters: parameters);
      },
    );
  }

  @override
  Future<void> onSignUp({
    String signUpMethod = 'email',
    Map<String, Object>? parameters,
  }) async {
    await _executeAnalyticsOperation(
      operationName: 'onSignUp($signUpMethod)',
      operation: () async {
        await _analytics.logSignUp(
          signUpMethod: signUpMethod,
          parameters: parameters,
        );
        await super
            .onSignUp(signUpMethod: signUpMethod, parameters: parameters);
      },
    );
  }

  @override
  Future<void> onShare({
    required String contentType,
    required String itemId,
    required String method,
    Map<String, Object>? parameters,
  }) async {
    await _executeAnalyticsOperation(
      operationName: 'onShare($contentType, $itemId, $method)',
      operation: () async {
        await _analytics.logShare(
          contentType: contentType,
          itemId: itemId,
          method: method,
          parameters: parameters,
        );
        await super.onShare(
          contentType: contentType,
          itemId: itemId,
          method: method,
          parameters: parameters,
        );
      },
    );
  }

  @override
  Future<void> logPurchase({
    String? currency,
    String? coupon,
    double? value,
    double? tax,
    double? shipping,
    String? transactionId,
    String? affiliation,
    Map<String, Object>? parameters,
  }) async {
    await _executeAnalyticsOperation(
      operationName: 'logPurchase',
      operation: () async {
        await _analytics.logPurchase(
          currency: currency,
          value: value,
          coupon: coupon,
          tax: tax,
          shipping: shipping,
          transactionId: transactionId,
          affiliation: affiliation,
          parameters: parameters,
        );
        await super.logPurchase(
          currency: currency,
          coupon: coupon,
          value: value,
          tax: tax,
          shipping: shipping,
          transactionId: transactionId,
          affiliation: affiliation,
          parameters: parameters,
        );
      },
    );
  }

  @override
  Future<void> setUserId(String userId) async {
    await _executeAnalyticsOperation(
      operationName: 'setUserId($userId)',
      operation: () async {
        await _analytics.setUserId(id: userId);
        await super.setUserId(userId);
      },
    );
  }

  @override
  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    await _executeAnalyticsOperation(
      operationName: 'setUserProperty($name: $value)',
      operation: () async {
        await _analytics.setUserProperty(name: name, value: value);
        await super.setUserProperty(name: name, value: value);
      },
    );
  }

  @override
  Future<void> resetAnalyticsData() async {
    await _executeAnalyticsOperation(
      operationName: 'resetAnalyticsData',
      operation: () async {
        await _analytics.resetAnalyticsData();
        logManager?.lInfo('Analytics data reset');
      },
    );
  }

  Future<void> _executeAnalyticsOperation({
    required String operationName,
    required Future<void> Function() operation,
  }) async {
    try {
      final bool isEnabled = await isAnalyticsEnabled();
      if (!isEnabled) {
        logManager?.lInfo('Analytics is disabled, skipping $operationName');
        return;
      }
      await operation();
    } catch (e) {
      logManager?.lError('Failed to execute $operationName: $e');
    }
  }
}
