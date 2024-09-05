import 'enums/connectivity_result_type.dart';

/// An abstract class that defines the methods used to monitor
/// the connectivity state of the device.
abstract interface class ConnectivityManager {
  /// Whether there is an active connection.
  bool get isConnected;

  /// Returns a boolean value indicating whether
  /// the device is connected to the internet.
  Future<bool> hasConnection();

  /// Returns a stream that monitors the connectivity state of the device.
  Stream<List<ConnectivityResultType>> get monitorConnection;

  /// Returns the method used to connect e.g: Bluetooth,
  /// WiFi, Ethernet, Mobile or None.
  Future<List<ConnectivityResultType>> getConnectivityResult();

  /// Dispose to release all streams and resources used.
  void dispose();
}
