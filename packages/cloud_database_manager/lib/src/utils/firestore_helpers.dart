import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/where_condition.dart';

/// A helper class for Firestore operations.
abstract final class FirestoreHelpers {
  /// Applies the specified [condition] to the [query].
  static Query<Map<String, dynamic>> applyCondition<T>(
    Query<Map<String, dynamic>> query,
    WhereCondition<T> condition,
  ) {
    Query<Map<String, dynamic>> result = query;
    switch (condition.operator) {
      case '==':
        result = query.where(condition.field, isEqualTo: condition.value);
      case '>':
        result = query.where(condition.field, isGreaterThan: condition.value);
      case '<':
        result = query.where(condition.field, isLessThan: condition.value);
      case '>=':
        result = query.where(
          condition.field,
          isGreaterThanOrEqualTo: condition.value,
        );
      case '<=':
        result = query.where(
          condition.field,
          isLessThanOrEqualTo: condition.value,
        );
      case 'array-contains':
        result = query.where(condition.field, arrayContains: condition.value);
      default:
        throw UnsupportedError('Unsupported operator: ${condition.operator}');
    }
    return result;
  }
}
