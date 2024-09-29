/// An abstract interface for interacting with a database.
///
/// This interface defines methods for initializing the database, inserting
/// records, retrieving all records, updating records, deleting records,
/// querying records, and deleting all records.
///
/// The type parameter `T` represents the model type that will be stored
/// in the database.
abstract class DbDao<T> {
  /// Inserts a record into the database.
  ///
  /// [model] - The model object to be inserted.
  Future<void> insertRecord(T model);

  /// Retrieves a record from the database.
  ///
  /// [id] - The id of the record to be retrieved.
  Future<T?> getRecord(String id);

  /// Retrieves all records from the database.
  Future<List<T>> getAllRecords();

  /// Updates a record in the database.
  ///
  /// [model] - The updated model object.
  Future<void> updateRecord(T model);

  /// Deletes a record from the database.
  ///
  /// [id] - The id of the record to be deleted.
  Future<bool> deleteRecord(String id);

  /// Deletes all records from the database.
  Future<void> deleteAllRecords();
}
