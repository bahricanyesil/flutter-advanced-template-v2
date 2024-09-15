import 'package:log_manager/log_manager.dart';
import 'package:mocktail/mocktail.dart';

final class MockConsoleLogger extends Mock implements ConsoleLogger {
  final List<String> loggedMessages = <String>[];

  @override
  void logMessage(String message) {
    loggedMessages.add(message);
  }
}
