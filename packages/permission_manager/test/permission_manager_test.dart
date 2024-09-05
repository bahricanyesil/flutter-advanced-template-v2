import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_manager/src/enums/permission_status_types.dart';
import 'package:permission_manager/src/enums/permission_types.dart';
import 'package:permission_manager/src/permission_manager_impl.dart';
import 'package:permission_manager/src/service/permission_handler_service.dart';
import 'package:permission_manager/src/utils/permission_status_types_extensions.dart';
import 'package:permission_manager/src/utils/permission_types_extensions.dart';

import 'mocks/mock_log_manager.dart';
import 'mocks/mock_permission_handler_service.dart';

void main() {
  group('PermissionManager Tests', () {
    late PermissionManagerImpl permissionManager;
    late PermissionHandlerService mockPermissionHandler;
    late MockLogManager mockLogManager;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      mockPermissionHandler = MockPermissionHandlerService();
      mockLogManager = MockLogManager();
      permissionManager = PermissionManagerImpl(
        logManager: mockLogManager,
        permissionHandler: mockPermissionHandler,
      );

      registerFallbackValue(Permission.audio);
    });

    test('requestPermission calls request on Permission', () async {
      when(() => mockPermissionHandler.request(any()))
          .thenAnswer((_) async => PermissionStatus.granted);

      final PermissionStatusTypes status = await permissionManager
          .requestPermission(PermissionTypes.backgroundRefresh);

      expect(status, PermissionStatusTypes.granted);
      expect(status.isGranted, true);
      verify(() => mockPermissionHandler.request(Permission.backgroundRefresh))
          .called(1);
    });

    test('checkPermissionStatus calls status on Permission', () async {
      when(() => mockPermissionHandler.status(any()))
          .thenAnswer((_) async => PermissionStatus.denied);

      const Permission permissionType = Permission.backgroundRefresh;

      final PermissionStatusTypes status = await permissionManager
          .checkPermission(permissionType.toPermissionType);

      expect(status, PermissionStatusTypes.denied);
      expect(status.isGranted, false);
      expect(status.isDenied, true);
      expect(status.isPermanentlyDenied, false);
      verify(() => mockPermissionHandler.status(permissionType)).called(1);

      when(() => mockPermissionHandler.status(any()))
          .thenAnswer((_) async => PermissionStatus.provisional);

      final PermissionStatusTypes status2 = await permissionManager
          .checkPermission(permissionType.toPermissionType);

      expect(status2, PermissionStatusTypes.provisional);
      expect(status2.isGranted, false);
      expect(status2.isDenied, false);
      expect(status2.isPermanentlyDenied, false);
    });

    test('checkPermissionStatus throws exception for unknown permission',
        () async {
      when(() => mockPermissionHandler.status(any()))
          .thenThrow(Exception('Unknown permission'));

      const Permission permissionType = Permission.backgroundRefresh;
      try {
        await permissionManager
            .checkPermission(permissionType.toPermissionType);
      } catch (e) {
        expect(e, isA<Exception>());
      }
      verify(() => mockPermissionHandler.status(permissionType)).called(1);
    });

    test(
        '''requestPermission returns undefined for unknown permission when rethrowExceptions is false''',
        () async {
      when(() => mockPermissionHandler.request(any()))
          .thenThrow(Exception('Unknown permission'));

      final PermissionManagerImpl permissionManager2 = PermissionManagerImpl(
        logManager: mockLogManager,
        permissionHandler: mockPermissionHandler,
        rethrowExceptions: false,
      );

      const Permission permissionType = Permission.camera;
      final PermissionStatusTypes statusType = await permissionManager2
          .requestPermission(permissionType.toPermissionType);

      expect(statusType, PermissionStatusTypes.undefined);

      verify(() => mockPermissionHandler.request(permissionType)).called(1);
    });

    test('openAppSettings opens app settings', () async {
      when(() => mockPermissionHandler.openAppSettings())
          .thenAnswer((_) async => true);

      final bool result = await permissionManager.openAppSettings();

      expect(result, true);
      verify(() => mockPermissionHandler.openAppSettings()).called(1);
    });
    test(
        '''openAppSettings returns false for unknown permission when rethrowExceptions is false''',
        () async {
      when(() => mockPermissionHandler.openAppSettings())
          .thenThrow(Exception('Unknown error'));

      final PermissionManagerImpl permissionManager2 = PermissionManagerImpl(
        logManager: mockLogManager,
        permissionHandler: mockPermissionHandler,
        rethrowExceptions: false,
      );

      final bool hasOpened = await permissionManager2.openAppSettings();

      expect(hasOpened, false);
    });

    test('checkAndRequestPermission requests permission when not granted',
        () async {
      when(() => mockPermissionHandler.status(any()))
          .thenAnswer((_) async => PermissionStatus.denied);
      when(() => mockPermissionHandler.request(any()))
          .thenAnswer((_) async => PermissionStatus.granted);

      const Permission permissionType = Permission.camera;
      final PermissionStatusTypes statusType = await permissionManager
          .checkAndRequestPermission(permissionType.toPermissionType);

      expect(statusType, PermissionStatusTypes.granted);
      expect(statusType.isGranted, true);
      verify(() => mockPermissionHandler.request(permissionType)).called(1);
    });
  });
}
