// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:db_storage_manager/db_storage_manager.dart';
import 'package:db_storage_manager/src/interceptors/sql_log_interceptor.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:log_manager/log_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// An interface for interacting with a database using the Drift library.
typedef ExecutorDbInterface = DbStorageManager<QueryExecutor>;

/// A singleton class that manages the database connection and
/// provides functionality to interact with it.
final class DriftDbManager implements ExecutorDbInterface {
  /// Creates a new instance of this class.
  DriftDbManager({this.logQueryInterceptor, this.logManager});

  /// Logs the queries executed by the database.
  final QueryInterceptor? logQueryInterceptor;

  /// The log manager to use for logging.
  final LogManager? logManager;
  late final DatabaseConnection _connection;

  @override
  Future<void> openConnection() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(p.join(dbFolder.path, 'app.db.sqlite'));
    late QueryExecutor executor;

    if (!file.existsSync()) {
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      final String cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;

      executor = NativeDatabase.createInBackground(file);
    } else {
      executor = NativeDatabase(file);
    }

    if (logQueryInterceptor != null || logManager != null) {
      executor = executor
          .interceptWith(logQueryInterceptor ?? SqlLogInterceptor(logManager!));
    }
    _connection = DatabaseConnection(executor);
  }

  @override
  Future<void> closeConnection() async {
    await _connection.executor.close();
  }

  @override
  Future<void> deleteEverything() async {
    await _connection.executor
        .runCustom('DELETE FROM sqlite_master WHERE type = "table";');
  }

  @override
  DatabaseConnection get connection => _connection;
}
