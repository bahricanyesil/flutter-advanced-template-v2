import 'package:flutter/foundation.dart';

import '../logger/log_manager.dart';

/// Base class for analytics report manager
abstract class AnalyticsManager {
  /// Create an instance of the analytics manager
  const AnalyticsManager(this._logManager);

  /// Logger manager instance
  final LogManager _logManager;

  /// Background event name
  static const String backgroundEventKey = 'background_event';

  /// Resumed app event name
  static const String resumedAppEventKey = 'resumed_app_event';

  /// Initialize the analytics manager
  Future<void> init();

  /// Dispose the analytics manager
  void dispose();

  /// Log an app open event
  @mustCallSuper
  Future<void> logAppOpen() async {
    _logManager.lInfo('Analytics Reported - App Open');
  }

  /// Log an event
  @mustCallSuper
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    _logManager
        .lInfo('Analytics Reported - Event: $name, Parameters: $parameters');
  }

  /// Log a screen view
  @mustCallSuper
  Future<void> logScreenView(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    _logManager
        .lInfo('Analytics Reported - Screen: $name, Parameters: $parameters');
  }

  /// Log a user login
  @mustCallSuper
  Future<void> onLogIn({
    required String loginMethod,
    Map<String, Object>? parameters,
  }) async {
    _logManager.lInfo('Analytics Reported - User Logged In: $loginMethod');
  }

  /// Log a user sign up
  @mustCallSuper
  Future<void> onSignUp({
    required String signUpMethod,
    Map<String, Object>? parameters,
  }) async {
    _logManager.lInfo('Analytics Reported - User Signed Up: $signUpMethod');
  }

  /// Set the user id
  @mustCallSuper
  Future<void> setUserId(String userId) async {
    _logManager.lInfo('Analytics Reported - User ID: $userId');
  }

  /// Set the user property
  @mustCallSuper
  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    _logManager.lInfo('Analytics Reported - User Property: $name: $value');
  }

  /// Log a share event
  @mustCallSuper
  Future<void> onShare({
    required String contentType,
    required String itemId,
    required String method,
    Map<String, Object>? parameters,
  }) async {
    _logManager.lInfo(
      '''Analytics Reported - Share: $contentType, Item: $itemId, Method: $method, Parameters: $parameters''',
    );
  }

  /// Log a purchase event
  @mustCallSuper
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
    _logManager.lInfo(
      '''Analytics Reported - Purchase: Currency: $currency, Coupon: $coupon, Value: $value, Tax: $tax, Shipping: $shipping, Transaction ID: $transactionId, Affiliation: $affiliation, Parameters: $parameters''',
    );
  }

  /// Reset the analytics data
  Future<void> resetAnalyticsData();

  /// Enable analytics
  Future<void> enableAnalytics();

  /// Disable analytics
  Future<void> disableAnalytics();
}
