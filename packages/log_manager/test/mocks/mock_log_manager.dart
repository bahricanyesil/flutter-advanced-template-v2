import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';

final class MockLogManager extends LogManager with Mock {
  final StreamController<BaseLogMessageModel> _streamController =
      StreamController<BaseLogMessageModel>();

  @override
  Stream<BaseLogMessageModel> get logStream => _streamController.stream;

  void addLogMessage(BaseLogMessageModel message) {
    _streamController.add(message);
  }

  @override
  Future<void> close() async {
    await _streamController.close();
  }

  @override
  Future<void> logFlutterError(FlutterErrorDetails details) async {
    // Override only if needed for specific behavior
    return super.logFlutterError(details);
  }
}
