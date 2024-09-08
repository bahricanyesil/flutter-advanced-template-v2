import 'package:cloud_database_manager/cloud_database_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseCloudDatabaseManager manager;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    manager = FirebaseCloudDatabaseManager(fakeFirestore);
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
  });

  group('fetchAllDocuments', () {
    test('should return all documents without condition', () async {
      await fakeFirestore
          .collection('test_collection')
          .add(<String, dynamic>{'name': 'Test 1'});
      await fakeFirestore
          .collection('test_collection')
          .add(<String, dynamic>{'name': 'Test 2'});

      final (List<Map<String, dynamic>>?, String?) result =
          await manager.fetchAllDocuments('test_collection');

      expect(result.$1?.length, 2);
      expect(result.$1?[0]['name'], 'Test 1');
      expect(result.$1?[0]['id'], isNotNull);
      expect(result.$1?[1]['name'], 'Test 2');
      expect(result.$1?[1]['id'], isNotNull);
      expect(result.$2, isNull);
    });
  });

  group('streamDocs', () {
    test('should return stream of QuerySnapshot', () {
      final (Stream<QuerySnapshot<Map<String, dynamic>>>?, String?) result =
          manager.streamDocs('test_collection');

      expect(result.$1, isA<Stream<QuerySnapshot<Map<String, dynamic>>>>());
      expect(result.$2, isNull);
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

      final Exception expectedException =
          Exception('Document does not exist in Firestore.');
      expect(result, expectedException.toString());
    });
  });
}
