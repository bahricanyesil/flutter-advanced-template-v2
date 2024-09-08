import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_task_snapshot.dart';

final class MockUploadTask extends Mock implements UploadTask {
  @override
  TaskSnapshot get snapshot => MockTaskSnapshot();

  @override
  Stream<TaskSnapshot> get snapshotEvents => const Stream<TaskSnapshot>.empty();

  @override
  Future<bool> cancel() async {
    return true;
  }

  @override
  Future<bool> pause() async {
    return true;
  }

  @override
  Future<bool> resume() async {
    return true;
  }

  @override
  Stream<TaskSnapshot> asStream() => const Stream<TaskSnapshot>.empty();

  @override
  Future<TaskSnapshot> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) async {
    return MockTaskSnapshot();
  }

  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) async {
    return onValue(MockTaskSnapshot());
  }

  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) async {
    return MockTaskSnapshot();
  }

  @override
  Future<TaskSnapshot> timeout(
    Duration timeLimit, {
    FutureOr<TaskSnapshot> Function()? onTimeout,
  }) async =>
      MockTaskSnapshot();
}
