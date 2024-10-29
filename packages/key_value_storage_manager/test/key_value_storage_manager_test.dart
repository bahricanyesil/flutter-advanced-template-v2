import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:key_value_storage_manager/key_value_storage_manager.dart';
import 'package:key_value_storage_manager/src/exceptions/index.dart';
import 'package:key_value_storage_manager/src/models/base_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/test_model.dart';

void main() {
  late SharedPreferences mockPreferences;
  late SharedPreferencesManager manager;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    mockPreferences = await SharedPreferences.getInstance();
    manager = SharedPreferencesManager(preferences: mockPreferences);
  });

  group('SharedPreferencesManager', () {
    test('supportedTypes returns correct list', () {
      expect(
        manager.supportedTypes,
        <Type>[String, int, double, bool, BaseDataModel, List],
      );
    });

    group('containsKey', () {
      test('returns true when key exists', () async {
        await mockPreferences.setString('existingKey', 'value');
        expect(manager.containsKey('existingKey'), isTrue);
      });

      test('returns false when key does not exist', () {
        expect(manager.containsKey('nonExistingKey'), isFalse);
      });
    });

    group('delete', () {
      test('returns true when key is successfully deleted', () async {
        await mockPreferences.setString('existingKey', 'value');
        expect(await manager.delete(key: 'existingKey'), isTrue);
        expect(mockPreferences.containsKey('existingKey'), isFalse);
      });

      test('returns false when key does not exist', () async {
        expect(await manager.delete(key: 'nonExistingKey'), isFalse);
      });
    });

    test('deleteAll clears all preferences', () async {
      await mockPreferences.setString('key1', 'value1');
      await mockPreferences.setInt('key2', 2);
      expect(await manager.deleteAll(), isTrue);
      expect(mockPreferences.getKeys().isEmpty, isTrue);
    });

    group('read', () {
      test('returns value when type matches', () async {
        await mockPreferences.setString('stringKey', 'value');
        expect(manager.read<String>('stringKey'), 'value');
      });

      test('returns null when value is null', () {
        expect(manager.read<String>('nullKey'), isNull);
      });

      test('MismatchedTypeException has correct message', () async {
        await mockPreferences.setInt('intKey', 42);
        try {
          manager.read<String>('intKey');
          fail('Expected MismatchedTypeException to be thrown');
        } catch (e) {
          expect(e, isA<MismatchedTypeException>());
          expect(
            e.toString(),
            'MismatchedTypeException: Expected type String, but found int.',
          );
        }
      });

      test('parses primitive types when tryToParse is true', () async {
        await mockPreferences.setString('intAsString', '42');
        expect(manager.read<int>('intAsString', tryToParse: true), 42);

        await mockPreferences.setString('doubleAsString', '3.14');
        expect(manager.read<double>('doubleAsString', tryToParse: true), 3.14);

        await mockPreferences.setString('boolAsString', 'true');
        expect(manager.read<bool>('boolAsString', tryToParse: true), isTrue);

        final List<int> listInt = <int>[1, 2, 3];
        await mockPreferences.setString(
          'listIntAsString',
          listInt.toString(),
        );
        expect(
          manager.read<List<int>>('listIntAsString', tryToParse: true),
          <int>[1, 2, 3],
        );

        final List<String> listString = <String>['a', 'b', 'c'];
        await mockPreferences.setString(
          'listStringAsString',
          jsonEncode(listString),
        );
        expect(
          manager.read<List<String>>('listStringAsString', tryToParse: true),
          <String>['a', 'b', 'c'],
        );

        final List<bool> listBool = <bool>[true, false, true];
        await mockPreferences.setString(
          'listBoolAsString',
          listBool.toString(),
        );
        expect(
          manager.read<List<bool>>('listBoolAsString', tryToParse: true),
          <bool>[true, false, true],
        );

        final List<double> listDouble = <double>[1.1, 2.2, 3.3];
        await mockPreferences.setString(
          'listDoubleAsString',
          listDouble.toString(),
        );
        expect(
          manager.read<List<double>>('listDoubleAsString', tryToParse: true),
          <double>[1.1, 2.2, 3.3],
        );

        expect(DataParserHelpers.parsePrimitive<String>('value'), 'value');
      });

      test('throws UnsuccessfulParseException for unsupported types', () async {
        try {
          await mockPreferences.setString('complexKey', '12');
          manager.read<Map<String, dynamic>>(
            'complexKey',
            tryToParse: true,
          );
        } catch (e) {
          expect(e, isA<UnsuccessfulParseException>());
          expect(
            e.toString(),
            '''UnsuccessfulParseException: Could not parse 12 to type Map<String, dynamic>.''',
          );
        }

        await mockPreferences
            .setStringList('complexList', <String>['test1', 'test2']);
        expect(
          () => manager.read<Map<String, dynamic>>(
            'complexList',
            tryToParse: true,
          ),
          throwsA(isA<UnsuccessfulParseException>()),
        );
      });

      test('uses fromJson function for BaseDataModel types', () async {
        await mockPreferences.setString(
          'modelKey',
          '{"id": 1, "name": "Test"}',
        );
        expect(
          manager.read<TestModel>(
            'modelKey',
            tryToParse: true,
            fromJson: (String? json) =>
                json == null ? null : TestModel.fromJson(json),
          ),
          isA<TestModel>(),
        );
      });
    });

    group('write', () {
      test('throws EmptyKeyException for empty key', () async {
        try {
          await manager.write(key: '', value: 'test');
        } catch (e) {
          expect(e, isA<EmptyKeyException>());
          expect(e.toString(), 'EmptyKeyException: Key cannot be empty.');
        }
      });

      test('writes String value', () async {
        expect(await manager.write(key: 'stringKey', value: 'value'), isTrue);
        expect(mockPreferences.getString('stringKey'), 'value');
      });

      test('writes int value', () async {
        expect(await manager.write(key: 'intKey', value: 42), isTrue);
        expect(mockPreferences.getInt('intKey'), 42);
      });

      test('writes double value', () async {
        expect(await manager.write(key: 'doubleKey', value: 3.14), isTrue);
        expect(mockPreferences.getDouble('doubleKey'), 3.14);
      });

      test('writes bool value', () async {
        expect(await manager.write(key: 'boolKey', value: true), isTrue);
        expect(mockPreferences.getBool('boolKey'), true);
      });

      test('writes List<String> value', () async {
        expect(
          await manager.write(key: 'listKey', value: <String>['a', 'b']),
          isTrue,
        );
        expect(mockPreferences.getStringList('listKey'), <String>['a', 'b']);
      });

      test('writes List<BaseDataModel> value', () async {
        final List<TestModel> models = <TestModel>[
          TestModel(id: 1, name: 'Test1'),
          TestModel(id: 2, name: 'Test2'),
        ];
        expect(
          await manager.write(key: 'modelList', value: models),
          isTrue,
        );
        expect(
          mockPreferences.getStringList('modelList'),
          models.map((TestModel e) => e.toJson()).toList(),
        );
      });

      test('writes List<int> value', () async {
        expect(
          await manager.write(key: 'intList', value: <int>[1, 2, 3]),
          isTrue,
        );
        expect(
          mockPreferences.getStringList('intList'),
          <String>['1', '2', '3'],
        );
      });

      test('writes BaseDataModel value', () async {
        final TestModel model = TestModel(id: 1, name: 'Test');
        expect(
          await manager.write(key: 'modelKey', value: model),
          isTrue,
        );
        expect(
          mockPreferences.getString('modelKey'),
          '{"id":1,"name":"Test"}',
        );
      });

      test('writes unsupported type as String when defaultToString is true',
          () async {
        final DateTime unsupportedValue = DateTime(2023);
        expect(
          await manager.write(
            key: 'dateKey',
            value: unsupportedValue,
            defaultToString: true,
          ),
          isTrue,
        );
        expect(
          mockPreferences.getString('dateKey'),
          unsupportedValue.toString(),
        );
      });

      test('throws UnsupportedTypeException for unsupported types', () async {
        try {
          await manager
              .write(key: 'unsupportedKey', value: <String, dynamic>{});
        } catch (e) {
          expect(e, isA<UnsupportedTypeException>());
          expect(
            e.toString(),
            '''UnsupportedTypeException: Type Map<String, dynamic> is not supported. Supported types are [String, int, double, bool, BaseDataModel<dynamic>, List<dynamic>]''',
          );
        }
      });
    });

    group('readModelList', () {
      test('returns null when list is not found', () {
        expect(
          manager.readModelList<TestModel>(
            'nonExistingList',
            TestModel.fromJson,
          ),
          isNull,
        );
      });

      test('returns list of models when found', () async {
        await mockPreferences.setStringList('modelList', <String>[
          '{"id":1,"name":"Test1"}',
          '{"id":2,"name":"Test2"}',
        ]);
        final List<TestModel>? result =
            manager.readModelList<TestModel>('modelList', TestModel.fromJson);
        expect(result, isA<List<TestModel>>());
        expect(result!.length, 2);
        expect(result[0].id, 1);
        expect(result[1].name, 'Test2');
      });
    });
  });
}
