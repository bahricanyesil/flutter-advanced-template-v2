import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_manager/network_manager.dart';
import 'package:network_manager/src/exceptions/mismatched_type_exception.dart';
import 'package:network_manager/src/exceptions/unsuccessful_parse_exception.dart';

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
      final BaseNetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
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

      final BaseNetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
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
      final BaseNetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
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

      final BaseNetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
          await networkManager.requestWithoutBody<DefaultModelT>(
        '/test',
        methodType: MethodTypes.get,
      );

      expect(res.responseData, isNull);
      expect(res.error, isNotNull);
      expect(res.error, exception);
      expect(res.hasError(), isTrue);
      expect(res.errorData, errorModel);
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('Mismatched type should throw MismatchedTypeException', () async {
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
        return dio.ResponseBody.fromString('', 200);
      });

      final BaseNetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
          await networkManager.sendRequest<DefaultModelT, DefaultModelT>(
        '/test',
        body: data,
        methodType: MethodTypes.get,
      );

      expect(res.responseData, isNull);
      expect(res.error, isA<MismatchedTypeException>());
      expect(res.errorData, isNull);
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

      final BaseNetworkResponseModel<ListResponseModel<int>, DefaultErrorModel>
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
      final DefaultErrorModel errorModel = DefaultErrorModel(
        message: jsonEncode(
          <String, dynamic>{
            'tr': 'test hata mesajı',
            'en': 'test error message',
          },
        ),
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

      final BaseNetworkResponseModel<ListResponseModel<int>, DefaultErrorModel>
          res = await networkManager.downloadFile<DefaultModelT>(
        '/test',
        onReceiveProgress: (int count, int total) => expect(count, 40),
      );

      expect(res.responseData, isNull);
      expect(res.error, isNotNull);
      expect(res.error, exception);
      expect(res.errorData?.message, 'test error message');
      verify(() => mockDioAdapter.fetch(any(), any(), any())).called(1);
    });

    test('UnsuccessfulParseException should be thrown', () async {
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
        return dio.ResponseBody.fromString(
          jsonEncode(<String, dynamic>{
            'data': <String>['test data'],
          }),
          200,
        );
      });
      try {
        await networkManager.sendRequest<DefaultModelT, DefaultModelT>(
          '/test',
          body: data,
          methodType: MethodTypes.get,
        );
      } catch (e) {
        expect(e, isA<UnsuccessfulParseException>());
      }
    });

    test('uploadFile method is called with correct parameters', () async {
      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
        return dio.ResponseBody.fromString(data.toJson(), 200);
      });

      final BaseNetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
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
      final BaseNetworkResponseModel<DefaultModelT, DefaultErrorModel> res =
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

      final BaseNetworkResponseModel<dio.Response<Object?>, DefaultErrorModel>
          res =
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

      final BaseNetworkResponseModel<dio.Response<Object?>, DefaultErrorModel>
          res =
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

    test('addAllIfNotExists method works correctly', () {
      final int interceptorLength = networkManager.allInterceptors.length;
      final List<dio.Interceptor> interceptors = <dio.Interceptor>[
        dio.InterceptorsWrapper(),
        dio.InterceptorsWrapper(),
      ];
      networkManager.addAllInterceptors(interceptors);
      expect(networkManager.allInterceptors.length, interceptorLength + 2);
      expect(
        networkManager.allInterceptors.sublist(interceptorLength),
        equals(interceptors),
      );
    });
  });

  group('MethodTypeListExt', () {
    test('find returns correct MethodType for valid name', () {
      const List<MethodTypes> methodTypes = MethodTypes.values;

      expect(methodTypes.find('get'), equals(MethodTypes.get));
      expect(methodTypes.find('post'), equals(MethodTypes.post));
      expect(methodTypes.find('put'), equals(MethodTypes.put));
      expect(methodTypes.find('delete'), equals(MethodTypes.delete));
      expect(methodTypes.find('patch'), equals(MethodTypes.patch));
    });

    test('find returns null for invalid name', () {
      const List<MethodTypes> methodTypes = MethodTypes.values;

      expect(methodTypes.find('invalid'), isNull);
      expect(methodTypes.find(''), isNull);
    });

    test('find is case-sensitive', () {
      const List<MethodTypes> methodTypes = MethodTypes.values;

      expect(methodTypes.find('GET'), isNull);
      expect(methodTypes.find('Post'), isNull);
    });
  });

  group('TokenTypes', () {
    test('isRefresh getter', () {
      expect(TokenTypes.refreshToken.isRefresh, isTrue);
      expect(TokenTypes.accessToken.isRefresh, isFalse);
      expect(TokenTypes.confirmToken.isRefresh, isFalse);
    });
  });
}
