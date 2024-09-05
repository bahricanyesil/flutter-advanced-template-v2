import 'package:permission_handler/permission_handler.dart';

/// A service for handling permissions.
abstract interface class PermissionHandlerService {
  /// Check the status of a specific [Permission]
  Future<PermissionStatus> status(Permission permission);

  /// Open the app settings.
  Future<bool> openAppSettings();

  /// Request permissions for a single permission.
  Future<PermissionStatus?> request(Permission permission);
}
