import 'constants/permission_types.dart';

/// Interface for managing permissions.
abstract interface class PermissionManager {
  /// Requests the permission.
  Future<bool> requestPermission(PermissionTypes permissionType);

  /// Checks if the permission is granted.
  Future<bool> checkPermission(PermissionTypes permissionType);

  /// Opens the app settings.
  Future<void> openAppSettings();

  /// Checks and requests the permission.
  Future<bool> checkAndRequestPermission(PermissionTypes permissionType);
}
