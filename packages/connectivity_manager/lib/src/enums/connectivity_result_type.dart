import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;

/// Represents the possible results of a connectivity check.
///
/// The [ConnectivityResultType] enum defines the different types of
/// connectivity results that can be obtained when checking the device's
/// connectivity status. The possible results include:
///
/// This enum is typically used in conjunction with the connectivity manager to
/// determine the current connectivity status of the device.
enum ConnectivityResultType {
  /// The device is connected to the internet via a Bluetooth connection.
  bluetooth,

  /// The device is connected to the internet via a Wi-Fi connection.
  wifi,

  /// The device is connected to the internet via an Ethernet connection.
  ethernet,

  /// The device is connected to the internet via a mobile data connection.
  mobile,

  /// The device is not connected to the internet.
  none,

  /// The device is connected to the internet via a VPN connection.
  vpn,

  /// The device is connected to the internet via an unknown connection.
  other,
}

/// Extension method to convert `connectivity.ConnectivityResult`
/// to `ConnectivityResult`.
extension ConnectivityResultX on connectivity.ConnectivityResult {
  /// Converts `connectivity.ConnectivityResult` to `ConnectivityResult`.
  ConnectivityResultType get toConnectivityResult {
    switch (this) {
      case connectivity.ConnectivityResult.none:
        return ConnectivityResultType.none;
      case connectivity.ConnectivityResult.mobile:
        return ConnectivityResultType.mobile;
      case connectivity.ConnectivityResult.wifi:
        return ConnectivityResultType.wifi;
      case connectivity.ConnectivityResult.ethernet:
        return ConnectivityResultType.ethernet;
      case connectivity.ConnectivityResult.bluetooth:
        return ConnectivityResultType.bluetooth;
      case connectivity.ConnectivityResult.vpn:
        return ConnectivityResultType.vpn;
      case connectivity.ConnectivityResult.other:
        return ConnectivityResultType.other;
    }
  }
}

/// Extension method to convert `List<connectivity.ConnectivityResult>`
extension ConnectivityResultListX on List<connectivity.ConnectivityResult> {
  /// Converts a list of `connectivity.ConnectivityResult` to a list of
  /// `ConnectivityResultType`.
  List<ConnectivityResultType> get toConnectivityResultList {
    return map((connectivity.ConnectivityResult e) => e.toConnectivityResult)
        .toList();
  }

  /// Returns a boolean value indicating whether the device is connected to the
  bool get hasConnection => toConnectivityResultList.hasConnection;
}

/// Extension methods on list of ConnectivityResultType
extension ConnectivityResultTypeListX on List<ConnectivityResultType> {
  /// List of connected types
  static const List<ConnectivityResultType> connectedTypes =
      <ConnectivityResultType>[
    ConnectivityResultType.mobile,
    ConnectivityResultType.wifi,
    ConnectivityResultType.ethernet,
    ConnectivityResultType.vpn,
  ];

  /// Returns a boolean value indicating whether the device is connected to the
  bool get hasConnection =>
      any((ConnectivityResultType e) => connectedTypes.contains(e)) &&
      !contains(ConnectivityResultType.none);
}
