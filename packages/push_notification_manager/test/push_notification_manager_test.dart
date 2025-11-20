import 'package:firebase_messaging/firebase_messaging.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart'
    as firebase_messaging_platform_interface;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:push_notification_manager/push_notification_manager.dart';

import 'mocks/mock_firebase_messaging.dart';
import 'mocks/mock_log_manager.dart';

void main() {
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockLogManager mockLogManager;
  late PushNotificationManager pushNotificationManager;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    mockFirebaseMessaging = MockFirebaseMessaging();
    mockLogManager = MockLogManager();
    const NotificationSettings enabledNotificationSettings =
        NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.enabled,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.enabled,
      criticalAlert: AppleNotificationSetting.enabled,
      sound: AppleNotificationSetting.enabled,
      timeSensitive: AppleNotificationSetting.enabled,
      authorizationStatus: AuthorizationStatus.provisional,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      providesAppNotificationSettings: AppleNotificationSetting.enabled,
    );

    when(() => mockFirebaseMessaging.getNotificationSettings())
        .thenAnswer((_) async => enabledNotificationSettings);

    when(() => mockFirebaseMessaging.requestPermission())
        .thenAnswer((_) async => enabledNotificationSettings);

    when(
      () => mockFirebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      ),
    ).thenAnswer(
      (_) async => <String, dynamic>{
        'alert': true,
        'badge': true,
        'sound': true,
      },
    );

    pushNotificationManager = await FirebasePushNotificationManager.create(
      firebaseMessaging: mockFirebaseMessaging,
      logManager: mockLogManager,
      onMessageCallback: (Map<String, dynamic> msg) {},
      onMessageOpenedAppCallback: (Map<String, dynamic> msg) {},
    );
  });

  group('FirebasePushNotificationManager', () {
    test('initialize', () async {
      await pushNotificationManager.initialize();
      verify(() => mockFirebaseMessaging.requestPermission()).called(1);
      verify(() => mockFirebaseMessaging.getNotificationSettings()).called(1);
      verify(
        () =>
            mockFirebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        ),
      ).called(1);
      expect(pushNotificationManager.hasPermission, isTrue);
    });

    test('requestPermission updates permission status', () async {
      await pushNotificationManager.requestPermission();
      expect(pushNotificationManager.hasPermission, isTrue);
      verify(() => mockLogManager.lDebug('Permission status updated: true'))
          .called(1);
    });

    test('getToken retrieves token', () async {
      when(() => mockFirebaseMessaging.getToken())
          .thenAnswer((_) async => 'mockToken');
      final String? token = await pushNotificationManager.getToken();
      expect(token, 'mockToken');
      verify(() => mockLogManager.lDebug('FirebaseMessaging token: mockToken'))
          .called(1);
    });

    test('subscribeToTopic with permission', () async {
      when(() => mockFirebaseMessaging.subscribeToTopic(any()))
          .thenAnswer((_) async => Future<void>.value());

      await pushNotificationManager.checkAndUpdatePermissionStatus();
      await pushNotificationManager.subscribeToTopic('testTopic');
      verify(() => mockFirebaseMessaging.subscribeToTopic('testTopic'))
          .called(1);
    });

    test('subscribeToTopic without permission', () async {
      await pushNotificationManager.subscribeToTopic('testTopic');
      expect(pushNotificationManager.hasPermission, isFalse);
      verifyNever(() => mockFirebaseMessaging.subscribeToTopic('testTopic'));
    });

    test('unsubscribeFromTopic with permission', () async {
      when(() => mockFirebaseMessaging.unsubscribeFromTopic(any()))
          .thenAnswer((_) async => Future<void>.value());

      await pushNotificationManager.checkAndUpdatePermissionStatus();
      await pushNotificationManager.unsubscribeFromTopic('testTopic');
      verify(() => mockFirebaseMessaging.unsubscribeFromTopic('testTopic'))
          .called(1);
    });

    // test('unsubscribeFromTopic without permission', () async {
    //   when(() => mockPermissionManager.checkAndRequestPermission(any()))
    //       .thenAnswer((_) async => PermissionStatusTypes.denied);
    //   await pushNotificationManager.requestPermission();
    //   await pushNotificationManager.unsubscribeFromTopic('testTopic');
    //   expect(pushNotificationManager.hasPermission, isFalse);
    //   verifyNever(
    //     () => mockFirebaseMessaging.unsubscribeFromTopic('testTopic'),
    //   );
    // });

    test('checkAndUpdatePermissionStatus updates permission status', () async {
      await pushNotificationManager.checkAndUpdatePermissionStatus();
      expect(pushNotificationManager.hasPermission, isTrue);
      verify(() => mockLogManager.lDebug('Permission status checked: true'))
          .called(1);
    });

    test('onMessage listener is triggered', () async {
      final Map<String, dynamic> messageData = <String, dynamic>{
        'key': 'value',
      };
      const RemoteNotification remoteNotification = RemoteNotification(
        title: 'Test Title',
        body: 'Test Body',
      );
      final RemoteMessage remoteMessage = RemoteMessage(
        data: messageData,
        notification: remoteNotification,
      );

      await pushNotificationManager
          .setOnMessageListener((Map<String, dynamic> msg) {
        expect(msg, dataToListenedMessage(messageData, remoteNotification));
      });

      // Simulate receiving a message
      firebase_messaging_platform_interface.FirebaseMessagingPlatform.onMessage
          .add(remoteMessage);

      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    test('onMessageOpenedApp listener is triggered', () async {
      final Map<String, dynamic> messageData = <String, dynamic>{
        'test_key': 'test_value',
      };
      const RemoteNotification remoteNotification = RemoteNotification(
        title: 'Opened Notification',
        body: 'Notification opened by user',
      );
      final RemoteMessage remoteMessage = RemoteMessage(
        data: messageData,
        notification: remoteNotification,
      );

      await pushNotificationManager
          .setOnMessageOpenedAppListener((Map<String, dynamic> msg) {
        expect(msg, dataToListenedMessage(messageData, remoteNotification));
      });

      firebase_messaging_platform_interface
          .FirebaseMessagingPlatform.onMessageOpenedApp
          .add(remoteMessage);

      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    test('setOnBackgroundMessageListener is triggered', () async {
      final Map<String, dynamic> messageData = <String, dynamic>{
        'key': 'value',
      };
      const RemoteNotification remoteNotification = RemoteNotification(
        title: 'Test Title',
        body: 'Test Body',
      );
      final RemoteMessage remoteMessage = RemoteMessage(
        data: messageData,
        notification: remoteNotification,
      );

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      pushNotificationManager
          .setOnBackgroundMessageListener((Map<String, dynamic> msg) {
        expect(msg, dataToListenedMessage(messageData, remoteNotification));
      });

      await firebase_messaging_platform_interface
          .FirebaseMessagingPlatform.onBackgroundMessage
          ?.call(remoteMessage);

      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  });
}

Map<String, dynamic> dataToListenedMessage(
  Map<String, dynamic> data,
  RemoteNotification? notification,
) {
  return <String, dynamic>{
    'data': data,
    'notification': notification,
    'title': notification?.title,
    'body': notification?.body,
    'messageId': null,
    'sentTime': null,
    'ttl': null,
  };
}
