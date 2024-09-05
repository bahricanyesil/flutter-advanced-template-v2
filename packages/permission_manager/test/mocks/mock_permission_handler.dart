import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

final class MockPermissionHandler extends Mock
    with MockPlatformInterfaceMixin
    implements PermissionHandlerPlatform {
  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) =>
      Future<PermissionStatus>.value(PermissionStatus.granted);

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) =>
      Future<ServiceStatus>.value(ServiceStatus.enabled);

  @override
  Future<bool> openAppSettings() => Future<bool>.value(true);

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) {
    final Map<Permission, PermissionStatus> permissionsMap =
        <Permission, PermissionStatus>{};
    return Future<Map<Permission, PermissionStatus>>.value(permissionsMap);
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(Permission? permission) =>
      Future<bool>.value(true);
}
