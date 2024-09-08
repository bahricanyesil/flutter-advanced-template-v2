import 'dart:io';

import 'package:cloud_storage_manager/cloud_storage_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'fakes/fake_path_provider_platform.dart';
import 'mocks/mock_download_task.dart';
import 'mocks/mock_file.dart';
import 'mocks/mock_firebase_reference.dart';
import 'mocks/mock_firebase_storage.dart';
import 'mocks/mock_log_manager.dart';
import 'mocks/mock_task_snapshot.dart';
import 'mocks/mock_upload_task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    PathProviderPlatform.instance = FakePathProviderPlatform();
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

  group('getFileDownloadUrl', () {
    test('successful get download URL', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      when(() => mockReference.getDownloadURL()).thenAnswer(
        (_) => Future<String>.value('https://example.com/file.txt'),
      );

      final (String?, String?) result =
          await cloudStorageManager.getFileDownloadUrl('test/file.txt');

      expect(result.$1, 'https://example.com/file.txt');
      expect(result.$2, isNull);
    });

    test('FirebaseException during get download URL', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      when(() => mockReference.getDownloadURL()).thenThrow(
        FirebaseException(plugin: 'storage', message: 'URL fetch failed'),
      );

      final (String?, String?) result =
          await cloudStorageManager.getFileDownloadUrl('test/file.txt');

      expect(result.$1, isNull);
      expect(result.$2, 'URL fetch failed');
    });

    test('generic exception during get download URL', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      when(() => mockReference.getDownloadURL())
          .thenThrow(Exception('Generic error'));

      final (String?, String?) result =
          await cloudStorageManager.getFileDownloadUrl('test/file.txt');

      expect(result.$1, isNull);
      expect(result.$2, 'Exception: Generic error');
    });
  });

  group('downloadFile', () {
    late MockDownloadTask mockDownloadTask;
    late MockTaskSnapshot mockTaskSnapshot;

    setUp(() {
      mockDownloadTask = MockDownloadTask();
      mockTaskSnapshot = MockTaskSnapshot();
    });

    test('successful download from path', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      const String fileName = 'file.txt';
      when(() => mockReference.name).thenReturn(fileName);
      when(() => mockReference.writeToFile(any()))
          .thenAnswer((_) => mockDownloadTask);
      when(() => mockDownloadTask.snapshotEvents).thenAnswer(
        (_) =>
            Stream<TaskSnapshot>.fromIterable(<TaskSnapshot>[mockTaskSnapshot]),
      );
      when(() => mockTaskSnapshot.state).thenReturn(TaskState.success);
      when(() => mockTaskSnapshot.totalBytes).thenReturn(100);
      when(() => mockTaskSnapshot.bytesTransferred).thenReturn(100);

      const String downloadPath = 'test/file.txt';
      final (File?, String?) result =
          await cloudStorageManager.downloadFile(downloadPath);

      expect(result.$1, isA<File>());
      expect(
        result.$1?.path,
        '${FakePathProviderPlatform.kApplicationDocumentsPath}/$fileName',
      );
      expect(result.$2, isNull);
    });

    test('successful download from URL', () async {
      when(() => mockStorage.refFromURL(any())).thenReturn(mockReference);
      when(() => mockReference.writeToFile(any()))
          .thenAnswer((_) => mockDownloadTask);
      const String fileName = 'file.txt';
      when(() => mockReference.name).thenReturn(fileName);
      when(() => mockDownloadTask.snapshotEvents).thenAnswer(
        (_) =>
            Stream<TaskSnapshot>.fromIterable(<TaskSnapshot>[mockTaskSnapshot]),
      );
      when(() => mockTaskSnapshot.state).thenReturn(TaskState.success);
      when(() => mockTaskSnapshot.totalBytes).thenReturn(100);
      when(() => mockTaskSnapshot.bytesTransferred).thenReturn(100);

      final (File?, String?) result = await cloudStorageManager
          .downloadFile('https://example.com/file.txt', fromUrl: true);

      expect(result.$1, isA<File>());
      expect(
        result.$1?.path,
        '${FakePathProviderPlatform.kApplicationDocumentsPath}/$fileName',
      );
      expect(result.$2, isNull);
    });

    test('FirebaseException during download', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      const String fileName = 'file.txt';
      when(() => mockReference.name).thenReturn(fileName);
      when(() => mockReference.writeToFile(any())).thenThrow(
        FirebaseException(plugin: 'storage', message: 'Download failed'),
      );

      final (File?, String?) result =
          await cloudStorageManager.downloadFile('test/file.txt');

      expect(result.$1, isNull);
      expect(result.$2, 'Download failed');
    });

    test('generic exception during download', () async {
      when(() => mockStorage.ref()).thenReturn(mockReference);
      when(() => mockReference.child(any())).thenReturn(mockReference);
      const String fileName = 'file.txt';
      when(() => mockReference.name).thenReturn(fileName);
      when(() => mockReference.writeToFile(any()))
          .thenThrow(Exception('Generic error'));

      final (File?, String?) result =
          await cloudStorageManager.downloadFile('test/file.txt');

      expect(result.$1, isNull);
      expect(result.$2, 'Exception: Generic error');
    });
  });
}
