import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../analytics_manager.dart';
import '../logger/log_manager.dart';

/// A manager class that handles analytics using Firebase Analytics.
/// This class implements the [AnalyticsManager] interface and
/// extends the [WidgetsBindingObserver] class.
/// It provides methods for initializing the analytics, logging events,
/// and logging screen views.
@immutable
class FirebaseAnalyticsManager extends AnalyticsManager
    with WidgetsBindingObserver {
  FirebaseAnalyticsManager._(this._analytics, super._logManager);

  /// Firebase analytics instance
  final FirebaseAnalytics _analytics;

  /// Factory method to create an instance of [FirebaseAnalyticsManager].
  /// It takes a [FirebaseAnalytics] parameter and returns
  /// a future of [FirebaseAnalyticsManager].
  static Future<FirebaseAnalyticsManager> create(
    FirebaseAnalytics analyticsParam,
  ) async {
    final GetIt getIt = GetIt.instance;
    final LogManager logManager = getIt<LogManager>();
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
    WidgetsBinding.instance.addObserver(this);
  }

  /// Disposes the observer from [WidgetsBinding].
  @override
  void dispose() => WidgetsBinding.instance.removeObserver(this);

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await logEvent(AnalyticsManager.resumedAppEventKey);
    } else if (state == AppLifecycleState.paused) {
      await logEvent(AnalyticsManager.backgroundEventKey);
    }
  }

  @override
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
    await super.logAppOpen();
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
    await super.logEvent(name, parameters: parameters);
  }

  @override
  Future<void> logScreenView(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logScreenView(screenName: name);
    await super.logScreenView(name, parameters: parameters);
  }

  @override
  Future<void> onLogIn({
    String loginMethod = 'email',
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logLogin(loginMethod: loginMethod, parameters: parameters);
    await super.onLogIn(loginMethod: loginMethod, parameters: parameters);
  }

  @override
  Future<void> onSignUp({
    String signUpMethod = 'email',
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logSignUp(
      signUpMethod: signUpMethod,
      parameters: parameters,
    );
    await super.onSignUp(signUpMethod: signUpMethod, parameters: parameters);
  }

  @override
  Future<void> onShare({
    required String contentType,
    required String itemId,
    required String method,
    Map<String, Object>? parameters,
  }) async {
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
  }

  @override
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    await super.setUserId(userId);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
    await super.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> resetAnalyticsData() async => _analytics.resetAnalyticsData();

  @override
  Future<void> enableAnalytics() async =>
      _analytics.setAnalyticsCollectionEnabled(true);

  @override
  Future<void> disableAnalytics() async =>
      _analytics.setAnalyticsCollectionEnabled(false);
}
