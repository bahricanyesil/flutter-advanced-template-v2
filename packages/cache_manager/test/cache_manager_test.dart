import 'dart:io';
import 'dart:typed_data';

import 'package:cache_manager/src/cache_manager_impl.dart';
import 'package:cache_manager/src/enums/file_sources.dart';
import 'package:cache_manager/src/models/file_info_model.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as ext_cache;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_file.dart';
import 'mocks/mock_file_response.dart';
import 'mocks/mock_flutter_cache_manager.dart';

void main() {
  late MockFlutterCacheManager mockManager;
  late CacheManagerImpl cacheManager;

  setUpAll(() {
    registerFallbackValue(File('dummy.txt'));
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(const Stream<List<int>>.empty());
    registerFallbackValue(const Duration(hours: 1));
  });

  setUp(() {
    mockManager = MockFlutterCacheManager();
    cacheManager = CacheManagerImpl(manager: mockManager);
  });

  group('CacheManagerImpl', () {
    test('clear calls emptyCache on the manager', () async {
      when(() => mockManager.emptyCache()).thenAnswer((_) async {});
      await cacheManager.clear();
      verify(() => mockManager.emptyCache()).called(1);
    });

    test('dispose calls dispose on the manager', () async {
      when(() => mockManager.dispose()).thenAnswer((_) async {});
      await cacheManager.dispose();
      verify(() => mockManager.dispose()).called(1);
    });

    test(
        '''downloadFile calls downloadFile on the manager and returns FileInfoModel''',
        () async {
      final MockFile mockFile = MockFile();
      final ext_cache.FileInfo mockFileInfo = ext_cache.FileInfo(
        mockFile,
        ext_cache.FileSource.NA,
        DateTime.now(),
        'testUrl',
      );

      when(() => mockFile.path).thenReturn('testUrl');

      when(
        () => mockManager.downloadFile(
          any(),
          key: any(named: 'key'),
          authHeaders: any(named: 'authHeaders'),
          force: any(named: 'force'),
        ),
      ).thenAnswer((_) async => mockFileInfo);

      final FileInfoModel result = await cacheManager.downloadFile(
        'testUrl',
        key: 'testKey',
        force: true,
        validDuration: const Duration(hours: 1),
      );

      expect(result, isA<FileInfoModel>());
      expect(result.source, equals(FileSources.unknown));
      expect(result.file, isA<File>());
      expect(result.file.path, equals('testUrl'));
      verify(
        () => mockManager.downloadFile(
          'testUrl',
          key: 'testKey',
          authHeaders: any(named: 'authHeaders'),
          force: true,
        ),
      ).called(1);
    });

    test(
        '''getFileFromCache calls getFileFromCache on the manager and returns FileInfoModel''',
        () async {
      final MockFile mockFile = MockFile();
      final ext_cache.FileInfo mockFileInfo = ext_cache.FileInfo(
        mockFile,
        ext_cache.FileSource.Cache,
        DateTime.now(),
        'testUrl',
      );
      when(() => mockFile.path).thenReturn('testUrl');
      when(
        () => mockManager.getFileFromCache(
          any(),
          ignoreMemCache: any(named: 'ignoreMemCache'),
        ),
      ).thenAnswer((_) async => mockFileInfo);

      final FileInfoModel? result =
          await cacheManager.getFileFromCache('testKey', ignoreMemCache: true);

      expect(result, isA<FileInfoModel>());
      expect(result?.file.path, equals('testUrl'));
      expect(result?.source, equals(FileSources.cache));
      expect(result?.originalUrl, equals('testUrl'));
      verify(
        () => mockManager.getFileFromCache('testKey', ignoreMemCache: true),
      ).called(1);
    });

    test(
        '''getFileFromMemory calls getFileFromMemory on the manager and returns FileInfoModel''',
        () async {
      final MockFile mockFile = MockFile();
      final ext_cache.FileInfo mockFileInfo = ext_cache.FileInfo(
        mockFile,
        ext_cache.FileSource.Cache,
        DateTime.now(),
        'testUrl',
      );
      when(() => mockFile.path).thenReturn('testUrl');
      when(() => mockManager.getFileFromMemory(any()))
          .thenAnswer((_) async => mockFileInfo);

      final FileInfoModel? result =
          await cacheManager.getFileFromMemory('testKey');

      expect(result, isA<FileInfoModel>());
      expect(result?.file.path, equals('testUrl'));
      expect(result?.source, equals(FileSources.memory));
      expect(result?.originalUrl, equals('testUrl'));
      verify(() => mockManager.getFileFromMemory('testKey')).called(1);
    });

    test(
        '''getFileStream calls getFileStream on the manager and returns Stream<String>''',
        () async {
      final MockFileResponse mockFileRes1 = MockFileResponse();
      final MockFileResponse mockFileRes2 = MockFileResponse();
      final Stream<ext_cache.FileResponse> mockStream =
          Stream<ext_cache.FileResponse>.fromIterable(<ext_cache.FileResponse>[
        mockFileRes1,
        mockFileRes2,
      ]);
      when(() => mockFileRes1.originalUrl).thenReturn('validUrl');
      when(() => mockFileRes2.originalUrl).thenReturn('url2');
      when(
        () => mockManager.getFileStream(
          any(),
          key: any(named: 'key'),
          headers: any(named: 'headers'),
          withProgress: any(named: 'withProgress'),
        ),
      ).thenAnswer((_) => mockStream);

      final Stream<String> result = cacheManager.getFileStream(
        'testUrl',
        key: 'testKey',
        headers: <String, String>{'Header': 'Value'},
        withProgress: true,
        validDuration: const Duration(hours: 1),
      );

      expect(result, isA<Stream<String>>());
      final Stream<String> stream = result;
      final String firstVal = await stream.first;
      final String lastVal = await stream.last;
      expect(firstVal, equals('validUrl'));
      expect(lastVal, equals('url2'));
      verify(
        () => mockManager.getFileStream(
          'testUrl',
          key: 'testKey',
          headers: any(named: 'headers'),
          withProgress: true,
        ),
      ).called(1);
    });

    test('getFile calls getSingleFile on the manager and returns File',
        () async {
      final MockFile mockFile = MockFile();
      when(
        () => mockManager.getSingleFile(
          any(),
          key: any(named: 'key'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => mockFile);
      when(() => mockFile.path).thenReturn('testUrl');

      final File result = await cacheManager.getFile(
        'testUrl',
        key: 'testKey',
        headers: <String, String>{'Header': 'Value'},
        validDuration: const Duration(hours: 1),
      );

      expect(result, isA<File>());
      expect(result.path, equals('testUrl'));
      verify(
        () => mockManager.getSingleFile(
          'testUrl',
          key: 'testKey',
          headers: <String, String>{
            'Header': 'Value',
            'cache-control': 'max-age=3600',
          },
        ),
      ).called(1);
    });

    test('putFile calls putFile on the manager and returns File', () async {
      final MockFile mockFile = MockFile();
      when(() => mockFile.path).thenReturn('testUrl');
      when(
        () => mockManager.putFile(
          any(),
          any(),
          key: any(named: 'key'),
          eTag: any(named: 'eTag'),
          maxAge: any(named: 'maxAge'),
          fileExtension: any(named: 'fileExtension'),
        ),
      ).thenAnswer((_) async => mockFile);

      final File result = await cacheManager.putFile(
        'testUrl',
        Uint8List(0),
        key: 'testKey',
        eTag: 'testETag',
        maxAge: const Duration(days: 1),
        fileExtension: 'jpg',
      );

      expect(result, isA<File>());
      expect(result.path, equals('testUrl'));
      verify(
        () => mockManager.putFile(
          'testUrl',
          any(),
          key: 'testKey',
          eTag: 'testETag',
          maxAge: const Duration(days: 1),
          fileExtension: 'jpg',
        ),
      ).called(1);
    });

    test('putFileStream calls putFileStream on the manager and returns File',
        () async {
      final MockFile mockFile = MockFile();
      when(() => mockFile.path).thenReturn('testUrl');
      when(
        () => mockManager.putFileStream(
          any(),
          any(),
          key: any(named: 'key'),
          eTag: any(named: 'eTag'),
          maxAge: any(named: 'maxAge'),
          fileExtension: any(named: 'fileExtension'),
        ),
      ).thenAnswer((_) async => mockFile);

      final File result = await cacheManager.putFileStream(
        'testUrl',
        const Stream<List<int>>.empty(),
        key: 'testKey',
        eTag: 'testETag',
        maxAge: const Duration(days: 1),
        fileExtension: 'jpg',
      );

      expect(result, isA<File>());
      expect(result.path, equals('testUrl'));
      verify(
        () => mockManager.putFileStream(
          'testUrl',
          any(),
          key: 'testKey',
          eTag: 'testETag',
          maxAge: const Duration(days: 1),
          fileExtension: 'jpg',
        ),
      ).called(1);
    });

    test('removeFile calls removeFile on the manager', () async {
      when(() => mockManager.removeFile(any())).thenAnswer((_) async {});
      await cacheManager.removeFile('testKey');
      verify(() => mockManager.removeFile('testKey')).called(1);
    });
  });
}
