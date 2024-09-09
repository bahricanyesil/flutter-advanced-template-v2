import 'package:cache_manager/src/enums/file_sources.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as ext_cache;

/// Extension methods for the [FileSources] enum.
extension FileSourceExtensions on ext_cache.FileSource {
  /// Converts the [ext_cache.FileSource] to [FileSources].
  FileSources get toLocalFileSource {
    return switch (this) {
      ext_cache.FileSource.Cache => FileSources.cache,
      ext_cache.FileSource.Online => FileSources.network,
      ext_cache.FileSource.NA => FileSources.unknown,
    };
  }
}
