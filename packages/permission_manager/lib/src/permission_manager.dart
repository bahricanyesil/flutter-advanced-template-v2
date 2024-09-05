import 'enums/permission_status_types.dart';
import 'enums/permission_types.dart';

/// Interface for managing permissions.
abstract interface class PermissionManager {
  /// Requests the permission.
  Future<PermissionStatusTypes> requestPermission(
    PermissionTypes permissionType,
  );

  /// Checks if the permission is granted.
  Future<PermissionStatusTypes> checkPermission(PermissionTypes permissionType);

  /// Opens the app settings.
  Future<bool> openAppSettings();

  /// Checks and requests the permission.
  Future<PermissionStatusTypes> checkAndRequestPermission(
    PermissionTypes permissionType,
  );
}
