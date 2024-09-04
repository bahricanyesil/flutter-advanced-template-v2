import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';

final class FakeFlutterErrorDetails extends Fake
    implements FlutterErrorDetails {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Fake Flutter Error Details';
  }
}
