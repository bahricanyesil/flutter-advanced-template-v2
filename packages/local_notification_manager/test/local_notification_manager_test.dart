import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart';

import 'mocks/mock_flutter_local_notifications_plugin.dart';
import 'mocks/mock_log_manager.dart';
import 'mocks/mock_notification_response.dart';
import 'mocks/mock_permission_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  late MockFlutterLocalNotificationsPlugin mockPlugin;
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
    registerFallbackValue(NotificationResponseType.selectedNotificationAction);
    registerFallbackValue(
      const CustomNotificationResponseModel(
        id: 0,
        actionId: 'default',
        responseType:
            CustomNotificationResponseModelType.selectedNotificationAction,
      ),
    );
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockLogManager = MockLogManager();
    mockPermissionManager = MockPermissionManager();
    manager = LocalNotificationManagerImpl(
      localNotificationPlugin: mockPlugin,
      logManager: mockLogManager,
      permissionManager: mockPermissionManager,
      rethrowExceptions: false,
      customSettings: _customSettings,
      receiveLocalNotificationCallback: (_, __, ___, ____) => true,
      onBackgroundNotificationCallback: (_) => true,
      receiveNotificationResponseCallback: (_) => true,
    );
  });

  group('LocalNotificationManagerImpl', () {
    test('initialize', () async {
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

      expect(await manager.initialize(), true);
      verify(
        () => mockLogManager.lDebug('Local notification manager initialized'),
      ).called(1);

      // Test failure case
      when(
        () => mockPlugin.initialize(
          any(),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
          onDidReceiveBackgroundNotificationResponse:
              any(named: 'onDidReceiveBackgroundNotificationResponse'),
        ),
      ).thenThrow(Exception('Test exception'));
      expect(await manager.initialize(), false);
    });

    test('showNotification', () async {
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.granted);
      when(() => mockPlugin.show(any(), any(), any(), any()))
          .thenAnswer((_) async {});

      expect(
        await manager.showNotification(
          id: 1,
          title: 'Test',
          body: 'Test body',
        ),
        true,
      );
      verify(() => mockLogManager.lDebug(any())).called(1);

      // Test no permission case
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.denied);
      expect(
        await manager.showNotification(
          id: 1,
          title: 'Test',
          body: 'Test body',
        ),
        false,
      );
      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('scheduleNotification', () async {
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.granted);
      when(() => _zonedScheduleCallback(mockPlugin)).thenAnswer((_) async {});

      expect(
        await manager.scheduleNotification(
          id: 1,
          title: 'Test',
          body: 'Test body',
          scheduledDate: DateTime.now().add(const Duration(hours: 1)),
        ),
        true,
      );
      verify(() => mockLogManager.lDebug(any())).called(1);

      // Test no permission case
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.denied);
      expect(
        await manager.scheduleNotification(
          id: 1,
          title: 'Test',
          body: 'Test body',
          scheduledDate: DateTime.now().add(const Duration(hours: 1)),
        ),
        false,
      );
      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('cancelNotification', () async {
      when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});
      expect(await manager.cancelNotification(1), true);
      verify(() => mockLogManager.lDebug(any())).called(1);

      // Test error case
      when(() => mockPlugin.cancel(any()))
          .thenThrow(Exception('Test exception'));
      expect(await manager.cancelNotification(1), false);
      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('cancelAllNotifications', () async {
      when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});
      expect(await manager.cancelAllNotifications(), true);
      verify(() => mockLogManager.lDebug(any())).called(1);

      // Test error case
      when(() => mockPlugin.cancelAll()).thenThrow(Exception('Test exception'));
      expect(await manager.cancelAllNotifications(), false);
      verify(() => mockLogManager.lError(any())).called(1);
    });

    test('notification callbacks', () async {
      expect(
        await manager.onDidReceiveLocalNotification(
          1,
          'Test',
          'Test body',
          'payload',
        ),
        true,
      );
      expect(
        await manager.onDidReceiveNotificationResponse(
          const CustomNotificationResponseModel(
            id: 1,
            actionId: 'action',
            input: 'input',
            payload: 'payload',
            responseType:
                CustomNotificationResponseModelType.selectedNotificationAction,
          ),
        ),
        true,
      );
      verify(() => mockLogManager.lDebug(any())).called(3);
    });

    test('isEnabled', () {
      expect(manager.isEnabled, true);
    });

    group('Callback error tests', () {
      late LocalNotificationManagerImpl errorManager;

      setUp(() {
        errorManager = LocalNotificationManagerImpl(
          localNotificationPlugin: mockPlugin,
          logManager: mockLogManager,
          permissionManager: mockPermissionManager,
          onBackgroundNotificationCallback: (_) =>
              throw Exception('Test exception on background'),
          receiveLocalNotificationCallback: (_, __, ___, ____) =>
              throw Exception('Test exception on foreground'),
          receiveNotificationResponseCallback: (_) =>
              throw Exception('Test exception on foreground response'),
        );
      });

      test('onDidReceiveLocalNotification throws', () async {
        expect(
          () => errorManager.onDidReceiveLocalNotification(
            1,
            'Test',
            'Test body',
            'payload',
          ),
          throwsException,
        );
      });

      test('onDidReceiveNotificationResponse throws', () async {
        expect(
          () => errorManager.onDidReceiveNotificationResponse(
            const CustomNotificationResponseModel(
              id: 1,
              actionId: 'action',
              input: 'input',
              payload: 'payload',
              responseType:
                  CustomNotificationResponseModelType.selectedNotification,
            ),
          ),
          throwsException,
        );
      });
    });

    test('Notification response callbacks are triggered correctly', () async {
      final MockFlutterLocalNotificationsPlugin customMockPlugin =
          MockFlutterLocalNotificationsPlugin();
      late void Function(NotificationResponse) capturedForegroundCallback;
      late void Function(NotificationResponse) capturedBackgroundCallback;

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
            invocation.namedArguments[#onDidReceiveNotificationResponse] as void
                Function(NotificationResponse);
        capturedBackgroundCallback = invocation
                .namedArguments[#onDidReceiveBackgroundNotificationResponse]
            as void Function(NotificationResponse);
        return Future<bool>.value(true);
      });
      when(() => mockPermissionManager.checkPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.denied);
      when(() => mockPermissionManager.requestPermission(any()))
          .thenAnswer((_) async => PermissionStatusTypes.granted);

      final LocalNotificationManagerImpl customManager =
          LocalNotificationManagerImpl(
        localNotificationPlugin: customMockPlugin,
        logManager: mockLogManager,
        permissionManager: mockPermissionManager,
        receiveNotificationResponseCallback:
            expectAsync1((CustomNotificationResponseModel response) {
          expect(response.id, 1);
          expect(response.actionId, 'default');
          expect(response.input, null);
          expect(response.payload, 'test_payload');
          return true;
        }),
      );

      await customManager.initialize();

      final MockNotificationResponse mockResponse = MockNotificationResponse();
      when(() => mockResponse.id).thenReturn(1);
      when(() => mockResponse.actionId).thenReturn('default');
      when(() => mockResponse.input).thenReturn(null);
      when(() => mockResponse.payload).thenReturn('test_payload');

      capturedForegroundCallback(mockResponse);
      capturedBackgroundCallback(mockResponse);
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
