import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

final class MockLogger extends Mock implements Logger {
  @override
  Future<void> close() async =>
      super.noSuchMethod(Invocation.method(#close, <Object?>[]));
}
