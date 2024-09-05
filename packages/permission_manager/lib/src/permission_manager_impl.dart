import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

import 'enums/permission_status_types.dart';
import 'enums/permission_types.dart';
import 'permission_manager.dart';
import 'service/permission_handler_service.dart';
import 'service/permission_handler_service_impl.dart';
import 'utils/permission_status_types_extensions.dart';
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
    PermissionHandlerService? permissionHandler,
  })  : _logManager = logManager,
        permissionHandlerService =
            permissionHandler ?? const PermissionHandlerServiceImpl();

  final LogManager? _logManager;

  /// If [rethrowExceptions] is true, the [PermissionManager] will rethrow
  /// exceptions.
  final bool rethrowExceptions;

  /// The [PermissionHandlerService] instance.
  final PermissionHandlerService permissionHandlerService;

  @override
  Future<PermissionStatusTypes> requestPermission(
    PermissionTypes permissionType,
  ) async {
    try {
      final PermissionStatus? status =
          await permissionHandlerService.request(permissionType.toPermission);
      _logManager?.lDebug('Permission status: $status');
      return status.toPermissionStatusTypes;
    } catch (e) {
      _logManager?.lError('Error requesting permission: $e');
      if (!rethrowExceptions) return PermissionStatusTypes.undefined;
      rethrow;
    }
  }

  @override
  Future<PermissionStatusTypes> checkPermission(
    PermissionTypes permissionType,
  ) async {
    try {
      final PermissionStatus status =
          await permissionHandlerService.status(permissionType.toPermission);
      _logManager?.lDebug('Permission status: $status');
      return status.toPermissionStatusTypes;
    } catch (e) {
      _logManager?.lError('Error checking permission: $e');
      if (!rethrowExceptions) return PermissionStatusTypes.undefined;
      rethrow;
    }
  }

  @override
  Future<bool> openAppSettings() async {
    try {
      final bool opened = await permissionHandlerService.openAppSettings();
      _logManager?.lDebug('App settings opened: $opened');
      return opened;
    } catch (e) {
      _logManager?.lError('Error opening app settings: $e');
      if (!rethrowExceptions) return false;
      rethrow;
    }
  }

  @override
  Future<PermissionStatusTypes> checkAndRequestPermission(
    PermissionTypes permissionType,
  ) async {
    final PermissionStatusTypes permissionStatus =
        await checkPermission(permissionType);
    if (!permissionStatus.isGranted) {
      return requestPermission(permissionType);
    }
    return permissionStatus;
  }
}
