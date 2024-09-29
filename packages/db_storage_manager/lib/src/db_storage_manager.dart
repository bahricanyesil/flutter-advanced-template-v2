/// An abstract class that defines the interface for a database storage manager.
///
/// This class provides methods to manage the lifecycle of a database
/// connection, including opening and closing the connection,
/// and deleting all data from the database.
///
/// The generic type parameter [T] represents
/// the type of the database connection.
abstract class DbStorageManager<T> {
  /// Opens a connection to the database.
  ///
  /// This method should be called before any database operations are performed.
  /// It initializes the connection to the database.
  Future<void> openConnection();

  /// Closes the connection to the database.
  ///
  /// This method should be called when the database is no longer needed.
  /// It ensures that all resources associated with
  /// the database connection are released.
  Future<void> closeConnection();

  /// Deletes all data from the database.
  ///
  /// This method should be used with caution as
  /// it will remove all data from the database.
  Future<void> deleteEverything();

  /// Gets the current database connection.
  ///
  /// This property provides access to the underlying database connection.
  /// The type of the connection is specified by the generic type parameter [T].
  T get connection;
}
