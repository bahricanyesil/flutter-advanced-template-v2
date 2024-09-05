import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

import 'permission_handler_service.dart';

/// A service for handling permissions.
@immutable
@visibleForTesting // Marking the class as not intended for direct testing
class PermissionHandlerServiceImpl implements PermissionHandlerService {
  /// Creates a new [PermissionHandlerServiceImpl] instance.
  const PermissionHandlerServiceImpl({
    PermissionHandlerPlatform? customHandlerPlatform,
  }) : _permissionHandlerPlatform = customHandlerPlatform;

  final PermissionHandlerPlatform? _permissionHandlerPlatform;

  /// The permission handler platform instance.
  PermissionHandlerPlatform get permissionHandlerPlatform =>
      _permissionHandlerPlatform ?? PermissionHandlerPlatform.instance;

  /// Check the status of a specific [Permission]
  @override
  Future<PermissionStatus> status(Permission permission) async =>
      permissionHandlerPlatform.checkPermissionStatus(permission);

  /// Open the app settings.
  @override
  Future<bool> openAppSettings() => permissionHandlerPlatform.openAppSettings();

  /// Request permissions for a single permission.
  @override
  Future<PermissionStatus?> request(Permission permission) async =>
      (await permissionHandlerPlatform
          .requestPermissions(<Permission>[permission]))[permission];
}
