/// The status of a permission.
enum PermissionStatusTypes {
  /// The permission is granted.
  granted,

  /// The permission is denied.
  denied,

  /// The permission is permanently denied.
  permanentlyDenied,

  /// The permission is restricted.
  restricted,

  /// The permission is limited.
  limited,

  /// The permission is provisional.
  provisional,

  /// No permission status.
  undefined,
}
