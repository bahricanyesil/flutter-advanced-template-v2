import 'package:log_manager/log_manager.dart';

/// Base class for analytics report manager
abstract class AnalyticsManager {
  /// Create an instance of the analytics manager
  ///
  /// The [logManager] parameter is optional and can be used to enable logging.
  const AnalyticsManager({LogManager? logManager}) : _logManager = logManager;

  /// Logger manager instance, can be null if not used
  final LogManager? _logManager;

  /// Key for the background event
  static const String backgroundEventKey = 'background_event';

  /// Key for the resumed app event
  static const String resumedAppEventKey = 'resumed_app_event';

  /// Initialize the analytics manager
  ///
  /// This method should be implemented to perform any necessary
  /// setup for the analytics manager.
  Future<void> init();

  /// Dispose the analytics manager
  ///
  /// This method should be implemented to clean up any resources
  /// used by the analytics manager.
  void dispose();

  /// Log an app open event
  ///
  /// This method logs an event indicating that the app has been opened.
  Future<void> logAppOpen() async {
    _logManager?.lInfo('Analytics Reported - App Open');
  }

  /// Log an event
  ///
  /// [name] - The name of the event to log.
  /// [parameters] - Optional parameters to include with the event.
  ///
  /// This method logs a custom event with the provided name and parameters.
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    _logManager
        ?.lInfo('Analytics Reported - Event: $name, Parameters: $parameters');
  }

  /// Log a screen view
  ///
  /// [name] - The name of the screen viewed.
  /// [parameters] - Optional parameters to include with the screen view event.
  ///
  /// This method logs a screen view event with the provided
  /// name and parameters.
  Future<void> logScreenView(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    _logManager
        ?.lInfo('Analytics Reported - Screen: $name, Parameters: $parameters');
  }

  /// Log a user login
  ///
  /// [loginMethod] - The method used for user login
  /// (e.g., email, social media).
  /// [parameters] - Optional parameters to include with the login event.
  ///
  /// This method logs a user login event with the provided
  /// login method and parameters.
  Future<void> onLogIn({
    required String loginMethod,
    Map<String, Object>? parameters,
  }) async {
    _logManager?.lInfo('Analytics Reported - User Logged In: $loginMethod');
  }

  /// Log a user sign up
  ///
  /// [signUpMethod] - The method used for user sign up
  /// (e.g., email, social media).
  /// [parameters] - Optional parameters to include with the sign up event.
  ///
  /// This method logs a user sign up event with the
  /// provided sign up method and parameters.
  Future<void> onSignUp({
    required String signUpMethod,
    Map<String, Object>? parameters,
  }) async {
    _logManager?.lInfo('Analytics Reported - User Signed Up: $signUpMethod');
  }

  /// Set the user id
  ///
  /// [userId] - The user ID to set for the analytics reports.
  ///
  /// This method sets the user ID for the analytics reports.
  Future<void> setUserId(String userId) async {
    _logManager?.lInfo('Analytics Reported - User ID: $userId');
  }

  /// Set the user property
  ///
  /// [name] - The name of the user property to set.
  /// [value] - The value of the user property.
  ///
  /// This method sets a user property with the provided name and value.
  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    _logManager?.lInfo('Analytics Reported - User Property: $name: $value');
  }

  /// Log a share event
  ///
  /// [contentType] - The type of content shared (e.g., article, image).
  /// [itemId] - The ID of the item being shared.
  /// [method] - The method used to share the content
  /// (e.g., email, social media).
  /// [parameters] - Optional parameters to include with the share event.
  ///
  /// This method logs a share event with the provided content type,
  /// item ID, method, and parameters.
  Future<void> onShare({
    required String contentType,
    required String itemId,
    required String method,
    Map<String, Object>? parameters,
  }) async {
    _logManager?.lInfo(
      '''Analytics Reported - Share: $contentType, Item: $itemId, Method: $method, Parameters: $parameters''',
    );
  }

  /// Log a purchase event
  ///
  /// [currency] - The currency used for the purchase.
  /// [coupon] - The coupon code applied.
  /// [value] - The value of the purchase.
  /// [tax] - The tax amount for the purchase.
  /// [shipping] - The shipping cost for the purchase.
  /// [transactionId] - The ID of the transaction.
  /// [affiliation] - The affiliation associated with the purchase.
  /// [parameters] - Optional parameters to include with the purchase event.
  ///
  /// This method logs a purchase event with the provided details.
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
    _logManager?.lInfo(
      '''Analytics Reported - Purchase: Currency: $currency, Coupon: $coupon, Value: $value, Tax: $tax, Shipping: $shipping, Transaction ID: $transactionId, Affiliation: $affiliation, Parameters: $parameters''',
    );
  }

  /// Reset the analytics data
  ///
  /// This method should be implemented to reset all analytics data.
  Future<void> resetAnalyticsData();

  /// Enable analytics
  ///
  /// This method should be implemented to enable analytics reporting.
  Future<void> enableAnalytics();

  /// Disable analytics
  ///
  /// This method should be implemented to disable analytics reporting.
  Future<void> disableAnalytics();
}
