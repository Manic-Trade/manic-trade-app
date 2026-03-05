/// Represents a generic pair of two values.
class Pair<T, U> {
  Pair(this.left, this.right);

  final T left;
  final U right;

  @override
  String toString() => '($left, $right)';

  Pair copyWith({
    T? left,
    U? right,
  }) {
    return Pair(
      left ?? this.left,
      right ?? this.right,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pair &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          right == other.right;

  @override
  int get hashCode => left.hashCode ^ right.hashCode;
}
