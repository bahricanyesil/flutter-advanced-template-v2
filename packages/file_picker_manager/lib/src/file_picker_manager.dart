import 'dart:io';

import 'constants/custom_file_types.dart';

/// An abstract class that provides a contract for file picker operations.
// ignore: one_member_abstracts
abstract interface class FilePickerManager {
  /// Picks an file from the user's device.
  Future<File?> pickFile({
    List<String> allowedExtensions = const <String>[],
    bool allowMultiple = false,
    CustomFileTypes? type,
  });
}
