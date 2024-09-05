import 'package:image_picker/image_picker.dart';

/// Image source types for the image picker.
enum ImageSourceTypes {
  /// Opens the user's camera.
  camera,

  /// Opens the user's gallery.
  gallery,
}

/// An extension that provides a conversion method for [ImageSourceTypes].
extension ImageSourceTypesExtension on ImageSourceTypes {
  /// Converts the [ImageSourceTypes] to [ImageSource].
  ImageSource get toPackageSource {
    switch (this) {
      case ImageSourceTypes.camera:
        return ImageSource.camera;
      case ImageSourceTypes.gallery:
        return ImageSource.gallery;
    }
  }
}
