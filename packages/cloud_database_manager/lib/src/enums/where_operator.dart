/// Enum representing the different operators that
/// can be used in a where condition.
enum WhereOperator {
  /// Equal to operator.
  isEqualTo('=='),

  /// Greater than operator.
  isGreaterThan('>'),

  /// Less than operator.
  isLessThan('<'),

  /// Greater than or equal to operator.
  isGreaterThanOrEqualTo('>='),

  /// Less than or equal to operator.
  isLessThanOrEqualTo('<='),

  /// Array contains operator.
  arrayContains('array-contains'),

  /// Array contains any operator.
  arrayContainsAny('array-contains-any');

  const WhereOperator(this.value);

  /// The string representation of the operator.
  final String value;
}
