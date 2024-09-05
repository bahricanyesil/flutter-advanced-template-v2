import 'dart:async';

import 'package:connectivity_manager/src/connectivity_plus_manager.dart';
import 'package:connectivity_manager/src/enums/connectivity_result_type.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_connectivity.dart';
import 'mocks/mock_log_manager.dart';

void main() {
  late MockConnectivity mockConnectivity;
  late MockLogManager mockLogManager;
  late ConnectivityPlusManager connectivityPlusManager;
  late StreamController<List<ConnectivityResult>> streamController;

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockLogManager = MockLogManager();
    streamController = StreamController<List<ConnectivityResult>>();

    when(mockConnectivity.checkConnectivity).thenAnswer(
      (_) async => <ConnectivityResult>[ConnectivityResult.none],
    );
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => streamController.stream);

    connectivityPlusManager =
        ConnectivityPlusManager(mockConnectivity, logManager: mockLogManager);
  });

  test('Initial connectivity state should be disconnected', () async {
    await connectivityPlusManager.hasConnection();
    expect(connectivityPlusManager.isConnected, isFalse);
  });

  test('Monitor connection should emit initial state', () async {
    when(mockConnectivity.checkConnectivity).thenAnswer(
      (_) async => <ConnectivityResult>[ConnectivityResult.none],
    );
    await connectivityPlusManager.hasConnection();
    await expectLater(
      connectivityPlusManager.monitorConnection,
      emitsInOrder(<List<ConnectivityResultType>>[
        <ConnectivityResultType>[ConnectivityResultType.none],
      ]),
    );
  });

  test('Check connection should return true if there is a connection',
      () async {
    when(mockConnectivity.checkConnectivity)
        .thenAnswer((_) async => <ConnectivityResult>[ConnectivityResult.wifi]);
    final bool hasConnection = await connectivityPlusManager.hasConnection();
    expect(hasConnection, isTrue);
  });

  test('Dispose should cancel subscription and close controller', () async {
    connectivityPlusManager.dispose();
    verify(() => mockConnectivity.onConnectivityChanged).called(1);
    expect(connectivityPlusManager.monitorConnection.isBroadcast, isTrue);
  });

  test('Check connection should return false if there is no connection',
      () async {
    when(mockConnectivity.checkConnectivity).thenAnswer(
      (_) async => ConnectivityResult.values,
    );
    final List<ConnectivityResultType> connections =
        await connectivityPlusManager.getConnectivityResult();
    final List<ConnectivityResult> conRes =
        await mockConnectivity.checkConnectivity();
    expect(connections.hasConnection, isFalse);
    expect(conRes, ConnectivityResult.values);
    expect(conRes.hasConnection, isFalse);
  });

  test('Update stream should emit connectivity changes', () async {
    int streamLength = 0;
    connectivityPlusManager.monitorConnection.listen(
      (List<ConnectivityResultType> event) {
        streamLength++;
      },
    );
    streamController.add(<ConnectivityResult>[ConnectivityResult.none]);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(connectivityPlusManager.isConnected, isFalse);
    expect(streamLength, 1);

    streamController.add(<ConnectivityResult>[ConnectivityResult.wifi]);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(connectivityPlusManager.isConnected, isTrue);
    expect(streamLength, 2);

    streamController.add(<ConnectivityResult>[ConnectivityResult.wifi]);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(streamLength, 2);
  });
}
