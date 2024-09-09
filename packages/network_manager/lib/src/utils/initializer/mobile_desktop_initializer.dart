// ignore_for_file: prefer-match-file-name

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Initializes the network manager for mobile and desktop platforms.
abstract final class NetworkManagerInitializer {
  /// Returns the [HttpClientAdapter] instance to be used by the network manager
  static final HttpClientAdapter httpClientAdapter = IOHttpClientAdapter();
}
