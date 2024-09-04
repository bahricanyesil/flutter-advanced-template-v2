import 'dart:async';

import 'package:log_manager/src/models/base_log_message_model.dart';
import 'package:log_manager/src/output-events/custom_stream_output.dart';
import 'package:mocktail/mocktail.dart';

final class MockStreamOutput extends Mock implements CustomStreamOutput {
  final StreamController<BaseLogMessageModel> _controller =
      StreamController<BaseLogMessageModel>.broadcast();

  @override
  Stream<BaseLogMessageModel> get stream => _controller.stream;

  @override
  void output(BaseLogMessageModel message) => _controller.add(message);

  @override
  Future<void> destroy() async =>
      super.noSuchMethod(Invocation.method(#destroy, <Object?>[]));
}
