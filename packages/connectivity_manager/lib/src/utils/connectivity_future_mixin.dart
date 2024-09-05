import 'dart:async';

import 'package:flutter/material.dart';

import '../connectivity_manager.dart';
import '../enums/connectivity_result_type.dart';

/// A mixin that provides a way to reload data when the device
/// is connected to the internet.
mixin ConnectivityFutureMixin<T extends StatefulWidget, D> on State<T> {
  late final StreamSubscription<List<ConnectivityResultType>> _subscription;

  /// Connectivity manager instance.
  ConnectivityManager get connectivityManager;

  /// Future callback to load data.
  late Future<D> futureCallback;

  @override
  void initState() {
    super.initState();
    futureCallback = loadData();
    _subscription = DataReloader(connectivityManager: connectivityManager)
        .reloadIfConnected(reload);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// Reloads the data. This method is called when
  /// the device is connected to the internet.
  void reload() {
    futureCallback = loadData();
    if (mounted) setState(() {});
  }

  /// Loads the data. This method should be implemented by
  /// the class using this mixin.
  Future<D> loadData();
}

/// Data reloader wrapper for connectivity changes.
final class DataReloader {
  /// Creates a new [DataReloader] instance.
  const DataReloader({required this.connectivityManager});

  /// Connectivity manager instance.
  final ConnectivityManager connectivityManager;

  /// Reloads the callback if the device is connected to the internet.
  StreamSubscription<List<ConnectivityResultType>> reloadIfConnected(
    FutureOr<void> Function() reloadFunction,
  ) {
    bool wasConnected = connectivityManager.isConnected;
    final StreamSubscription<List<ConnectivityResultType>> subscription =
        connectivityManager.monitorConnection
            .listen((List<ConnectivityResultType> connections) async {
      final bool isConnected = connections.hasConnection;
      if (!wasConnected && isConnected) {
        await reloadFunction();
      }
      wasConnected = isConnected;
    });
    // ignore: cascade_invocations
    subscription.onDone(connectivityManager.dispose);
    return subscription;
  }
}
