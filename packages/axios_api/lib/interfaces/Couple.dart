/// Represents a 2-tuple, or pair.
class Couple<T1, T2> {
  /// Returns the first item of the tuple
  final T1 item1;

  /// Returns the second item of the tuple
  final T2 item2;

  /// Creates a new tuple value with the specified items.
  const Couple(this.item1, this.item2);

  /// Create a new tuple value with the specified list [items].
  factory Couple.fromList(List items) {
    if (items.length < 2) {
      throw ArgumentError('items must have length 2');
    }

    return Couple<T1, T2>(items[0] as T1, items[1] as T2);
  }

  /// Returns a tuple with the first item set to the specified value.
  Couple<T1, T2> withItem1(T1 v) => Couple<T1, T2>(v, item2);

  /// Returns a tuple with the second item set to the specified value.
  Couple<T1, T2> withItem2(T2 v) => Couple<T1, T2>(item1, v);

  /// Creates a [List] containing the items of this [Couple].
  ///
  /// The elements are in item order. The list is variable-length
  /// if [growable] is true.
  List toList({bool growable = false}) =>
      List.from([item1, item2], growable: growable);

  @override
  String toString() => '[$item1, $item2]';

  @override
  bool operator ==(Object other) =>
      other is Couple && other.item1 == item1 && other.item2 == item2;

  @override
  int get hashCode => item1.hashCode ^ item2.hashCode;
}
