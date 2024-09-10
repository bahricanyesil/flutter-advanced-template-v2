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
      const DefaultModelT data = DefaultModelT(
        data: movieData,
        resultCode: '200',
        resultMessage: <LanguageTypes, String>{
          LanguageTypes.tr: 'test data',
        },
      );

      when(() => mockDioAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
        return dio.ResponseBody.fromString(
          data.toJson(),
          200,
        );
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
  });
}
