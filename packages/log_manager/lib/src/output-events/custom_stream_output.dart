import 'dart:async';

import '../models/base_log_message_model.dart';
import 'base_log_output.dart';

/// A custom stream output for logging events.
///
/// This class provides a stream-based output for logging events. It allows
/// listeners to receive a stream of lists of strings representing log lines.
/// The output can be controlled by pausing and resuming the stream.
final class CustomStreamOutput implements ILogOutput {
  /// Constructor for the [CustomStreamOutput] class.
  CustomStreamOutput() {
    _controller = StreamController<BaseLogMessage>.broadcast(
      onListen: () => _shouldForward = true,
      onCancel: () => _shouldForward = false,
    );
  }

  late StreamController<BaseLogMessage> _controller;
  bool _shouldForward = false;

  /// The stream of log lines.
  Stream<BaseLogMessage> get stream => _controller.stream;

  /// Outputs a log event.
  ///
  /// If the stream is not currently forwarding, the log event will not be
  /// added to the stream.
  @override
  void output(BaseLogMessage logMessage) {
    if (!_shouldForward) return;
    _controller.add(logMessage);
  }

  /// Destroys the stream output.
  ///
  /// Closes the stream controller and releases
  /// any resources associated with it.
  @override
  Future<void> destroy() async => _controller.close();
}
