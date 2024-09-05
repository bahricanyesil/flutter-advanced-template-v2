import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

import 'constants/custom_file_types.dart';
import 'file_picker_manager.dart';
import 'utils/custom_file_picker_statuses_extensions.dart';
import 'utils/custom_file_types_extensions.dart';

/// A service that provides image picker operations.
@immutable
final class FilePickerManagerImpl implements FilePickerManager {
  /// Creates an [FilePickerManagerImpl] with the given [FilePicker].
  const FilePickerManagerImpl(
    this._filePicker, {
    LogManager? logManager,
    this.rethrowExceptions = true,
  }) : _logManager = logManager;

  final FilePicker _filePicker;
  final LogManager? _logManager;

  /// Whether to handle exceptions.
  final bool rethrowExceptions;

  @override
  Future<File?> pickFile({
    List<String> allowedExtensions = const <String>[],
    bool allowMultiple = false,
    CustomFileTypes type = CustomFileTypes.any,
    String? dialogTitle,
    String? initialDirectory,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    FilePickerStatusCallback? onFileLoading,
  }) async {
    try {
      final FilePickerResult? pickedFile = await _filePicker.pickFiles(
        allowMultiple: allowMultiple,
        type: type.toPackageType,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
        initialDirectory: initialDirectory,
        allowCompression: allowCompression,
        compressionQuality: compressionQuality,
        withData: withData,
        withReadStream: withReadStream,
        lockParentWindow: lockParentWindow,
        readSequential: readSequential,
        onFileLoading: (FilePickerStatus status) {
          onFileLoading?.call(status.toCustomFilePickerStatus);
        },
      );
      if (pickedFile != null) {
        _logManager
            ?.lInfo('File picked, path: ${pickedFile.files.single.path}');
        return File(pickedFile.files.single.path!);
      }
      _logManager?.lDebug('No file picked');
      return null;
    } catch (e) {
      _logManager?.lError('Error picking file: $e');
      if (!rethrowExceptions) return null;
      rethrow;
    }
  }
}
