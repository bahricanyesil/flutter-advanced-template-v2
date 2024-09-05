import 'package:image_picker/image_picker.dart';

/// The type of camera device to use.
enum CameraDeviceTypes {
  /// The rear camera device.
  rear,

  /// The front camera device.
  front,
}

/// Extension methods for [CameraDeviceTypes].
extension CameraDeviceTypesX on CameraDeviceTypes {
  /// Converts the [CameraDeviceTypes] to a [CameraDevice].
  CameraDevice get toPackageCameraDevice {
    switch (this) {
      case CameraDeviceTypes.rear:
        return CameraDevice.rear;
      case CameraDeviceTypes.front:
        return CameraDevice.front;
    }
  }
}
