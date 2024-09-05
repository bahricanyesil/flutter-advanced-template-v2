/// Library for logging messages to the console.
///
/// This library provides a base class for managing logging functionality.
/// It includes methods for logging fatal errors, errors, warnings,
/// informational messages, debug messages, and trace messages.
library log_manager;

export 'package:logger/logger.dart';

export 'src/enums/log_levels.dart';
export 'src/log_manager.dart';
export 'src/logger_log_manager.dart';
export 'src/models/base_log_message_model.dart';
export 'src/models/base_log_options_model.dart';
export 'src/output-events/base_log_output.dart';
export 'src/output-events/custom_stream_output.dart';
export 'src/output-events/dev_console_output.dart';
export 'src/utils/custom_log_extensions.dart';
export 'src/utils/custom_pretty_printer.dart';
