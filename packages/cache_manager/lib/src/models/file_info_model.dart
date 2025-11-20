import 'dart:io';

import 'package:cache_manager/src/enums/file_sources.dart';
import 'package:flutter/foundation.dart';

/// Represents information about a cached file.
@immutable
final class FileInfoModel {
  /// Creates a [FileInfoModel] instance.
  ///
  /// The [file] parameter represents the cached file.
  /// The [source] parameter represents the source of the file.
  /// The [validTill] parameter represents the expiration date of the file.
  /// The [originalUrl] parameter represents the original URL of the file.
  const FileInfoModel(
    this.file,
    this.source,
    this.validTill,
    this.originalUrl,
  );

  /// The cached file.
  final File file;

  /// The source of the file.
  final FileSources source;

  /// The expiration date of the file.
  final DateTime validTill;

  /// The original URL of the file.
  final String originalUrl;
}
