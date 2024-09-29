import 'dart:async';

import 'package:drift/drift.dart';
import 'package:log_manager/log_manager.dart';

/// A [QueryInterceptor] that logs all SQL queries and their results.
final class SqlLogInterceptor extends QueryInterceptor {
  /// Creates a new [SqlLogInterceptor].
  SqlLogInterceptor(this.logManager);

  /// The log manager.
  final LogManager logManager;

  Future<T> _run<T>(
    String description,
    FutureOr<T> Function() operation,
  ) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    logManager.lDebug('Running $description');

    try {
      final T result = await operation();
      logManager
          .lDebug(' => succeeded after ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } on Object catch (e) {
      logManager
          .lError(' => failed after ${stopwatch.elapsedMilliseconds}ms ($e)');
      rethrow;
    }
  }

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    logManager.lDebug('Starting transaction');
    return super.beginTransaction(parent);
  }

  @override
  Future<void> commitTransaction(TransactionExecutor inner) {
    return _run('Commit transaction', () => inner.send());
  }

  @override
  Future<void> rollbackTransaction(TransactionExecutor inner) {
    return _run('Rollback transaction', () => inner.rollback());
  }

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) {
    return _run(
      'Batch with $statements',
      () => executor.runBatched(statements),
    );
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runInsert(statement, args),
    );
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runUpdate(statement, args),
    );
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runDelete(statement, args),
    );
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runCustom(statement, args),
    );
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runSelect(statement, args),
    );
  }
}
