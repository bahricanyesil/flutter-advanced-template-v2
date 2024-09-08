import 'package:flutter/foundation.dart';

import '../enums/where_operator.dart';

/// A class to represent a where condition.
@immutable
final class WhereCondition<T> {
  /// Creates a new [WhereCondition].
  const WhereCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  /// Field to apply the condition.
  final String field;

  /// Operator to apply.
  final WhereOperator operator;

  /// Value to compare.
  final T value;
}
