// ignore_for_file: prefer-match-file-name

import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// This abstract class represents a network manager initializer.
/// It provides a [httpClientAdapter] property that returns a
/// [HttpClientAdapter] instance.
abstract final class NetworkManagerInitializer {
  /// Returns the [HttpClientAdapter] instance to be used by the network manager
  static final HttpClientAdapter httpClientAdapter = BrowserHttpClientAdapter();
}
