import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_manager/network_manager.dart';
import 'package:network_manager/src/enums/method_types.dart';
import 'package:network_manager/src/models/index.dart';

import 'mocks/mock_dio_adapter.dart';

typedef DefaultModelT = DefaultDataModel<Map<String, dynamic>>;

void main() {
  late NetworkManagerImpl<DefaultErrorModel> networkManager;
  late MockDioAdapter mockDioAdapter;

  const Map<String, dynamic> movieData = <String, dynamic>{
    'data': 'test data',
    'id': 1,
    'title': 'test title',
    'year': '2024',
    'director': 'test director',
    'genre': 'test genre',
    'rating': 10,
    'description': 'test description',
    'poster': 'test poster',
    'trailer': 'test trailer',
  };
  const DefaultModelT data = DefaultModelT(
    data: movieData,
    resultCode: '200',
    resultMessage: <LanguageTypes, String>{
      LanguageTypes.tr: 'test data',
    },
  );
  final dio.FormData formData = dio.FormData.fromMap(<String, dynamic>{
    'file': 'test file',
  });

  final NetworkManagerParamsModel params = NetworkManagerParamsModel(
    baseOptions: dio.BaseOptions(baseUrl: 'https://api.example.com'),
  );

  setUpAll(() {
    registerFallbackValue(dio.RequestOptions(path: '/test'));
  });

  setUp(() {
    mockDioAdapter = MockDioAdapter();
    networkManager = NetworkManagerImpl<DefaultErrorModel>(
      params: params,
      clientAdapter: mockDioAdapter,
    );
  });

  group('NetworkManagerImpl', () {
    test('constructor initializes properly', () {
      expect(networkManager, isNotNull);
      expect(networkManager.options.baseUrl, 'https://api.example.com');
    });

    test('create network manager without a client adapter', () {
      final NetworkManagerImpl<DefaultErrorModel> nM =
          NetworkManagerImpl<DefaultErrorModel>(params: params);
      expect(nM, isNotNull);
      expect(nM.options.baseUrl, 'https://api.example.com');
    });

    test('sendRequest method is called with correct parameters', () async {
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
        return dio.ResponseBody.fromString(data.toJson(), 200);
      });
      final NetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
          await networkManager.sendRequest<DefaultModelT, DefaultModelT>(
        '/test',
        body: data,
        methodType: MethodTypes.get,
      );

      expect(res.responseData, data);
      expect(res.error, isNull);
      expect(res.errorData, isNull);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('sendRequest handles DioException', () async {
      const DefaultErrorModel errorModel =
          DefaultErrorModel(message: 'test data', resultCode: '200');
      final dio.DioException exception = dio.DioException(
        requestOptions: dio.RequestOptions(path: '/test'),
        response: dio.Response<Object?>(
          requestOptions: dio.RequestOptions(path: '/test'),
          data: errorModel,
          statusCode: 404,
        ),
      );
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenThrow(exception);

      final NetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
          await networkManager.sendRequest<DefaultModelT, DefaultModelT>(
        '/test',
        body: const DefaultModelT(
          data: movieData,
          resultCode: '200',
          resultMessage: <LanguageTypes, String>{
            LanguageTypes.tr: 'test data',
          },
        ),
        methodType: MethodTypes.get,
      );

      expect(res.responseData, isNull);
      expect(res.error, isNotNull);
      expect(res.error, exception);
      expect(res.errorData, errorModel);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('requestWithoutBody method is called with correct parameters',
        () async {
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
        return dio.ResponseBody.fromString(data.toJson(), 200);
      });
      final NetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
          await networkManager.requestWithoutBody<DefaultModelT>(
        '/test',
        methodType: MethodTypes.get,
      );

      expect(res.responseData, data);
      expect(res.error, isNull);
      expect(res.errorData, isNull);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('requestWithoutBody handles DioException', () async {
      const DefaultErrorModel errorModel = DefaultErrorModel(
        message: 'test data',
        resultCode: '200',
      );
      final dio.DioException exception = dio.DioException(
        requestOptions: dio.RequestOptions(path: '/test'),
        response: dio.Response<Object?>(
          requestOptions: dio.RequestOptions(path: '/test'),
          data: errorModel,
          statusCode: 404,
        ),
      );
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenThrow(exception);

      final NetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
          await networkManager.requestWithoutBody<DefaultModelT>(
        '/test',
        methodType: MethodTypes.get,
      );

      expect(res.responseData, isNull);
      expect(res.error, isNotNull);
      expect(res.error, exception);
      expect(res.errorData, errorModel);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('downloadFile method is called with correct parameters', () async {
      final List<int> fileBytes = List<int>.generate(
        40,
        (int index) => index * Random().nextInt(4) + 1,
      );
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
        return dio.ResponseBody.fromBytes(fileBytes, 200);
      });

      final NetworkResponseModel<ListResponseModel<int>, DefaultErrorModel>
          res = await networkManager.downloadFile<DefaultModelT>(
        '/test',
        body: data,
        onReceiveProgress: (int count, int total) => expect(count, 40),
      );

      expect(res.responseData, isNotNull);
      expect(res.responseData?.dataList, fileBytes);
      expect(res.errorData, isNull);
      expect(res.error, isNull);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('downloadFile handles DioException', () async {
      const DefaultErrorModel errorModel = DefaultErrorModel(
        message: 'test data',
        resultCode: '200',
      );
      final dio.DioException exception = dio.DioException(
        requestOptions: dio.RequestOptions(path: '/test'),
        response: dio.Response<Object?>(
          requestOptions: dio.RequestOptions(path: '/test'),
          data: errorModel,
          statusCode: 404,
        ),
      );
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenThrow(exception);

      final NetworkResponseModel<ListResponseModel<int>, DefaultErrorModel>
          res = await networkManager.downloadFile<DefaultModelT>(
        '/test',
        onReceiveProgress: (int count, int total) => expect(count, 40),
      );

      expect(res.responseData, isNull);
      expect(res.error, isNotNull);
      expect(res.error, exception);
      expect(res.errorData, errorModel);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('uploadFile method is called with correct parameters', () async {
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
        return dio.ResponseBody.fromString(data.toJson(), 200);
      });

      final NetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
          await networkManager.uploadFile<dio.FormData, DefaultModelT>(
        '/test',
        formData,
      );

      expect(res.responseData, data);
      expect(res.error, isNull);
      expect(res.errorData, isNull);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('uploadFile handles DioException', () async {
      const DefaultErrorModel errorModel = DefaultErrorModel(
        message: 'test data',
        resultCode: '200',
      );
      final dio.DioException exception = dio.DioException(
        requestOptions: dio.RequestOptions(path: '/test'),
        response: dio.Response<Object?>(
          requestOptions: dio.RequestOptions(path: '/test'),
          data: errorModel,
          statusCode: 404,
        ),
      );
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenThrow(exception);

      final dio.FormData errorFormData = dio.FormData.fromMap(<String, dynamic>{
        'file': 'errorFormData file',
      });
      final NetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
          await networkManager.uploadFile<dio.FormData, DefaultModelT>(
        '/test',
        errorFormData,
      );

      expect(res.responseData, isNull);
      expect(res.error, isNotNull);
      expect(res.error, exception);
      expect(res.errorData, errorModel);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('dioRequest method is called with correct parameters', () async {
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
        return dio.ResponseBody.fromString(data.toJson(), 200);
      });

      final NetworkResponseModel<dio.Response<Object?>, DefaultErrorModel> res =
          await networkManager.dioRequest('/test', methodType: MethodTypes.get);

      expect(res.responseData, isNotNull);
      expect(res.responseData?.data, data.toJson());
      expect(res.error, isNull);
      expect(res.errorData, isNull);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('dioRequest handles DioException', () async {
      const DefaultErrorModel errorModel = DefaultErrorModel(
        message: 'test data',
        resultCode: '200',
      );
      final dio.DioException exception = dio.DioException(
        requestOptions: dio.RequestOptions(path: '/test'),
        response: dio.Response<Object?>(
          requestOptions: dio.RequestOptions(path: '/test'),
          data: errorModel,
          statusCode: 404,
        ),
      );
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenThrow(exception);

      final NetworkResponseModel<dio.Response<Object?>, DefaultErrorModel> res =
          await networkManager.dioRequest('/test', methodType: MethodTypes.get);

      expect(res.responseData, isNull);
      expect(res.error, isNotNull);
      expect(res.error, exception);
      expect(res.errorData, errorModel);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('addBaseHeader and removeBaseHeader methods work correctly', () {
      expect(
        networkManager.allHeaders,
        isNot(containsPair('test-key', 'test-value')),
      );
      networkManager.addBaseHeader(
        const MapEntry<String, String>('test-key', 'test-value'),
      );
      expect(networkManager.allHeaders, containsPair('test-key', 'test-value'));

      networkManager.removeHeader('test-key');
      expect(
        networkManager.allHeaders,
        isNot(containsPair('test-key', 'test-value')),
      );

      networkManager.addBaseHeader(
        const MapEntry<String, String>('test2-key', 'test2-value'),
      );
      expect(
        networkManager.allHeaders,
        containsPair('test2-key', 'test2-value'),
      );
      networkManager.clearHeader();
      expect(networkManager.allHeaders, isEmpty);
    });

    test('addInterceptor and removeInterceptor methods work correctly', () {
      final dio.Interceptor interceptor = dio.InterceptorsWrapper();
      expect(networkManager.allInterceptors, isNot(contains(interceptor)));

      networkManager.insertInterceptor(interceptor);
      expect(networkManager.allInterceptors, contains(interceptor));

      networkManager.removeInterceptor(interceptor);
      expect(networkManager.allInterceptors, isNot(contains(interceptor)));
    });
  });
}
