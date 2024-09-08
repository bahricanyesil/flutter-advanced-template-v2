import 'package:cloud_storage_manager/cloud_storage_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_file.dart';
import 'mocks/mock_firebase_reference.dart';
import 'mocks/mock_firebase_storage.dart';
import 'mocks/mock_log_manager.dart';
import 'mocks/mock_task_snapshot.dart';
import 'mocks/mock_upload_task.dart';

void main() {
  late MockFirebaseStorage mockStorage;
  late MockLogManager mockLogManager;
  late FirebaseCloudStorageManager cloudStorageManager;
  late MockFirebaseReference mockReference;
  late MockUploadTask mockUploadTask;
  late MockTaskSnapshot mockTaskSnapshot;
  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockLogManager = MockLogManager();
    mockUploadTask = MockUploadTask();
    mockTaskSnapshot = MockTaskSnapshot();
    cloudStorageManager =
        FirebaseCloudStorageManager(mockStorage, logManager: mockLogManager);
    mockReference = MockFirebaseReference();
  });

  group('uploadFile', () {
    test('successful upload', () async {
      when(() => mockStorage.ref(any())).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      when(() => mockReference.putFile(any(), any()))
          .thenAnswer((_) => mockUploadTask);
      when(() => mockTaskSnapshot.state).thenReturn(TaskState.success);
      when(() => mockReference.getDownloadURL()).thenAnswer(
        (_) => Future<String>.value('https://example.com/file.txt'),
      );

      final (String?, String?) result = await cloudStorageManager.uploadFile(
        path: 'test/file.txt',
        file: MockFile(),
      );

      expect(result.$1, 'https://example.com/file.txt');
      expect(result.$2, isNull);
    });

    test('FirebaseException during upload', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      when(() => mockReference.putFile(any())).thenThrow(
        FirebaseException(plugin: 'storage', message: 'Upload failed'),
      );

      final (String?, String?) result = await cloudStorageManager.uploadFile(
        path: 'test/file.txt',
        file: MockFile(),
      );

      expect(result.$1, isNull);
      expect(result.$2, 'Upload failed');
    });

    test('generic exception during upload', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      when(() => mockReference.putFile(any()))
          .thenThrow(Exception('Generic error'));

      final (String?, String?) result = await cloudStorageManager.uploadFile(
        path: 'test/file.txt',
        file: MockFile(),
      );

      expect(result.$1, isNull);
      expect(result.$2, 'Exception: Generic error');
    });
  });

  group('deleteFile', () {
    test('successful delete from path', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      when(() => mockReference.delete())
          .thenAnswer((_) => Future<void>.value());

      final String? result =
          await cloudStorageManager.deleteFile('test/file.txt');

      expect(result, isNull);
    });

    test('successful delete from URL', () async {
      when(() => mockStorage.refFromURL(any())).thenReturn(mockReference);
      when(() => mockReference.delete())
          .thenAnswer((_) => Future<void>.value());

      final String? result = await cloudStorageManager
          .deleteFile('https://example.com/file.txt', fromUrl: true);

      expect(result, isNull);
    });

    test('FirebaseException during delete', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      when(() => mockReference.delete()).thenThrow(
        FirebaseException(plugin: 'storage', message: 'Delete failed'),
      );

      final String? result =
          await cloudStorageManager.deleteFile('test/file.txt');

      expect(result, 'Delete failed');
    });

    test('generic exception during delete', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      when(() => mockReference.delete()).thenThrow(Exception('Generic error'));

      final String? result =
          await cloudStorageManager.deleteFile('test/file.txt');

      expect(result, 'Exception: Generic error');
    });
  });
}
