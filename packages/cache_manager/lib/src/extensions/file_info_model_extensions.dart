import 'package:cache_manager/src/enums/file_sources.dart';
import 'package:cache_manager/src/extensions/file_source_extensions.dart';
import 'package:cache_manager/src/models/file_info_model.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as ext_cache;

/// Extension methods for the [ext_cache.FileInfo] class.
extension FileInfoModelExtensions on ext_cache.FileInfo {
  /// Converts the [ext_cache.FileInfo] to [ext_cache.FileInfo].

  FileInfoModel toFileInfo({FileSources? fileSource}) => FileInfoModel(
        file,
        fileSource ?? source.toLocalFileSource,
        validTill,
        originalUrl,
      );
}
