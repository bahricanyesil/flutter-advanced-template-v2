import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler show openAppSettings;
import 'package:permission_handler/permission_handler.dart';

/// A service for handling permissions.
@immutable
class PermissionHandlerService {
  /// Creates a new [PermissionHandlerService] instance.
  const PermissionHandlerService();

  /// Check the status of a specific [Permission]
  Future<PermissionStatus> status(Permission permission) async =>
      permission.status;

  /// Open the app settings.
  Future<bool> openAppSettings() => permission_handler.openAppSettings();

  /// Request permissions for a single permission.
  Future<PermissionStatus> request(Permission permission) =>
      permission.request();
}
