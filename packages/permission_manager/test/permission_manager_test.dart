import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_manager/src/constants/permission_status_types.dart';
import 'package:permission_manager/src/constants/permission_types.dart';
import 'package:permission_manager/src/permission_manager_impl.dart';
import 'package:permission_manager/src/utils/permission_status_types_extensions.dart';
import 'package:permission_manager/src/utils/permission_types_extensions.dart';

import 'mocks/mock_log_manager.dart';
import 'mocks/mock_permission_handler_service.dart';

void main() {
  group('PermissionManager Tests', () {
    late PermissionManagerImpl permissionManager;
    late MockPermissionHandlerService mockPermissionHandler;
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
    });

    test('checkPermissionStatus returns undefined for unknown permission',
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
  });
}
