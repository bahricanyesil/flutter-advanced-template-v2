import 'dart:io';

import 'package:image_picker_manager/src/enums/camera_device_types.dart';

import 'enums/image_source_types.dart';

/// An abstract class that provides a contract for image picker operations.
// ignore: one_member_abstracts
abstract interface class ImagePickerManager {
  /// Picks an image from the user's device.
  Future<File?> pickImage({
    required ImageSourceTypes source,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 75,
    CameraDeviceTypes preferredCameraDevice = CameraDeviceTypes.rear,
    bool requestFullMetadata = true,
  });
}
