import 'package:analytics_manager/analytics_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_firebase_analytics.dart';
import 'mocks/mock_log_manager.dart';

void main() {
  late FirebaseAnalyticsManager analyticsManager;
  late MockFirebaseAnalytics mockFirebaseAnalytics;
  late MockLogManager mockLogManager;
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    mockFirebaseAnalytics = MockFirebaseAnalytics();
    mockLogManager = MockLogManager();

    when(() => mockFirebaseAnalytics.logAppOpen()).thenAnswer((_) async {
      return;
    });
    when(() => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(true))
        .thenAnswer((_) async {
      return;
    });
    analyticsManager = await FirebaseAnalyticsManager.create(
      mockFirebaseAnalytics,
      logManager: mockLogManager,
    );
  });

  group('Firebase Analytics Manager Tests', () {
    test('should initialize analytics and log app open', () async {
      /// Called once in the setUp method
      verify(() => mockFirebaseAnalytics.logAppOpen()).called(1);
      verify(() => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(true))
          .called(1);
    });

    test('should handle app lifecycle changes and log events', () async {
      when(
        () => mockFirebaseAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await analyticsManager
          .didChangeAppLifecycleState(AppLifecycleState.resumed);

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: AnalyticsManager.resumedAppEventKey,
        ),
      ).called(1);

      await analyticsManager
          .didChangeAppLifecycleState(AppLifecycleState.paused);

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: AnalyticsManager.backgroundEventKey,
        ),
      ).called(1);
    });

    test('should log app open events correctly', () async {
      when(() => mockFirebaseAnalytics.logAppOpen()).thenAnswer((_) async {
        return;
      });

      await analyticsManager.logAppOpen();

      /// Called once in the setUp method and once in the logAppOpen method
      verify(() => mockFirebaseAnalytics.logAppOpen()).called(2);
    });

    test('should handle logging app open errors gracefully', () async {
      when(() => mockFirebaseAnalytics.logAppOpen())
          .thenThrow(Exception('Logging error'));
      verifyNever(() => mockLogManager.lError(any()));

      await analyticsManager.logAppOpen();

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should log events correctly', () async {
      when(
        () => mockFirebaseAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await analyticsManager.logEvent(
        'test_event',
        parameters: <String, String>{'param': 'value'},
      );

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: 'test_event',
          parameters: <String, Object>{'param': 'value'},
        ),
      ).called(1);
    });

    test('should handle logging events errors gracefully', () async {
      when(
        () => mockFirebaseAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenThrow(Exception('Logging error'));

      await analyticsManager.logEvent(
        'test_event',
        parameters: <String, String>{'param': 'value'},
      );

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should log screen views correctly', () async {
      when(
        () => mockFirebaseAnalytics.logScreenView(
          screenName: any(named: 'screenName'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await analyticsManager.logScreenView('home_screen');

      verify(
        () => mockFirebaseAnalytics.logScreenView(screenName: 'home_screen'),
      ).called(1);
    });

    test('should handle logging screen view errors gracefully', () async {
      when(
        () => mockFirebaseAnalytics.logScreenView(
          screenName: any(named: 'screenName'),
        ),
      ).thenThrow(Exception('Logging error'));

      await analyticsManager.logScreenView('home_screen');

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should log login events correctly', () async {
      when(
        () => mockFirebaseAnalytics.logLogin(
          loginMethod: any(named: 'loginMethod'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await analyticsManager.onLogIn(loginMethod: 'google');

      verify(() => mockFirebaseAnalytics.logLogin(loginMethod: 'google'))
          .called(1);
    });

    test('should handle logging login events errors gracefully', () async {
      when(
        () => mockFirebaseAnalytics.logLogin(
          loginMethod: any(named: 'loginMethod'),
          parameters: any(named: 'parameters'),
        ),
      ).thenThrow(Exception('Logging error'));

      await analyticsManager.onLogIn(loginMethod: 'google');

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should log sign-up events correctly', () async {
      when(
        () => mockFirebaseAnalytics.logSignUp(
          signUpMethod: any(named: 'signUpMethod'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await analyticsManager.onSignUp(signUpMethod: 'facebook');

      verify(() => mockFirebaseAnalytics.logSignUp(signUpMethod: 'facebook'))
          .called(1);
    });

    test('should handle logging sign-up events errors gracefully', () async {
      when(
        () => mockFirebaseAnalytics.logSignUp(
          signUpMethod: any(named: 'signUpMethod'),
          parameters: any(named: 'parameters'),
        ),
      ).thenThrow(Exception('Logging error'));

      await analyticsManager.onSignUp(signUpMethod: 'facebook');

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should log share events correctly', () async {
      when(
        () => mockFirebaseAnalytics.logShare(
          contentType: any(named: 'contentType'),
          itemId: any(named: 'itemId'),
          method: any(named: 'method'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await analyticsManager.onShare(
        contentType: 'image',
        itemId: 'item_123',
        method: 'email',
      );

      verify(
        () => mockFirebaseAnalytics.logShare(
          contentType: 'image',
          itemId: 'item_123',
          method: 'email',
        ),
      ).called(1);
    });

    test('should handle logging share events errors gracefully', () async {
      when(
        () => mockFirebaseAnalytics.logShare(
          contentType: any(named: 'contentType'),
          itemId: any(named: 'itemId'),
          method: any(named: 'method'),
          parameters: any(named: 'parameters'),
        ),
      ).thenThrow(Exception('Logging error'));

      await analyticsManager.onShare(
        contentType: 'image',
        itemId: 'item_123',
        method: 'email',
      );

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should log purchase events correctly', () async {
      when(
        () => mockFirebaseAnalytics.logPurchase(
          currency: any(named: 'currency'),
          value: any(named: 'value'),
          coupon: any(named: 'coupon'),
          tax: any(named: 'tax'),
          shipping: any(named: 'shipping'),
          transactionId: any(named: 'transactionId'),
          affiliation: any(named: 'affiliation'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await analyticsManager.logPurchase(
        currency: 'USD',
        value: 10,
        coupon: 'DISCOUNT10',
        tax: 1,
        shipping: 2,
        transactionId: 'txn_123',
        affiliation: 'affiliate_456',
      );

      verify(
        () => mockFirebaseAnalytics.logPurchase(
          currency: 'USD',
          value: 10,
          coupon: 'DISCOUNT10',
          tax: 1,
          shipping: 2,
          transactionId: 'txn_123',
          affiliation: 'affiliate_456',
        ),
      ).called(1);
    });

    test('should handle logging purchase events errors gracefully', () async {
      when(
        () => mockFirebaseAnalytics.logPurchase(
          currency: any(named: 'currency'),
          value: any(named: 'value'),
          coupon: any(named: 'coupon'),
          tax: any(named: 'tax'),
          shipping: any(named: 'shipping'),
          transactionId: any(named: 'transactionId'),
          affiliation: any(named: 'affiliation'),
          parameters: any(named: 'parameters'),
        ),
      ).thenThrow(Exception('Logging error'));

      await analyticsManager.logPurchase(
        currency: 'USD',
        value: 10,
        coupon: 'DISCOUNT10',
        tax: 1,
        shipping: 2,
        transactionId: 'txn_123',
        affiliation: 'affiliate_456',
      );

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should set user ID correctly', () async {
      when(() => mockFirebaseAnalytics.setUserId(id: any(named: 'id')))
          .thenAnswer((_) async {
        return;
      });

      await analyticsManager.setUserId('user_123');

      verify(() => mockFirebaseAnalytics.setUserId(id: 'user_123')).called(1);
    });

    test('should handle setting user ID errors gracefully', () async {
      when(() => mockFirebaseAnalytics.setUserId(id: any(named: 'id')))
          .thenThrow(Exception('Setting user ID error'));

      await analyticsManager.setUserId('user_123');

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should set user properties correctly', () async {
      when(
        () => mockFirebaseAnalytics.setUserProperty(
          name: any(named: 'name'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await analyticsManager.setUserProperty(
        name: 'property_name',
        value: 'property_value',
      );

      verify(
        () => mockFirebaseAnalytics.setUserProperty(
          name: 'property_name',
          value: 'property_value',
        ),
      ).called(1);
    });

    test('should handle setting user properties errors gracefully', () async {
      when(
        () => mockFirebaseAnalytics.setUserProperty(
          name: any(named: 'name'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('Setting user property error'));

      await analyticsManager.setUserProperty(
        name: 'property_name',
        value: 'property_value',
      );

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should reset analytics data correctly', () async {
      when(() => mockFirebaseAnalytics.resetAnalyticsData())
          .thenAnswer((_) async {
        return;
      });

      await analyticsManager.resetAnalyticsData();

      verify(() => mockFirebaseAnalytics.resetAnalyticsData()).called(1);
    });

    test('should handle resetting analytics data errors gracefully', () async {
      when(() => mockFirebaseAnalytics.resetAnalyticsData())
          .thenThrow(Exception('Resetting analytics data error'));

      await analyticsManager.resetAnalyticsData();

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should enable analytics correctly', () async {
      await analyticsManager.enableAnalytics();

      /// Once it is called in the setUp method
      /// and once in the enableAnalytics method
      verify(() => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(true))
          .called(2);
    });

    test('should handle enabling analytics errors gracefully', () async {
      when(() => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(true))
          .thenThrow(Exception('Enabling analytics error'));

      await analyticsManager.enableAnalytics();

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should disable analytics correctly', () async {
      when(() => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(false))
          .thenAnswer((_) async {
        return;
      });

      await analyticsManager.disableAnalytics();

      verify(() => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(false))
          .called(1);
    });

    test('should handle disabling analytics errors gracefully', () async {
      when(() => mockFirebaseAnalytics.setAnalyticsCollectionEnabled(false))
          .thenThrow(Exception('Disabling analytics error'));

      await analyticsManager.disableAnalytics();

      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('should dispose correctly', () async {
      analyticsManager.dispose();
      verify(() => mockLogManager.lInfo('Firebase Analytics Manager disposed'))
          .called(1);
    });
  });
}
