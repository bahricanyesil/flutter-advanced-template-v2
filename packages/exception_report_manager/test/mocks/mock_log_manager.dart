import 'dart:async';

import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';

final class MockLogManager extends Mock implements LogManager {
  final StreamController<BaseLogMessageModel> logStreamController =
      StreamController<BaseLogMessageModel>.broadcast();

  @override
  Stream<BaseLogMessageModel> get logStream => logStreamController.stream;

  @override
  Future<void> close() async {
    await logStreamController.close();
  }
}
