import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker_manager/src/utils/custom_file_types_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

import 'constants/custom_file_types.dart';
import 'file_picker_manager.dart';

/// A service that provides image picker operations.
@immutable
final class FilePickerManagerImpl implements FilePickerManager {
  /// Creates an [FilePickerManagerImpl] with the given [FilePicker].
  const FilePickerManagerImpl(this._filePicker, LogManager? logManager)
      : _logManager = logManager;

  final FilePicker _filePicker;
  final LogManager? _logManager;

  @override
  Future<File?> pickFile({
    List<String> allowedExtensions = const <String>[],
    bool allowMultiple = false,
    CustomFileTypes? type,
  }) async {
    try {
      final FilePickerResult? pickedFile = await _filePicker.pickFiles(
        allowMultiple: allowMultiple,
        type: (type ?? CustomFileTypes.any).toPackageType,
        allowedExtensions: allowedExtensions,
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
      return null;
    }
  }
}
