import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
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
  /// Creates an instance of [FirebaseAnalyticsManager].
  /// [logManager] is optional and can be null if logging is not used.
  const FirebaseAnalyticsManager._(this._analytics, LogManager? logManager)
      : super(logManager: logManager);

  /// Firebase analytics instance
  final FirebaseAnalytics _analytics;

  /// Factory method to create an instance of [FirebaseAnalyticsManager].
  /// It takes a [FirebaseAnalytics] parameter and returns
  /// a future of [FirebaseAnalyticsManager].
  static Future<FirebaseAnalyticsManager> create(
    FirebaseAnalytics analyticsParam,
    LogManager? logManager,
  ) async {
    final FirebaseAnalyticsManager instance =
        FirebaseAnalyticsManager._(analyticsParam, logManager);
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

  @override
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      logManager?.lError('Failed to log app open event: $e');
    }
    await super.logAppOpen();
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      logManager
          ?.lError('Failed to log event: $name, parameters: $parameters: $e');
    }
    await super.logEvent(name, parameters: parameters);
  }

  @override
  Future<void> logScreenView(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logScreenView(screenName: name);
    } catch (e) {
      logManager?.lError(
        'Failed to log screen view: $name, parameters: $parameters: $e',
      );
    }
    await super.logScreenView(name, parameters: parameters);
  }

  @override
  Future<void> onLogIn({
    String loginMethod = 'email',
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logLogin(
        loginMethod: loginMethod,
        parameters: parameters,
      );
    } catch (e) {
      logManager?.lError(
        'Failed to log login event: $loginMethod, parameters: $parameters: $e',
      );
    }
    await super.onLogIn(loginMethod: loginMethod, parameters: parameters);
  }

  @override
  Future<void> onSignUp({
    String signUpMethod = 'email',
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logSignUp(
        signUpMethod: signUpMethod,
        parameters: parameters,
      );
    } catch (e) {
      logManager?.lError(
        '''Failed to log sign-up event: $signUpMethod, parameters: $parameters: $e''',
      );
    }
    await super.onSignUp(signUpMethod: signUpMethod, parameters: parameters);
  }

  @override
  Future<void> onShare({
    required String contentType,
    required String itemId,
    required String method,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: method,
        parameters: parameters,
      );
    } catch (e) {
      logManager?.lError(
        '''Failed to log share event: contentType: $contentType, itemId: $itemId, method: $method, parameters: $parameters: $e''',
      );
    }
    await super.onShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
      parameters: parameters,
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
    try {
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
    } catch (e) {
      logManager?.lError(
        '''Failed to log purchase event: currency: $currency, value: $value, coupon: $coupon, tax: $tax, shipping: $shipping, transactionId: $transactionId, affiliation: $affiliation, parameters: $parameters: $e''',
      );
    }
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
  }

  @override
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      logManager?.lError('Failed to set user ID: $userId: $e');
    }
    await super.setUserId(userId);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      logManager?.lError('Failed to set user property: $name: $value: $e');
    }
    await super.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();
    } catch (e) {
      logManager?.lError('Failed to reset analytics data: $e');
    }
  }

  @override
  Future<void> enableAnalytics() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
    } catch (e) {
      logManager?.lError('Failed to enable analytics: $e');
    }
  }

  @override
  Future<void> disableAnalytics() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(false);
    } catch (e) {
      logManager?.lError('Failed to disable analytics: $e');
    }
  }
}
