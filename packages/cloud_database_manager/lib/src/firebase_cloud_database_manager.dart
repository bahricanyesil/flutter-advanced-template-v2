import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:log_manager/log_manager.dart';

import 'cloud_database_manager.dart';
import 'entities/where_condition.dart';
import 'utils/firestore_helpers.dart';
import 'utils/query_document_snapshot_extensions.dart';

/// A base class for managing Firestore operations.
@immutable
final class FirebaseCloudDatabaseManager implements CloudDatabaseManager {
  /// Creates a new instance of the [FirebaseCloudDatabaseManager].
  const FirebaseCloudDatabaseManager(
    this._firestore, {
    LogManager? logManager,
    this.rethrowExceptions = false,
  }) : _logManager = logManager;

  /// The [FirebaseFirestore] instance.
  final FirebaseFirestore _firestore;

  /// The [LogManager] instance.
  final LogManager? _logManager;

  /// Whether to rethrow exceptions.
  final bool rethrowExceptions;

  @override
  Future<(Map<String, dynamic>?, String?)> fetchDocumentById(
    String collection,
    String id,
  ) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection(collection).doc(id).get();
      final Map<String, dynamic>? data = doc.exists ? doc.dataWithId : null;
      _logManager
          ?.lDebug('Document fetched successfully from Firestore. $data');
      return (data, null);
    } on FirebaseException catch (e) {
      _logManager?.lError('Error fetching document: ${e.message ?? e.code}');
      if (rethrowExceptions) rethrow;
      return (null, e.message ?? e.code);
    } catch (e) {
      _logManager?.lError('Error fetching document: $e');
      if (rethrowExceptions) rethrow;
      return (null, e.toString());
    }
  }

  @override
  Future<(List<Map<String, dynamic>>?, String?)> fetchAllDocuments(
    String collection, {
    WhereCondition<Object>? condition,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);
      if (condition != null) {
        query = FirestoreHelpers.applyCondition<Object>(query, condition);
      }
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await query.get();
      final List<Map<String, dynamic>> documents = querySnapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.dataWithId,
          )
          .toList();
      _logManager
          ?.lDebug('Documents fetched successfully from Firestore. $documents');
      return (documents, null);
    } on FirebaseException catch (e) {
      _logManager
          ?.lError('Error fetching all documents: ${e.message ?? e.code}');
      if (rethrowExceptions) rethrow;
      return (null, e.message ?? e.code);
    } catch (e) {
      _logManager?.lError('Error fetching all documents: $e');
      if (rethrowExceptions) rethrow;
      return (null, e.toString());
    }
  }

  /// Fetches all documents from the specified collection as a stream.
  (Stream<QuerySnapshot<Map<String, dynamic>>>?, String?) streamDocs(
    String collection,
  ) {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshotStream =
          _firestore.collection(collection).snapshots();
      _logManager?.lDebug(
        'Documents stream fetched successfully from Firestore. $snapshotStream',
      );
      return (snapshotStream, null);
    } on FirebaseException catch (e) {
      _logManager?.lError(
        'Error fetching all documents stream: ${e.message ?? e.code}',
      );
      if (rethrowExceptions) rethrow;
      return (null, e.message ?? e.code);
    } catch (e) {
      _logManager?.lError('Error fetching all documents stream: $e');
      if (rethrowExceptions) rethrow;
      return (null, e.toString());
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> addDocument(
    String collection,
    Map<String, dynamic> newDoc, {
    String? docPath,
  }) async {
    try {
      final CollectionReference<Map<String, dynamic>> collectionRef =
          _firestore.collection(collection);
      final DocumentReference<Map<String, dynamic>> docRef =
          collectionRef.doc(docPath);
      await docRef.set(newDoc);
      final DocumentSnapshot<Map<String, dynamic>> doc = await docRef.get();
      final Map<String, dynamic>? dataMap = doc.exists ? doc.dataWithId : null;
      _logManager?.lDebug('Document added successfully to Firestore. $dataMap');
      return (dataMap, null);
    } on FirebaseException catch (e) {
      _logManager?.lError('Error adding document: ${e.message ?? e.code}');
      if (rethrowExceptions) rethrow;
      return (null, e.message ?? e.code);
    } catch (e) {
      _logManager?.lError('Error adding document: $e');
      if (rethrowExceptions) rethrow;
      return (null, e.toString());
    }
  }

  @override
  Future<String?> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final DocumentReference<Map<String, dynamic>> doc =
          _firestore.collection(collection).doc(id);
      await doc.update(updateData);
      _logManager
          ?.lDebug('Document updated successfully in Firestore. $updateData');
      return null;
    } on FirebaseException catch (e) {
      _logManager?.lError('Error updating document: ${e.message ?? e.code}');
      if (rethrowExceptions) rethrow;
      return e.message ?? e.code;
    } catch (e) {
      _logManager?.lError('Error updating document: $e');
      if (rethrowExceptions) rethrow;
      return e.toString();
    }
  }

  @override
  Future<String?> deleteDocument(String collection, String id) async {
    try {
      final DocumentReference<Map<String, dynamic>> doc =
          _firestore.collection(collection).doc(id);
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await doc.get();
      if (!docSnapshot.exists) {
        throw Exception('Document does not exist in Firestore.');
      }
      await doc.delete();
      return null;
    } on FirebaseException catch (e) {
      _logManager?.lError('Error deleting document: ${e.message ?? e.code}');
      if (rethrowExceptions) rethrow;
      return e.message ?? e.code;
    } catch (e) {
      _logManager?.lError('Error deleting document: $e');
      if (rethrowExceptions) rethrow;
      return e.toString();
    }
  }
}
