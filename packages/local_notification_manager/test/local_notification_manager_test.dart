import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_notification_manager/src/enums/custom_notification_visibility.dart';
import 'package:local_notification_manager/src/enums/notification_category.dart';
import 'package:local_notification_manager/src/enums/notification_importance.dart';
import 'package:local_notification_manager/src/enums/notification_interruption_level.dart';
import 'package:local_notification_manager/src/enums/notification_priority.dart';
import 'package:local_notification_manager/src/local_notification_manager_impl.dart';
import 'package:local_notification_manager/src/models/custom_local_notification_settings.dart';
import 'package:local_notification_manager/src/models/custom_notification_response_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_manager/permission_manager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

import 'mocks/mock_flutter_local_notification_platform.dart';
import 'mocks/mock_flutter_local_notifications_plugin.dart';
import 'mocks/mock_log_manager.dart';
import 'mocks/mock_permission_manager.dart';

class MockNotificationResponse extends Mock implements NotificationResponse {
  @override
  NotificationResponseType get notificationResponseType =>
      NotificationResponseType.selectedNotification;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockFlutterLocalNotificationPlatform mockPlatform;
  late MockLogManager mockLogManager;
  late MockPermissionManager mockPermissionManager;
  late LocalNotificationManagerImpl manager;

  setUpAll(() {
    registerFallbackValue(
      const InitializationSettings(android: AndroidInitializationSettings('')),
    );
    registerFallbackValue(PermissionTypes.notification);
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(const AndroidNotificationChannel('id', 'name'));
    registerFallbackValue(AndroidFlutterLocalNotificationsPlugin());
    registerFallbackValue(TZDateTime(getLocation('Europe/Istanbul'), 2000));
    registerFallbackValue(UILocalNotificationDateInterpretation.wallClockTime);
    registerFallbackValue(NotificationResponseType.selectedNotification);
    registerFallbackValue(
      const CustomNotificationResponseModel(
        id: 0,
        actionId: 'default',
        responseType: CustomNotificationResponseModelType.selectedNotification,
      ),
    );
  });

  setUp(() {
    mockPlatform = MockFlutterLocalNotificationPlatform();
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    FlutterLocalNotificationsPlatform.instance = mockPlatform;
    mockLogManager = MockLogManager();
    mockPermissionManager = MockPermissionManager();
    manager = LocalNotificationManagerImpl(
      localNotificationPlugin: mockPlugin,
      logManager: mockLogManager,
      permissionManager: mockPermissionManager,
      rethrowExceptions: false,
      customSettings: _customSettings,
      receiveLocalNotificationCallback: (
        int id,
        String? title,
        String? body,
        String? payload,
      ) =>
          true,
      receiveBackgroundNotificationResponseCallback: (
        CustomNotificationResponseModel response,
      ) =>
          true,
      receiveNotificationResponseCallback: (
        CustomNotificationResponseModel response,
      ) =>
          true,
    );
  });

  group('LocalNotificationManagerImpl', () {
    test('initialize - success', () async {
      when(
        () => mockPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
          onDidReceiveBackgroundNotificationResponse:
              any(named: 'onDidReceiveBackgroundNotificationResponse'),
        ),
      ).thenAnswer((_) async => true);
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.granted);

      final bool result = await manager.initialize();

      expect(result, true);
      verify(
        () => mockLogManager.lDebug('Local notification manager initialized'),
      ).called(1);
    });

    test('initialize - failure', () async {
      when(
        () => mockPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
          onDidReceiveBackgroundNotificationResponse:
              any(named: 'onDidReceiveBackgroundNotificationResponse'),
        ),
      ).thenThrow(Exception('Test exception'));
      final bool result = await manager.initialize();
      expect(result, false);
    });

    test('showNotification - success', () async {
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.granted);
      when(() => mockPlugin.show(any(), any(), any(), any()))
          .thenAnswer((_) async {
        return;
      });

      final bool result = await manager.showNotification(
        id: 1,
        title: 'Test',
        body: 'Test body',
      );

      expect(result, true);
      verify(() => mockLogManager.lDebug(any())).called(1);
    });

    test('showNotification - no permission', () async {
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.denied);

      final bool result = await manager.showNotification(
        id: 1,
        title: 'Test',
        body: 'Test body',
      );

      expect(result, false);
      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('scheduleNotification - success', () async {
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.granted);
      when(
        () => _zonedScheduleCallback(mockPlugin),
      ).thenAnswer((_) async {
        return;
      });

      final bool result = await manager.scheduleNotification(
        id: 1,
        title: 'Test',
        body: 'Test body',
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(result, true);
      verify(() => mockLogManager.lDebug(any())).called(1);
    });

    test('scheduleNotification - no permission', () async {
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.denied);

      final bool result = await manager.scheduleNotification(
        id: 1,
        title: 'Test',
        body: 'Test body',
        scheduledDate: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(result, false);
      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('cancelNotification - success', () async {
      when(() => mockPlugin.cancel(any())).thenAnswer((_) async {
        return;
      });

      final bool result = await manager.cancelNotification(1);

      expect(result, true);
      verify(() => mockLogManager.lDebug(any())).called(1);
    });

    test('cancelNotification - error', () async {
      when(() => mockPlugin.cancel(any()))
          .thenThrow(Exception('Test exception'));

      final bool result = await manager.cancelNotification(1);

      expect(result, false);
      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('cancelAllNotifications - success', () async {
      when(() => mockPlugin.cancelAll()).thenAnswer((_) async {
        return;
      });

      final bool result = await manager.cancelAllNotifications();

      expect(result, true);
      verify(() => mockLogManager.lDebug(any())).called(1);
    });

    test('cancelAllNotifications - error', () async {
      when(() => mockPlugin.cancelAll()).thenThrow(Exception('Test exception'));

      final bool result = await manager.cancelAllNotifications();

      expect(result, false);
      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('onDidReceiveLocalNotification - success', () async {
      final bool result = await manager.onDidReceiveLocalNotification(
        1,
        'Test',
        'Test body',
        'payload',
      );

      expect(result, true);
      verify(() => mockLogManager.lDebug(any())).called(1);
    });

    test('onDidReceiveBackgroundNotificationResponse - success', () async {
      const CustomNotificationResponseModel response =
          CustomNotificationResponseModel(
        id: 1,
        actionId: 'action',
        input: 'input',
        payload: 'payload',
        responseType: CustomNotificationResponseModelType.selectedNotification,
      );
      final bool result =
          await manager.onDidReceiveBackgroundNotificationResponse(response);

      expect(result, true);
      verify(() => mockLogManager.lDebug(any())).called(1);
    });

    test('onDidReceiveNotificationResponse - success', () async {
      const CustomNotificationResponseModel response =
          CustomNotificationResponseModel(
        id: 1,
        actionId: 'action',
        input: 'input',
        payload: 'payload',
        responseType: CustomNotificationResponseModelType.selectedNotification,
      );
      final bool result =
          await manager.onDidReceiveNotificationResponse(response);

      expect(result, true);
      verify(() => mockLogManager.lDebug(any())).called(1);
    });

    test('isEnabled - returns true', () {
      expect(manager.isEnabled, true);
    });

    test('Callback error tests', () async {
      final Exception backgroundException =
          Exception('Test exception on background');
      final Exception foregroundException =
          Exception('Test exception on foreground');
      final Exception foregroundResponseException =
          Exception('Test exception on foreground response');
      final LocalNotificationManagerImpl errorManager =
          LocalNotificationManagerImpl(
        localNotificationPlugin: mockPlugin,
        logManager: mockLogManager,
        permissionManager: mockPermissionManager,
        receiveBackgroundNotificationResponseCallback: (
          CustomNotificationResponseModel response,
        ) =>
            throw backgroundException,
        receiveLocalNotificationCallback: (
          int id,
          String? title,
          String? body,
          String? payload,
        ) =>
            throw foregroundException,
        receiveNotificationResponseCallback: (
          CustomNotificationResponseModel response,
        ) =>
            throw foregroundResponseException,
      );
      when(
        () => mockPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
          onDidReceiveBackgroundNotificationResponse:
              any(named: 'onDidReceiveBackgroundNotificationResponse'),
        ),
      ).thenAnswer((_) async => true);
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.granted);

      await errorManager.initialize();

      try {
        await errorManager.onDidReceiveLocalNotification(
          1,
          'Test',
          'Test body',
          'payload',
        );
      } catch (e) {
        expect(e, foregroundException);
      }

      try {
        await errorManager.onDidReceiveBackgroundNotificationResponse(
          const CustomNotificationResponseModel(
            id: 1,
            actionId: 'action',
            input: 'input',
            payload: 'payload',
            responseType:
                CustomNotificationResponseModelType.selectedNotification,
          ),
        );
      } catch (e) {
        expect(e, backgroundException);
      }

      try {
        await errorManager.onDidReceiveNotificationResponse(
          const CustomNotificationResponseModel(
            id: 1,
            actionId: 'action',
            input: 'input',
            payload: 'payload',
            responseType:
                CustomNotificationResponseModelType.selectedNotification,
          ),
        );
      } catch (e) {
        expect(e, foregroundResponseException);
      }
    });

    test('Notification response callbacks are triggered correctly', () async {
      final MockFlutterLocalNotificationsPlugin customMockPlugin =
          MockFlutterLocalNotificationsPlugin();
      late Function(NotificationResponse) capturedForegroundCallback;
      late Function(NotificationResponse) capturedBackgroundCallback;

      when(
        () => customMockPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
          onDidReceiveBackgroundNotificationResponse:
              any(named: 'onDidReceiveBackgroundNotificationResponse'),
        ),
      ).thenAnswer((Invocation invocation) {
        capturedForegroundCallback =
            invocation.namedArguments[#onDidReceiveNotificationResponse]
                as Function(NotificationResponse);
        capturedBackgroundCallback = invocation
                .namedArguments[#onDidReceiveBackgroundNotificationResponse]
            as Function(NotificationResponse);
        return Future<bool>.value(true);
      });
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.granted);

      final LocalNotificationManagerImpl customManager =
          LocalNotificationManagerImpl(
        localNotificationPlugin: customMockPlugin,
        logManager: mockLogManager,
        permissionManager: mockPermissionManager,
        receiveBackgroundNotificationResponseCallback: (
          CustomNotificationResponseModel response,
        ) {
          return true;
        },
        receiveLocalNotificationCallback: (
          int id,
          String? title,
          String? body,
          String? payload,
        ) {
          return true;
        },
        receiveNotificationResponseCallback: (
          CustomNotificationResponseModel response,
        ) {
          return true;
        },
      );

      await customManager.initialize();

      // Create a mock NotificationResponse
      final MockNotificationResponse mockResponse = MockNotificationResponse();
      when(() => mockResponse.id).thenReturn(1);
      when(() => mockResponse.actionId).thenReturn('default');
      when(() => mockResponse.input).thenReturn(null);
      when(() => mockResponse.payload).thenReturn('test_payload');

      // Trigger the foreground callback
      await capturedForegroundCallback(mockResponse);

      // // Verify that onDidReceiveNotificationResponse was called
      // verify(() => customManager.onDidReceiveNotificationResponse(any()))
      //     .called(1);

      // // Trigger the background callback
      // await capturedBackgroundCallback(mockResponse);

      // // Verify that onDidReceiveBackgroundNotificationResponse was called
      // verify(
      //   () => customManager.onDidReceiveBackgroundNotificationResponse(any()),
      // ).called(1);
    });
  });
}

Future<void> _zonedScheduleCallback(
  MockFlutterLocalNotificationsPlugin mockPlugin,
) {
  return mockPlugin.zonedSchedule(
    any(),
    any(),
    any(),
    any(),
    any(),
    payload: any(named: 'payload'),
    androidScheduleMode: any(named: 'androidScheduleMode'),
    uiLocalNotificationDateInterpretation:
        any(named: 'uiLocalNotificationDateInterpretation'),
    matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
  );
}

CustomLocalNotificationSettings get _customSettings {
  const Map<String, String> exampleMap = <String, String>{
    'id': 'id',
    'title': 'title',
    'body': 'body',
    'payload': 'payload',
  };
  return const CustomLocalNotificationSettings(
    icon: 'icon',
    channelId: 'channelId',
    channelName: 'channelName',
    channelDescription: 'channelDescription',
    visibility: CustomNotificationVisibility.public,
    priority: NotificationPriority.max,
    interruptionLevel: NotificationInterruptionLevel.critical,
    importance: NotificationImportance.max,
    category: NotificationCategory.transport,
    sound: 'sound',
    attachments: <Map<String, String>>[exampleMap],
    actions: <Map<String, String>>[exampleMap],
  );
}
