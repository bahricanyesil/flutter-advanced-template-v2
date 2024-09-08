import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/where_condition.dart';
import '../enums/where_operator.dart';

/// A helper class for Firestore operations.
abstract final class FirestoreHelpers {
  /// Applies the specified [condition] to the [query].
  static Query<Map<String, dynamic>> applyCondition<T>(
    Query<Map<String, dynamic>> query,
    WhereCondition<T> condition,
  ) =>
      switch (condition.operator) {
        WhereOperator.isEqualTo =>
          query.where(condition.field, isEqualTo: condition.value),
        WhereOperator.isGreaterThan =>
          query.where(condition.field, isGreaterThan: condition.value),
        WhereOperator.isLessThan =>
          query.where(condition.field, isLessThan: condition.value),
        WhereOperator.isGreaterThanOrEqualTo =>
          query.where(condition.field, isGreaterThanOrEqualTo: condition.value),
        WhereOperator.isLessThanOrEqualTo =>
          query.where(condition.field, isLessThanOrEqualTo: condition.value),
        WhereOperator.arrayContains =>
          query.where(condition.field, arrayContains: condition.value),
        WhereOperator.arrayContainsAny => query.where(
            condition.field,
            arrayContainsAny: condition.value as Iterable<Object?>,
          ),
      };
}
