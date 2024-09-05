import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:permission_manager/src/service/permission_handler_service_impl.dart';

import '../mocks/mock_permission_handler.dart';

void main() {
  group('Permission Handler Service Tests', () {
    setUp(() {
      PermissionHandlerPlatform.instance = MockPermissionHandler();
    });

    test('openAppSettings opens the app settings', () async {
      final bool hasOpened =
          await const PermissionHandlerServiceImpl().openAppSettings();

      expect(hasOpened, true);
    });

    test('requestPermission calls request on Permission', () async {
      final PermissionStatus? status =
          await const PermissionHandlerServiceImpl()
              .request(Permission.backgroundRefresh);

      expect(status, null);
    });

    test('status returns the status of the permission', () async {
      final PermissionStatus status = await const PermissionHandlerServiceImpl()
          .status(Permission.backgroundRefresh);

      expect(status, PermissionStatus.granted);
    });
  });
}
