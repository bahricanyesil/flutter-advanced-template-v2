import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_manager/src/enums/camera_device_types.dart';
import 'package:image_picker_manager/src/enums/image_source_types.dart';
import 'package:image_picker_manager/src/image_picker_manager_impl.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_image_picker.dart';
import 'mocks/mock_log_manager.dart';

void main() {
  group('ImagePickerManagerImpl', () {
    late ImagePicker mockImagePicker;
    late ImagePickerManagerImpl imagePickerManager;
    late MockLogManager mockLogManager;

    Future<XFile?> replacablePickImage() => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
          preferredCameraDevice: any(named: 'preferredCameraDevice'),
          requestFullMetadata: any(named: 'requestFullMetadata'),
        );

    setUp(() {
      mockImagePicker = MockImagePicker();
      mockLogManager = MockLogManager();
      imagePickerManager =
          ImagePickerManagerImpl(mockImagePicker, logManager: mockLogManager);

      registerFallbackValue(ImageSource.camera);
      registerFallbackValue(CameraDevice.rear);
    });

    test('pickImage returns a File when an image is picked', () async {
      final XFile mockResult = _exampleXFile('jpg');

      when(replacablePickImage).thenAnswer((_) async => mockResult);

      final File? result = await imagePickerManager.pickImage(
        source: ImageSourceTypes.camera,
      );

      expect(result, isA<File>());
      expect(result?.path, 'mock/path/to/image.jpg');
    });

    test('pickImage returns null when no image is picked', () async {
      when(replacablePickImage).thenAnswer((_) async => null);

      final File? result = await imagePickerManager.pickImage(
        source: ImageSourceTypes.gallery,
        preferredCameraDevice: CameraDeviceTypes.front,
      );

      expect(result, isNull);
    });

    test('pickImage logs error on exception', () async {
      when(replacablePickImage).thenThrow(Exception('Test error'));

      expect(
        () async =>
            imagePickerManager.pickImage(source: ImageSourceTypes.camera),
        throwsException,
      );
    });
  });
}

XFile _exampleXFile(String extension) => XFile('mock/path/to/image.$extension');
