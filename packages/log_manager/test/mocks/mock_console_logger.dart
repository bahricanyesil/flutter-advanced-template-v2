import 'package:log_manager/src/output-events/dev_console_output.dart';
import 'package:mocktail/mocktail.dart';

final class MockConsoleLogger extends Mock implements CustomConsoleLogger {
  final List<String> loggedMessages = <String>[];

  @override
  void log(String message) {
    loggedMessages.add(message);
  }
}
