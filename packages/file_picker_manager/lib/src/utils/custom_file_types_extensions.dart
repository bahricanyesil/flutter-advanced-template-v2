import 'package:file_picker/file_picker.dart';

import 'package:file_picker_manager/src/enums/custom_file_types.dart';

/// An extension that provides a conversion method for [CustomFileTypes].
extension CustomFileTypesExtensions on CustomFileTypes {
  /// Converts the [CustomFileTypes] to [FileType].
  FileType get toPackageType {
    switch (this) {
      case CustomFileTypes.any:
        return FileType.any;
      case CustomFileTypes.media:
        return FileType.media;
      case CustomFileTypes.image:
        return FileType.image;
      case CustomFileTypes.video:
        return FileType.video;
      case CustomFileTypes.audio:
        return FileType.audio;
      case CustomFileTypes.custom:
        return FileType.custom;
    }
  }
}
