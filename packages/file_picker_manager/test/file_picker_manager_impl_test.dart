import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker_manager/src/constants/custom_file_types.dart';
import 'package:file_picker_manager/src/file_picker_manager_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_file_picker.dart';

void main() {
  group('FilePickerManagerImpl', () {
    late FilePicker mockFilePicker;
    late FilePickerManagerImpl filePickerManager;

    Future<FilePickerResult?> replacablePickFiles() => mockFilePicker.pickFiles(
          allowMultiple: any(named: 'allowMultiple'),
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
          dialogTitle: any(named: 'dialogTitle'),
          initialDirectory: any(named: 'initialDirectory'),
          allowCompression: any(named: 'allowCompression'),
          compressionQuality: any(named: 'compressionQuality'),
          withData: any(named: 'withData'),
          withReadStream: any(named: 'withReadStream'),
          lockParentWindow: any(named: 'lockParentWindow'),
          readSequential: any(named: 'readSequential'),
          onFileLoading: any(named: 'onFileLoading'),
        );

    setUp(() {
      mockFilePicker = MockFilePicker();
      filePickerManager = FilePickerManagerImpl(mockFilePicker);

      registerFallbackValue(FileType.any);
    });

    test('pickFile returns a File when a file is picked', () async {
      // Arrange
      final FilePickerResult mockResult = _exampleFilePickerResult('txt');

      when(replacablePickFiles).thenAnswer((_) async => mockResult);

      // Act
      final File? result = await filePickerManager.pickFile();

      // Assert
      expect(result, isA<File>());
      expect(result?.path, 'mock/path/to/file.txt');
    });

    test('pickFile returns null when no file is picked', () async {
      // Arrange
      when(replacablePickFiles).thenAnswer((_) async => null);

      // Act
      final File? result = await filePickerManager.pickFile();

      // Assert
      expect(result, isNull);
    });

    test('pickFile logs error on exception', () async {
      // Arrange
      when(replacablePickFiles).thenThrow(Exception('Test error'));

      expect(filePickerManager.pickFile, throwsException);
    });

    test('pick different file types', () async {
      for (final CustomFileTypes type in CustomFileTypes.values) {
        final FilePickerResult mockFile = _exampleFilePickerResult(type.name);
        when(replacablePickFiles).thenAnswer((_) async => mockFile);
        expect(
          (await filePickerManager.pickFile(type: type))?.path,
          'mock/path/to/file.${type.name}',
        );
      }
    });
  });
}

FilePickerResult _exampleFilePickerResult(String extension) =>
    FilePickerResult(<PlatformFile>[
      _examplePlatformFile(extension),
    ]);

PlatformFile _examplePlatformFile(String extension) => PlatformFile(
      path: 'mock/path/to/file.$extension',
      name: 'file.$extension',
      size: 100,
    );
