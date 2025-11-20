// ignore_for_file: unused_element

import 'dart:io';

import 'package:cache_manager/src/cache_manager.dart';
import 'package:cache_manager/src/enums/file_sources.dart';
import 'package:cache_manager/src/extensions/file_info_model_extensions.dart';
import 'package:cache_manager/src/models/file_info_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as ext_cache;

/// Represents the manager for the cache storage.
/// The [ext_cache.CacheManager] interface provides methods
/// for managing the cache storage.
/// It includes methods for downloading, getting,
/// and removing files from the cache.
/// It also includes methods for clearing the cache
/// and disposing of the cache manager.
/// The [CacheManagerImpl] class implements [ext_cache.CacheManager].
/// It uses the [ext_cache.CacheManager] class
/// from the `flutter_cache_manager` package.
@immutable
final class CacheManagerImpl implements CacheManager {
  /// Creates a [CacheManagerImpl] instance.
  const CacheManagerImpl({required this.manager});

  /// Instance of [ext_cache.CacheManager].
  final ext_cache.CacheManager manager;

  @override
  Future<void> clear() async => manager.emptyCache();

  @override
  Future<void> dispose() async => manager.dispose();

  @override
  Future<FileInfoModel> downloadFile(
    String url, {
    String? key,
    Map<String, String>? authHeaders,
    bool force = false,
    Duration? validDuration,
  }) async {
    final ext_cache.FileInfo infoRes = await manager.downloadFile(
      url,
      key: key,
      authHeaders: _updateCacheHeader(validDuration, authHeaders),
      force: force,
    );
    return infoRes.toFileInfo();
  }

  @override
  Future<FileInfoModel?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) async {
    final ext_cache.FileInfo? infoRes = await manager.getFileFromCache(
      key,
      ignoreMemCache: ignoreMemCache,
    );
    return infoRes?.toFileInfo();
  }

  @override
  Future<FileInfoModel?> getFileFromMemory(String key) async {
    final ext_cache.FileInfo? infoRes = await manager.getFileFromMemory(key);
    return infoRes?.toFileInfo(fileSource: FileSources.memory);
  }

  @override
  Stream<String> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
    Duration? validDuration,
  }) {
    final Stream<ext_cache.FileResponse> streamRes = manager.getFileStream(
      url,
      key: key,
      headers: _updateCacheHeader(validDuration, headers),
      withProgress: withProgress,
    );
    return streamRes
        .map((ext_cache.FileResponse response) => response.originalUrl);
  }

  @override
  Future<File> getFile(
    String url, {
    String? key,
    Map<String, String>? headers,
    Duration? validDuration,
  }) async =>
      manager.getSingleFile(
        url,
        key: key ?? url,
        headers: _updateCacheHeader(validDuration, headers),
      );

  Map<String, String>? _updateCacheHeader(
    Duration? validDuration,
    Map<String, String>? headers,
  ) {
    final DateTime? validTill =
        validDuration != null ? DateTime.now().add(validDuration) : null;
    final Map<String, String> updatedHeaders = headers ?? <String, String>{};
    if (validTill != null) {
      updatedHeaders[HttpHeaders.cacheControlHeader] =
          'max-age=${validDuration?.inSeconds}';
    }
    return updatedHeaders.isEmpty ? null : updatedHeaders;
  }

  @override
  Future<File> putFile(
    String url,
    Uint8List fileBytes, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  }) async =>
      manager.putFile(
        url,
        fileBytes,
        key: key,
        eTag: eTag,
        maxAge: maxAge,
        fileExtension: fileExtension,
      );

  @override
  Future<File> putFileStream(
    String url,
    Stream<List<int>> source, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  }) async =>
      manager.putFileStream(
        url,
        source,
        key: key,
        eTag: eTag,
        maxAge: maxAge,
        fileExtension: fileExtension,
      );

  @override
  Future<void> removeFile(String key) async => manager.removeFile(key);
}
