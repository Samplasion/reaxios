abstract class _BaseTuple {
  const _BaseTuple();

  int get length;

  bool operator ==(Object other);

  operator [](int i);
  int get hashCode;

  factory _BaseTuple.fromIterable(Iterable iterable) {
    throw "Unimplemented";
  }
}

class Tuple2<E0, E1> extends _BaseTuple {
  final E0 first;
  final E1 second;

  const Tuple2(this.first, this.second);

  int get length => 2;

  bool operator ==(Object other) {
    if (other is! Tuple2) return false;
    return first == other.first && second == other.second;
  }

  operator [](int i) {
    switch (i) {
      case 0:
        return first;
      case 1:
        return second;
      default:
        throw new RangeError.index(i, this, "index");
    }
  }

  int get hashCode => first.hashCode ^ second.hashCode;

  String toString() => "($first, $second)";

  factory Tuple2.fromIterable(Iterable iterable) {
    if (iterable.length != 2) {
      throw new ArgumentError("Iterable has wrong length: ${iterable.length}.");
    }
    return new Tuple2(iterable.first, iterable.last);
  }
}

class Tuple3<E0, E1, E2> extends _BaseTuple {
  final E0 first;
  final E1 second;
  final E2 third;

  const Tuple3(this.first, this.second, this.third);

  int get length => 3;

  bool operator ==(Object other) {
    if (other is! Tuple3) return false;
    return first == other.first &&
        second == other.second &&
        third == other.third;
  }

  operator [](int i) {
    switch (i) {
      case 0:
        return first;
      case 1:
        return second;
      case 2:
        return third;
      default:
        throw new RangeError.index(i, this, "index");
    }
  }

  int get hashCode => first.hashCode ^ second.hashCode ^ third.hashCode;

  String toString() => "($first, $second, $third)";

  factory Tuple3.fromIterable(Iterable iterable) {
    if (iterable.length != 3) {
      throw new ArgumentError("Iterable has wrong length: ${iterable.length}.");
    }
    return new Tuple3(iterable.first, iterable.elementAt(1), iterable.last);
  }
}

class Tuple4<E0, E1, E2, E3> extends _BaseTuple {
  final E0 first;
  final E1 second;
  final E2 third;
  final E3 fourth;

  const Tuple4(this.first, this.second, this.third, this.fourth);

  int get length => 4;

  bool operator ==(Object other) {
    if (other is! Tuple4) return false;
    return first == other.first &&
        second == other.second &&
        third == other.third &&
        fourth == other.fourth;
  }

  operator [](int i) {
    switch (i) {
      case 0:
        return first;
      case 1:
        return second;
      case 2:
        return third;
      case 3:
        return fourth;
      default:
        throw new RangeError.index(i, this, "index");
    }
  }

  int get hashCode =>
      first.hashCode ^ second.hashCode ^ third.hashCode ^ fourth.hashCode;

  String toString() => "($first, $second, $third, $fourth)";

  factory Tuple4.fromIterable(Iterable iterable) {
    if (iterable.length != 4) {
      throw new ArgumentError("Iterable has wrong length: ${iterable.length}.");
    }
    return new Tuple4(iterable.first, iterable.elementAt(1),
        iterable.elementAt(2), iterable.last);
  }
}
