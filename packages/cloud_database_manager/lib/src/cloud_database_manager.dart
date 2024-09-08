import 'entities/where_condition.dart';

/// Represents an interface for managing cloud database operations.
abstract interface class CloudDatabaseManager {
  /// Fetches a document from the specified collection by ID.
  Future<(Map<String, dynamic>?, String?)> fetchDocumentById(
    String collection,
    String id,
  );

  /// Fetches all documents from the specified collection.
  Future<(List<Map<String, dynamic>>?, String?)> fetchAllDocuments(
    String collection, {
    WhereCondition<Object>? condition,
  });

  /// Adds a document to the specified collection.
  Future<(Map<String, dynamic>?, String?)> addDocument(
    String collection,
    Map<String, dynamic> data, {
    String? docPath,
  });

  /// Updates a document in the specified collection by ID.
  Future<String?> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  );

  /// Deletes a document from the specified collection by ID.
  Future<String?> deleteDocument(String collection, String id);
}
