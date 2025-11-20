import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_manager/src/enums/camera_device_types.dart';
import 'package:image_picker_manager/src/enums/image_source_types.dart';
import 'package:image_picker_manager/src/image_picker_manager.dart';
import 'package:log_manager/log_manager.dart';

/// An implementation of the [ImagePickerManager] that uses
/// the [ImagePicker] package.
///
/// This class is immutable and thread-safe.
///
/// [ImagePickerManagerImpl] is a concrete implementation of the
/// [ImagePickerManager] that uses the [ImagePicker] package
/// to pick images from the user's device.
@immutable
final class ImagePickerManagerImpl implements ImagePickerManager {
  /// Creates an [ImagePickerManagerImpl] with the given
  /// [ImagePicker] and [LogManager].
  const ImagePickerManagerImpl(
    this._imagePicker, {
    LogManager? logManager,
    this.rethrowExceptions = true,
  }) : _logManager = logManager;

  final ImagePicker _imagePicker;
  final LogManager? _logManager;

  /// Whether to handle exceptions.
  final bool rethrowExceptions;

  @override
  Future<File?> pickImage({
    required ImageSourceTypes source,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 75,
    CameraDeviceTypes preferredCameraDevice = CameraDeviceTypes.rear,
    bool requestFullMetadata = true,
  }) async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source.toPackageSource,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice.toPackageCameraDevice,
        requestFullMetadata: requestFullMetadata,
      );
      if (pickedImage != null) {
        _logManager
            ?.lInfo('Image picked from ${source.toString().split('.').last}');
        return File(pickedImage.path);
      }
      _logManager
          ?.lDebug('No image picked from ${source.toString().split('.').last}');
      return null;
    } catch (e) {
      _logManager?.lError('Error picking image: $e');
      if (!rethrowExceptions) return null;
      rethrow;
    }
  }
}
