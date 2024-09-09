import 'dart:io';

import 'package:cache_manager/src/models/file_info_model.dart';
import 'package:flutter/foundation.dart';

/// An interface for managing cache storage. This interface defines methods
/// for interacting with a cache storage system.
///
/// Implementations of this interface should provide functionality for storing,
/// retrieving, and removing files from the cache.
abstract interface class CacheManager {
  /// Retrieves a single file from the cache storage.
  ///
  /// The [url] parameter specifies the URL of the file to retrieve.
  /// The [key] parameter is an optional identifier for the file.
  /// The [headers] parameter is an optional map of headers to
  /// include in the request.
  ///
  /// Returns a [Future] that completes with the retrieved [File].
  Future<File> getFile(
    String url, {
    String key,
    Map<String, String> headers,
    Duration? validDuration,
  });

  /// Retrieves a file stream from the cache storage.
  ///
  /// The [url] parameter specifies the URL of the file to retrieve.
  /// The [key] parameter is an optional identifier for the file.
  /// The [headers] parameter is an optional map of headers to include
  /// in the request.
  /// The [withProgress] parameter specifies whether to include progress
  /// updates in the stream.
  ///
  /// Returns a [Stream] of [String] objects representing the original url.
  Stream<String> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress,
    Duration? validDuration,
  });

  /// Downloads a file from the specified URL and stores it
  /// in the cache storage.
  ///
  /// The [url] parameter specifies the URL of the file to download.
  /// The [key] parameter is an optional identifier for the file.
  /// The [authHeaders] parameter is an optional map of authentication
  /// headers to include in the request.
  /// The [force] parameter specifies whether to force download
  /// the file even if it already exists in the cache.
  ///
  /// Returns a [Future] that completes with the downloaded [FileInfoModel].
  Future<FileInfoModel> downloadFile(
    String url, {
    String? key,
    Map<String, String>? authHeaders,
    bool force = false,
    Duration? validDuration,
  });

  /// Retrieves a file from the cache storage based on its key.
  ///
  /// The [key] parameter specifies the identifier of the file to retrieve.
  /// The [ignoreMemCache] parameter specifies whether to ignore the
  /// in-memory cache and retrieve the file from disk only.
  ///
  /// Returns a [Future] that completes with the retrieved [FileInfoModel],
  /// or `null` if the file is not found in the cache.
  Future<FileInfoModel?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  });

  /// Retrieves a file from the in-memory cache based on its key.
  ///
  /// The [key] parameter specifies the identifier of the file to retrieve.
  ///
  /// Returns a [Future] that completes with the retrieved [FileInfoModel],
  /// or `null` if the file is not found in the in-memory cache.
  Future<FileInfoModel?> getFileFromMemory(String key);

  /// Stores a file in the cache storage.
  ///
  /// The [url] parameter specifies the URL of the file to store.
  /// The [fileBytes] parameter specifies the bytes of the file to store.
  /// The [key] parameter is an optional identifier for the file.
  /// The [eTag] parameter is an optional entity tag for the file.
  /// The [maxAge] parameter specifies the maximum age of the file in the cache.
  /// The [fileExtension] parameter specifies the file extension
  /// of the stored file.
  ///
  /// Returns a [Future] that completes with the stored [File].
  Future<File> putFile(
    String url,
    Uint8List fileBytes, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  });

  /// Stores a file stream in the cache storage.
  ///
  /// The [url] parameter specifies the URL of the file to store.
  /// The [source] parameter specifies the stream of bytes representing
  /// the file to store.
  /// The [key] parameter is an optional identifier for the file.
  /// The [eTag] parameter is an optional entity tag for the file.
  /// The [maxAge] parameter specifies the maximum age of the file in the cache.
  /// The [fileExtension] parameter specifies the file extension
  /// of the stored file.
  ///
  /// Returns a [Future] that completes with the stored [File].
  Future<File> putFileStream(
    String url,
    Stream<List<int>> source, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  });

  /// Removes a file from the cache storage based on its key.
  ///
  /// The [key] parameter specifies the identifier of the file to remove.
  ///
  /// Returns a [Future] that completes when the file is successfully removed.
  Future<void> removeFile(String key);

  /// Clears the cache storage, removing all files.
  ///
  /// Returns a [Future] that completes when the cache is successfully cleared.
  Future<void> clear();

  /// Disposes of any resources associated with the cache storage.
  ///
  /// Returns a [Future] that completes when the resources
  /// are successfully disposed.
  Future<void> dispose();
}
