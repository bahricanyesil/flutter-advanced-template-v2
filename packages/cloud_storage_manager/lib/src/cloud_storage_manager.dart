import 'dart:io';

/// Represents an interface for managing Storage operations.
abstract interface class CloudStorageManager {
  /// Uploads a file to the specified storage path.
  /// Returns a tuple containing the download URL
  /// of the uploaded file and an error message, if any.
  Future<(String? downloadUrl, String? error)> uploadFile({
    required String path,
    required File file,
  });

  /// Deletes a file from the specified storage path.
  /// Returns an error message, if any.
  Future<String?> deleteFile(String path, {bool fromUrl = false});

  /// Fetches the download URL for a file at the specified storage path.
  /// Returns a tuple containing the download URL and an error message, if any.
  Future<(String? downloadUrl, String? error)> getFileDownloadUrl(String path);

  /// Downloads a file from the specified download URL.
  Future<(File?, String?)> downloadFile(
    String downloadUrl, {
    bool fromUrl = false,
    String? customDownloadPath,
  });
}
