import 'package:permission_handler/permission_handler.dart';

import '../enums/permission_status_types.dart';

/// Extension methods for [PermissionStatusTypes].
extension PermissionStatusTypesExtensions on PermissionStatusTypes {
  /// Returns true if the permission status is [PermissionStatusTypes.granted].
  bool get isGranted => this == PermissionStatusTypes.granted;

  /// Returns true if the permission status is [PermissionStatusTypes.denied].
  bool get isDenied => this == PermissionStatusTypes.denied;

  /// Returns true if the permission status
  /// is [PermissionStatusTypes.permanentlyDenied].
  bool get isPermanentlyDenied =>
      this == PermissionStatusTypes.permanentlyDenied;
}

/// Extension methods for [PermissionStatus].
extension PermissionStatusExtensions on PermissionStatus? {
  /// Returns the [PermissionStatusTypes] equivalent of the [PermissionStatus].
  PermissionStatusTypes get toPermissionStatusTypes => switch (this) {
        PermissionStatus.denied => PermissionStatusTypes.denied,
        PermissionStatus.granted => PermissionStatusTypes.granted,
        PermissionStatus.restricted => PermissionStatusTypes.restricted,
        PermissionStatus.limited => PermissionStatusTypes.limited,
        PermissionStatus.permanentlyDenied =>
          PermissionStatusTypes.permanentlyDenied,
        PermissionStatus.provisional => PermissionStatusTypes.provisional,
        _ => PermissionStatusTypes.undefined,
      };
}
