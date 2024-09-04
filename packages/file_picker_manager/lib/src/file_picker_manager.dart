import 'dart:io';

import 'constants/custom_file_picker_statuses.dart';
import 'constants/custom_file_types.dart';

/// A callback that is called when the file picker status changes.
typedef FilePickerStatusCallback = void Function(
  CustomFilePickerStatuses status,
);

/// An abstract class that provides a contract for file picker operations.
// ignore: one_member_abstracts
abstract interface class FilePickerManager {
  /// Picks an file from the user's device.
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
  });
}
