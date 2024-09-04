import '../models/base_log_message_model.dart';

/// Represents an interface for a log output.
abstract interface class BaseLogOutput {
  /// Outputs the given log message.
  void output(BaseLogMessageModel logMessage);

  /// Destroys the log output.
  Future<void> destroy();
}
