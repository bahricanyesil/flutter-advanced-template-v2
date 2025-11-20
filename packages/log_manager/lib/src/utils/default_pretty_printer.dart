import 'package:log_manager/src/utils/custom_pretty_printer.dart';

/// A pretty printer for the logger package.
final class DefaultPrettyPrinter extends CustomPrettyPrinter {
  /// Creates a new instance of [DefaultPrettyPrinter].
  DefaultPrettyPrinter() : super(onlyErrorStackTrace: true, printTime: false);
}
