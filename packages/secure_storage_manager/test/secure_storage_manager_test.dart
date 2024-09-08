import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:secure_storage_manager/secure_storage_manager.dart';

import 'mocks/mock_flutter_secure_storage.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageManagerImpl manager;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    manager = SecureStorageManagerImpl(storage: mockStorage);
  });

  group('SecureStorageManagerImpl', () {
    test('containsKey returns true when key exists', () async {
      when(() => mockStorage.containsKey(key: any(named: 'key')))
          .thenAnswer((_) async => true);

      expect(await manager.containsKey('testKey'), isTrue);
    });

    test('containsKey returns false when key does not exist', () async {
      when(() => mockStorage.containsKey(key: any(named: 'key')))
          .thenAnswer((_) async => false);

      expect(await manager.containsKey('testKey'), isFalse);
    });

    test('delete returns true and deletes when key exists', () async {
      when(() => mockStorage.containsKey(key: any(named: 'key')))
          .thenAnswer((_) async => true);
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {
        return;
      });

      expect(await manager.delete(key: 'testKey'), isTrue);
      verify(() => mockStorage.delete(key: 'testKey')).called(1);
    });

    test('delete returns false when key does not exist', () async {
      when(() => mockStorage.containsKey(key: any(named: 'key')))
          .thenAnswer((_) async => false);

      expect(await manager.delete(key: 'testKey'), isFalse);
      verifyNever(() => mockStorage.delete(key: any(named: 'key')));
    });

    test('deleteAll calls underlying storage method', () async {
      when(() => mockStorage.deleteAll()).thenAnswer((_) async {
        return;
      });

      await manager.deleteAll();
      verify(() => mockStorage.deleteAll()).called(1);
    });

    test('read returns value when key exists', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'testValue');

      expect(await manager.read(key: 'testKey'), equals('testValue'));
    });

    test('read returns null when key does not exist', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      expect(await manager.read(key: 'testKey'), isNull);
    });

    test('write calls underlying storage method', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await manager.write(key: 'testKey', value: 'testValue');
      verify(() => mockStorage.write(key: 'testKey', value: 'testValue'))
          .called(1);
    });
  });
}
