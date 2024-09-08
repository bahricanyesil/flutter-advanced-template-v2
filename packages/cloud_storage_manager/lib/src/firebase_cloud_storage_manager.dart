import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'cloud_storage_manager.dart';

/// A class that manages Firebase Storage operations.
/// This class is used to manage file uploads, downloads, and deletions.
/// It implements the [CloudStorageManager] interface.
/// It uses the [FirebaseStorage] package to manage the storage operations.
@immutable
final class FirebaseCloudStorageManager implements CloudStorageManager {
  /// Creates a new instance of the [FirebaseCloudStorageManager].
  const FirebaseCloudStorageManager(this._storage, {LogManager? logManager})
      : _logManager = logManager;

  /// The [FirebaseStorage] instance.
  final FirebaseStorage _storage;

  /// The [LogManager] instance.
  final LogManager? _logManager;

  @override
  Future<(String? downloadUrl, String? error)> uploadFile({
    required String path,
    required File file,
  }) async {
    try {
      final Reference storageRef = _storage.ref().child(path);
      await storageRef.putFile(file);
      final String downloadUrl = await storageRef.getDownloadURL();
      _logManager?.lDebug(
        'File uploaded successfully to Firebase Storage. $downloadUrl',
      );
      return (downloadUrl, null);
    } on FirebaseException catch (e) {
      _logManager
          ?.lError('Error uploading file to Firebase Storage: ${e.message}');
      return (null, e.message);
    } catch (e) {
      _logManager?.lError('Error uploading file to Firebase Storage: $e');
      return (null, e.toString());
    }
  }

  @override
  Future<String?> deleteFile(String path, {bool fromUrl = false}) async {
    try {
      late final Reference storageRef;
      if (fromUrl) {
        storageRef = _storage.refFromURL(path);
      } else {
        storageRef = _storage.ref().child(path);
      }
      await storageRef.delete();
      _logManager?.lDebug('File deleted successfully from Firebase Storage.');
      return null;
    } on FirebaseException catch (e) {
      _logManager?.lError(
        'Error deleting the file from Firebase Storage: ${e.message}',
      );
      return e.message;
    } catch (e) {
      _logManager?.lError('Error deleting file from Firebase Storage: $e');
      return e.toString();
    }
  }

  @override
  Future<(String? downloadUrl, String? error)> getFileDownloadUrl(
    String path,
  ) async {
    try {
      final Reference storageRef = _storage.ref().child(path);
      final String downloadUrl = await storageRef.getDownloadURL();
      _logManager
          ?.lDebug('File download URL fetched successfully: $downloadUrl');
      return (downloadUrl, null);
    } on FirebaseException catch (e) {
      _logManager?.lError(
        'Error getting download url from Firebase Storage: ${e.message}',
      );
      return (null, e.message);
    } catch (e) {
      _logManager?.lError('Error fetching file download URL: $e');
      return (null, e.toString());
    }
  }

  @override
  Future<(File?, String?)> downloadFile(
    String downloadUrl, {
    bool fromUrl = false,
    String? customDownloadPath,
  }) async {
    try {
      late final Reference storageRef;
      if (fromUrl) {
        storageRef = _storage.refFromURL(downloadUrl);
      } else {
        storageRef = _storage.ref().child(downloadUrl);
      }
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath =
          customDownloadPath ?? '${appDocDir.absolute}/${storageRef.name}';
      final File file = File(filePath);

      final DownloadTask downloadTask = storageRef.writeToFile(file);

      await for (final TaskSnapshot taskSnapshot
          in downloadTask.snapshotEvents) {
        if (taskSnapshot.state == TaskState.success) {
          final int totalBytes = taskSnapshot.totalBytes;
          final int bytesTransferred = taskSnapshot.bytesTransferred;
          if (totalBytes == bytesTransferred) {
            _logManager?.lDebug(
              'File downloaded successfully from Firebase Storage.',
            );
            return (file, null);
          }
        }
      }
      return (null, 'Error downloading file from Firebase Storage.');
    } on FirebaseException catch (e) {
      _logManager?.lError(
        'Error download file from Firebase Storage: ${e.message}',
      );
      return (null, e.message);
    } catch (e) {
      _logManager?.lError('Error downloading file from Firebase Storage: $e');
      return (null, e.toString());
    }
  }
}
