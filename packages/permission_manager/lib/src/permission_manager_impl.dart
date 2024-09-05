import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants/permission_types.dart';
import 'permission_manager.dart';
import 'utils/permission_types_extensions.dart';

/// Implementation of the [PermissionManager] interface.
///
/// This class provides methods to request, check, and open app settings for
/// various types of permissions.
///
/// It uses the PermissionHandler package to request and check permissions.
/// The [LogManager] is used to log messages.
///
/// If the [LogManager] is not provided, the [PermissionManager] will not log
/// any messages.
///
/// This class is immutable and can be used as a singleton.
@immutable
final class PermissionManagerImpl implements PermissionManager {
  /// Creates a new [PermissionManagerImpl] instance.
  ///
  /// The [logManager] parameter is optional and can be used to log messages.
  const PermissionManagerImpl({
    LogManager? logManager,
    this.rethrowExceptions = true,
  }) : _logManager = logManager;

  final LogManager? _logManager;

  /// If [rethrowExceptions] is true, the [PermissionManager] will rethrow
  /// exceptions.
  final bool rethrowExceptions;

  @override
  Future<bool> requestPermission(PermissionTypes permissionType) async {
    try {
      final PermissionStatus status =
          await permissionType.toPermission.request();
      _logManager?.lDebug('Permission status: $status');
      return status.isGranted;
    } catch (e) {
      _logManager?.lError('Error requesting permission: $e');
      if (!rethrowExceptions) return false;
      rethrow;
    }
  }

  @override
  Future<bool> checkPermission(PermissionTypes permissionType) async {
    try {
      final PermissionStatus status = await permissionType.toPermission.status;
      _logManager?.lDebug('Permission status: $status');
      return status.isGranted;
    } catch (e) {
      _logManager?.lError('Error checking permission: $e');
      if (!rethrowExceptions) return false;
      rethrow;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      final bool opened = await openAppSettings();
      _logManager?.lDebug('App settings opened: $opened');
      return opened;
    } catch (e) {
      _logManager?.lError('Error opening app settings: $e');
      if (!rethrowExceptions) return false;
      rethrow;
    }
  }

  @override
  Future<bool> checkAndRequestPermission(PermissionTypes permissionType) async {
    final bool isGranted = await checkPermission(permissionType);
    if (!isGranted) {
      return requestPermission(permissionType);
    }
    return isGranted;
  }
}
