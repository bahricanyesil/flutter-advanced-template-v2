import 'dart:async';

import 'package:collection/collection.dart';
import 'package:connectivity_manager/src/connectivity_manager.dart';
import 'package:connectivity_manager/src/enums/connectivity_result_type.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:log_manager/log_manager.dart';
import 'package:rxdart/rxdart.dart';

/// Type definition for the function that checks if two objects are equal.
typedef UnOrderedEqualFunc = bool Function(Object? a, Object? b);

/// A class that manages connectivity and provides methods to check for network
/// connection and monitor changes in network connectivity.
final class ConnectivityPlusManager implements ConnectivityManager {
  /// Creates a [ConnectivityPlusManager] instance.
  ConnectivityPlusManager(this._connectivity, {LogManager? logManager})
      : _logManager = logManager {
    _initConnectivity();
  }
  final Connectivity _connectivity;
  final LogManager? _logManager;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  late final BehaviorSubject<List<ConnectivityResultType>>
      _connectionTypeController;

  bool _isConnected = false;
  List<ConnectivityResultType> _connections = <ConnectivityResultType>[
    ConnectivityResultType.none,
  ];

  Future<void> _initConnectivity() async {
    _connectionTypeController = BehaviorSubject<List<ConnectivityResultType>>();
    _connections = await getConnectivityResult();
    _isConnected = _connections.hasConnection;
    _connectionTypeController.add(_connections);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _isConnected = results.hasConnection;
      final UnOrderedEqualFunc unOrdDeepEq =
          const DeepCollectionEquality.unordered().equals;
      if (!unOrdDeepEq(results.toConnectivityResultList, _connections)) {
        _logManager?.lDebug('''
          Connectivity changed:\n
          Old Connections: $_connections\n
          New Connections: ${results.toConnectivityResultList}''');
        _connections = results.toConnectivityResultList;
        _connectionTypeController.add(_connections);
      }
    });
  }

  @override
  Stream<List<ConnectivityResultType>> get monitorConnection =>
      _connectionTypeController.stream.distinct(
        (List<ConnectivityResultType> a, List<ConnectivityResultType> b) =>
            a.equals(b),
      );

  @override
  bool get isConnected => _isConnected;

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _connectionTypeController.close();
  }

  @override
  Future<bool> hasConnection() async {
    final List<ConnectivityResultType> connections =
        await getConnectivityResult();
    return connections.hasConnection;
  }

  @override
  Future<List<ConnectivityResultType>> getConnectivityResult() async {
    final List<ConnectivityResult> conRes =
        await _connectivity.checkConnectivity();
    return conRes.toConnectivityResultList;
  }
}
