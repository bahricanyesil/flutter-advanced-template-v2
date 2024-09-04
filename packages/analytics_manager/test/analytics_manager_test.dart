import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_analytics_manager.dart';
import 'mocks/mock_log_manager.dart';

void main() {
  late MockAnalyticsManager analyticsManager;
  late MockLogManager logManager;

  setUp(() {
    logManager = MockLogManager();
    analyticsManager = MockAnalyticsManager(logManager: logManager);
  });

  group('Event Logging Tests', () {
    test('should log app open event', () async {
      await analyticsManager.logAppOpen();
      verify(() => logManager.lInfo('Analytics Reported - App Open')).called(1);
    });

    test('should log custom event', () async {
      final Map<String, Object> params = <String, Object>{'key': 'value'};
      await analyticsManager.logEvent('test_event', parameters: params);
      const String expectedLog =
          'Analytics Reported - Event: test_event, Parameters: {key: value}';
      verify(() => logManager.lInfo(expectedLog)).called(1);
    });

    test('should log screen view', () async {
      final Map<String, Object> params = <String, Object>{'key': 'value'};
      await analyticsManager.logScreenView('test_screen', parameters: params);
      verify(
        () => logManager.lInfo(
          'Analytics Reported - Screen: test_screen, Parameters: {key: value}',
        ),
      ).called(1);
    });

    test('should log login event', () async {
      await analyticsManager.onLogIn(loginMethod: 'email');
      verify(
        () => logManager.lInfo('Analytics Reported - User Logged In: email'),
      ).called(1);
    });

    test('should log sign-up event', () async {
      await analyticsManager.onSignUp(signUpMethod: 'email');
      verify(
        () => logManager.lInfo('Analytics Reported - User Signed Up: email'),
      ).called(1);
    });

    test('should log share event', () async {
      await analyticsManager.onShare(
        contentType: 'article',
        itemId: '123',
        method: 'email',
      );
      const String expectedLog =
          '''Analytics Reported - Share: article, Item: 123, Method: email, Parameters: null''';
      verify(() => logManager.lInfo(expectedLog)).called(1);
    });

    test('should log purchase event', () async {
      await analyticsManager.logPurchase(
        currency: 'USD',
        value: 10,
        transactionId: 'txn_123',
      );
      const String expectedLog =
          '''Analytics Reported - Purchase: Currency: USD, Coupon: null, Value: 10.0, Tax: null, Shipping: null, Transaction ID: txn_123, Affiliation: null, Parameters: null''';
      verify(() => logManager.lInfo(expectedLog)).called(1);
    });

    test('should set user ID', () async {
      await analyticsManager.setUserId('user_123');
      verify(() => logManager.lInfo('Analytics Reported - User ID: user_123'))
          .called(1);
    });

    test('should set user property', () async {
      await analyticsManager.setUserProperty(
        name: 'property_name',
        value: 'value',
      );
      verify(
        () => logManager.lInfo(
          'Analytics Reported - User Property: property_name: value',
        ),
      ).called(1);
    });
  });

  group('LogManager Tests', () {
    test('should log information', () {
      logManager.lInfo('Test log message');
      verify(() => logManager.lInfo('Test log message')).called(1);
    });

    test('should handle multiple log messages', () {
      logManager
        ..lInfo('First log message')
        ..lInfo('Second log message');
      verify(() => logManager.lInfo('First log message')).called(1);
      verify(() => logManager.lInfo('Second log message')).called(1);
    });

    test('should get the correct LogManager instance', () {
      expect(analyticsManager.logManager, equals(logManager));
    });
  });
}
