import 'package:cloud_database_manager/cloud_database_manager.dart';
import 'package:cloud_database_manager/src/entities/where_condition.dart';
import 'package:cloud_database_manager/src/enums/where_operator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/mock_firebase_firestore.dart';
import 'mocks/mock_log_manager.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseCloudDatabaseManager manager;
  late MockLogManager mockLogManager;
  late MockFirebaseFirestore mockFirestore;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockLogManager = MockLogManager();
    mockFirestore = MockFirebaseFirestore();
    manager = FirebaseCloudDatabaseManager(
      fakeFirestore,
      logManager: mockLogManager,
    );
    await fakeFirestore.collection('test_collection').add(<String, dynamic>{
      'name': 'Test 1',
      'age': 20,
      'tags': <String>['tag1', 'tag2'],
    });
    await fakeFirestore.collection('test_collection').add(<String, dynamic>{
      'name': 'Test 2',
      'age': 30,
      'tags': <String>['tag1', 'tag2'],
    });
    await fakeFirestore.collection('test_collection').add(<String, dynamic>{
      'name': 'Test 3',
      'age': 20,
      'tags': <String>['tag1', 'tag3'],
    });
  });

  group('fetchDocumentById', () {
    test('should return document data when document exists', () async {
      await fakeFirestore
          .collection('test_collection')
          .doc('1')
          .set(<String, dynamic>{'name': 'Test'});

      final (Map<String, dynamic>?, String?) result =
          await manager.fetchDocumentById('test_collection', '1');

      expect(result.$1, <String, String>{'name': 'Test', 'id': '1'});
      expect(result.$2, isNull);
    });

    test('should return null data when document does not exist', () async {
      final (Map<String, dynamic>?, String?) result =
          await manager.fetchDocumentById('test_collection', '1');

      expect(result.$1, isNull);
      expect(result.$2, isNull);
    });

    test('should handle FirebaseException and Exception', () async {
      const String collectionName = 'test_collection';
      const String docId = '1';
      final DocumentReference<Map<String, dynamic>> doc =
          fakeFirestore.collection(collectionName).doc(docId);

      const String exceptionMessage = 'Error fetching document: ';
      whenCalling(Invocation.method(#get, null)).on(doc).thenThrow(
            FirebaseException(plugin: 'firestore', message: exceptionMessage),
          );

      final (Map<String, dynamic>?, String?) result =
          await manager.fetchDocumentById(collectionName, docId);

      expect(result.$1, isNull);
      expect(result.$2, contains(exceptionMessage));

      const String docId2 = '2';
      final DocumentReference<Map<String, dynamic>> doc2 =
          fakeFirestore.collection(collectionName).doc(docId2);

      whenCalling(Invocation.method(#get, null)).on(doc2).thenThrow(
            Exception(exceptionMessage),
          );

      final (Map<String, dynamic>?, String?) result2 =
          await manager.fetchDocumentById(collectionName, docId2);

      expect(result2.$1, isNull);
      expect(result2.$2, Exception(exceptionMessage).toString());
    });
  });

  group('fetchAllDocuments', () {
    test('should return all documents without condition', () async {
      final (List<Map<String, dynamic>>?, String?) result =
          await manager.fetchAllDocuments('test_collection');

      expect(result.$1?.length, 3);
      expect(result.$1?[0]['name'], 'Test 1');
      expect(result.$1?[0]['id'], isNotNull);
      expect(result.$1?[1]['name'], 'Test 2');
      expect(result.$1?[1]['id'], isNotNull);
      expect(result.$1?[2]['name'], 'Test 3');
      expect(result.$1?[2]['id'], isNotNull);
      expect(result.$2, isNull);
    });

    test('should return documents where age is equal to a value', () async {
      final (List<Map<String, dynamic>>?, String?) result =
          await manager.fetchAllDocuments(
        'test_collection',
        condition: const WhereCondition<int>(
          field: 'age',
          operator: WhereOperator.isEqualTo,
          value: 20,
        ),
      );
      expect(result.$1?.length, 2);
      expect(result.$1?[0]['name'], 'Test 1');
    });

    test('should return documents where tags contains any of the values',
        () async {
      final (List<Map<String, dynamic>>?, String?) containsAnyResult =
          await manager.fetchAllDocuments(
        'test_collection',
        condition: const WhereCondition<List<String>>(
          field: 'tags',
          operator: WhereOperator.arrayContainsAny,
          value: <String>['tag2', 'tag3'],
        ),
      );
      expect(containsAnyResult.$1?.length, 3);
      expect(containsAnyResult.$1?[0]['name'], 'Test 1');
      expect(containsAnyResult.$1?[1]['name'], 'Test 2');
      expect(containsAnyResult.$1?[2]['name'], 'Test 3');
    });

    test('should return documents where tags contains a value', () async {
      final (List<Map<String, dynamic>>?, String?) containsResult =
          await manager.fetchAllDocuments(
        'test_collection',
        condition: const WhereCondition<String>(
          field: 'tags',
          operator: WhereOperator.arrayContains,
          value: 'tag2',
        ),
      );

      expect(containsResult.$1?.length, 2);
      expect(containsResult.$1?[0]['name'], 'Test 1');
      expect(containsResult.$1?[1]['name'], 'Test 2');
    });

    test('should return documents where age is greater than a value', () async {
      final (List<Map<String, dynamic>>?, String?) greaterThanResult =
          await manager.fetchAllDocuments(
        'test_collection',
        condition: const WhereCondition<int>(
          field: 'age',
          operator: WhereOperator.isGreaterThan,
          value: 25,
        ),
      );

      expect(greaterThanResult.$1?.length, 1);
      expect(greaterThanResult.$1?[0]['name'], 'Test 2');
    });

    test('should return documents where age is less than a value', () async {
      final (List<Map<String, dynamic>>?, String?) lessThanResult =
          await manager.fetchAllDocuments(
        'test_collection',
        condition: const WhereCondition<int>(
          field: 'age',
          operator: WhereOperator.isLessThan,
          value: 25,
        ),
      );

      expect(lessThanResult.$1?.length, 2);
      expect(lessThanResult.$1?[0]['name'], 'Test 1');
      expect(lessThanResult.$1?[1]['name'], 'Test 3');
    });

    test('should return documents where age is less than or equal to a value',
        () async {
      final (List<Map<String, dynamic>>?, String?) lessThanOrEqualToResult =
          await manager.fetchAllDocuments(
        'test_collection',
        condition: const WhereCondition<int>(
          field: 'age',
          operator: WhereOperator.isLessThanOrEqualTo,
          value: 20,
        ),
      );

      expect(lessThanOrEqualToResult.$1?.length, 2);
      expect(lessThanOrEqualToResult.$1?[0]['name'], 'Test 1');
      expect(lessThanOrEqualToResult.$1?[1]['name'], 'Test 3');
    });

    test(
        'should return documents where age is greater than or equal to a value',
        () async {
      final (List<Map<String, dynamic>>?, String?) greaterThanOrEqualToResult =
          await manager.fetchAllDocuments(
        'test_collection',
        condition: const WhereCondition<int>(
          field: 'age',
          operator: WhereOperator.isGreaterThanOrEqualTo,
          value: 20,
        ),
      );

      expect(greaterThanOrEqualToResult.$1?.length, 3);
      expect(greaterThanOrEqualToResult.$1?[0]['name'], 'Test 1');
      expect(greaterThanOrEqualToResult.$1?[1]['name'], 'Test 2');
      expect(greaterThanOrEqualToResult.$1?[2]['name'], 'Test 3');
    });

    test('should handle FirebaseException and Exception', () async {
      const String collectionName = 'test_collection';
      final DocumentReference<Map<String, dynamic>> doc =
          fakeFirestore.collection(collectionName).doc('id');
      const String exceptionMessage = 'Error fetching all documents: ';
      whenCalling(Invocation.method(#get, null)).on(doc).thenThrow(
            FirebaseException(plugin: 'firestore', message: exceptionMessage),
          );
      final (List<Map<String, dynamic>>?, String?) result =
          await manager.fetchAllDocuments(collectionName);
      expect(result.$1, isNull);
      expect(result.$2, contains(exceptionMessage));

      const String collectionName2 = 'test_collection2';
      final DocumentReference<Map<String, dynamic>> doc2 =
          fakeFirestore.collection(collectionName2).doc('id');
      whenCalling(Invocation.method(#get, null)).on(doc2).thenThrow(
            Exception(exceptionMessage),
          );
      final (List<Map<String, dynamic>>?, String?) result2 =
          await manager.fetchAllDocuments(collectionName2);
      expect(result2.$1, isNull);
      expect(result2.$2, Exception(exceptionMessage).toString());
    });
  });

  group('streamDocs', () {
    test('should return stream of QuerySnapshot', () {
      final (Stream<QuerySnapshot<Map<String, dynamic>>>?, String?) result =
          manager.streamDocs('test_collection');

      expect(result.$1, isA<Stream<QuerySnapshot<Map<String, dynamic>>>>());
      expect(result.$2, isNull);
    });

    test('should handle FirebaseException and Exception', () async {
      final FirebaseCloudDatabaseManager streamManager =
          FirebaseCloudDatabaseManager(
        mockFirestore,
        logManager: mockLogManager,
      );
      const String collectionName = 'test_collection_error';
      const String exceptionMessage = 'Error fetching documents stream';
      when(() => mockFirestore.collection(collectionName).snapshots())
          .thenThrow(
        FirebaseException(
          plugin: 'firestore',
          message: exceptionMessage,
        ),
      );
      final (Stream<QuerySnapshot<Map<String, dynamic>>>?, String?) result =
          streamManager.streamDocs(collectionName);

      expect(result.$1, isNull);
      expect(result.$2, exceptionMessage);

      when(() => mockFirestore.collection(collectionName).snapshots())
          .thenThrow(
        Exception(exceptionMessage),
      );
      final (Stream<QuerySnapshot<Map<String, dynamic>>>?, String?) result2 =
          streamManager.streamDocs(collectionName);
      expect(result2.$1, isNull);
      expect(result2.$2, Exception(exceptionMessage).toString());
    });
  });

  group('addDocument', () {
    test('should add document and return data', () async {
      final (Map<String, dynamic>?, String?) result = await manager.addDocument(
        'test_collection',
        <String, dynamic>{'name': 'New Test'},
      );

      expect(result.$1?['name'], 'New Test');
      expect(result.$2, isNull);
    });

    test('should handle FirebaseException and Exception', () async {
      const String collectionName = 'test_collection';
      const String docPath = 'docPath';
      final DocumentReference<Map<String, dynamic>> doc =
          fakeFirestore.collection(collectionName).doc(docPath);
      const String exceptionMessage = 'Error adding document';
      whenCalling(Invocation.method(#set, null)).on(doc).thenThrow(
            FirebaseException(plugin: 'firestore', message: exceptionMessage),
          );
      final (Map<String, dynamic>?, String?) result = await manager.addDocument(
        collectionName,
        <String, dynamic>{'name': 'New Test'},
        docPath: docPath,
      );
      expect(result.$1, isNull);
      expect(result.$2, exceptionMessage);

      const String collectionName2 = 'test_collection2';
      const String docPath2 = 'docPath2';
      final DocumentReference<Map<String, dynamic>> doc2 =
          fakeFirestore.collection(collectionName2).doc(docPath2);
      whenCalling(Invocation.method(#set, null)).on(doc2).thenThrow(
            Exception(exceptionMessage),
          );
      final (Map<String, dynamic>?, String?) result2 =
          await manager.addDocument(
        collectionName2,
        <String, dynamic>{'name': 'New Test'},
        docPath: docPath2,
      );
      expect(result2.$1, isNull);
      expect(result2.$2, Exception(exceptionMessage).toString());
    });
  });

  group('updateDocument', () {
    test('should update document successfully', () async {
      final DocumentReference<Map<String, dynamic>> docRef = await fakeFirestore
          .collection('test_collection')
          .add(<String, dynamic>{'name': 'Original'});

      final String? result = await manager.updateDocument(
        'test_collection',
        docRef.id,
        <String, dynamic>{'name': 'Updated Test'},
      );

      expect(result, isNull);

      final DocumentSnapshot<Map<String, dynamic>> updatedDoc =
          await fakeFirestore
              .collection('test_collection')
              .doc(docRef.id)
              .get();
      expect(updatedDoc.data()?['name'], 'Updated Test');
    });

    test('should handle FirebaseException and Exception', () async {
      const String collectionName = 'test_collection';
      const String docId = '1';
      await fakeFirestore.collection(collectionName).doc(docId).set(
        <String, dynamic>{'name': 'To Update'},
      );
      final DocumentReference<Map<String, dynamic>> doc =
          fakeFirestore.collection(collectionName).doc(docId);
      const String exceptionMessage = 'Error updating document';
      whenCalling(Invocation.method(#update, null)).on(doc).thenThrow(
            FirebaseException(plugin: 'firestore', message: exceptionMessage),
          );
      final String? result = await manager.updateDocument(
        collectionName,
        docId,
        <String, dynamic>{'name': 'Updated Test'},
      );
      expect(result, exceptionMessage);

      const String collectionName2 = 'test_collection_2';
      const String docId2 = '2';
      await fakeFirestore.collection(collectionName2).doc(docId2).set(
        <String, dynamic>{'name': 'To Update'},
      );
      final DocumentReference<Map<String, dynamic>> doc2 =
          fakeFirestore.collection(collectionName2).doc(docId2);
      whenCalling(Invocation.method(#update, null)).on(doc2).thenThrow(
            Exception(exceptionMessage),
          );
      final String? result2 = await manager.updateDocument(
        collectionName2,
        docId2,
        <String, dynamic>{'name': 'Updated Test'},
      );
      expect(result2, Exception(exceptionMessage).toString());
    });
  });

  group('deleteDocument', () {
    test('should delete existing document successfully', () async {
      final DocumentReference<Map<String, dynamic>> docRef = await fakeFirestore
          .collection('test_collection')
          .add(<String, dynamic>{'name': 'To Delete'});

      final String? result =
          await manager.deleteDocument('test_collection', docRef.id);

      expect(result, isNull);

      final DocumentSnapshot<Map<String, dynamic>> deletedDoc =
          await fakeFirestore
              .collection('test_collection')
              .doc(docRef.id)
              .get();
      expect(deletedDoc.exists, false);
    });

    test('should return error when document does not exist', () async {
      final String? result =
          await manager.deleteDocument('test_collection', 'non_existent_id');

      const String expectedExceptionMessage =
          'Document does not exist in Firestore.';
      expect(result, Exception(expectedExceptionMessage).toString());
    });

    test('should handle FirebaseException and Exception', () async {
      const String collectionName = 'test_collection';
      const String docId = '1';
      await fakeFirestore.collection(collectionName).doc(docId).set(
        <String, dynamic>{'name': 'To Delete'},
      );
      final DocumentReference<Map<String, dynamic>> doc =
          fakeFirestore.collection(collectionName).doc(docId);

      const String exceptionMessage = 'Error deleting document';
      whenCalling(Invocation.method(#delete, null)).on(doc).thenThrow(
            FirebaseException(plugin: 'firestore', message: exceptionMessage),
          );

      final String? result =
          await manager.deleteDocument(collectionName, docId);

      expect(result, exceptionMessage);
    });
  });
}
