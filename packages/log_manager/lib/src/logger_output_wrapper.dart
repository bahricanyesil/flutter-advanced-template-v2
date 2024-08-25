import 'package:logger/logger.dart';
import 'package:logger/web.dart';

/// The [LoggerOutputWrapper] class is used to wrap the [Logger] class.
/// It is used to add and remove output listeners.
abstract class LoggerOutputWrapper {
  /// Adds an output listener to the logger.
  void addOutputListener(OutputCallback callback);

  /// Removes an output listener from the logger.
  void removeOutputListener(OutputCallback callback);
}

/// The [LoggerOutputWrapperImpl] class is used to implement
/// the [LoggerOutputWrapper] class.
class LoggerOutputWrapperImpl implements LoggerOutputWrapper {
  @override
  void addOutputListener(OutputCallback callback) {
    Logger.addOutputListener(callback);
  }

  @override
  void removeOutputListener(OutputCallback callback) {
    Logger.removeOutputListener(callback);
  }
}
