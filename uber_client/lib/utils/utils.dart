import '../models/bag.dart';

abstract class Utils {
  static List<List<Bag>> groupSpots(
      List<Bag> points, bool Function(Bag, Bag) areClose) {
    List<List<Bag>> result = [];

    for (var point in points) {
      bool grouped = false;

      for (var group in result) {
        if (group.any((p) => p != point && areClose(p, point))) {
          group.add(point);
          grouped = true;
          break;
        }
      }

      if (!grouped) {
        result.add([point]);
      }
    }

    return result;
  }

  static bool compare<T>(List<T> a, List<T> b, bool Function(T, T) compare) {
    // check the length then each item individually, order is not important
    if (a.length != b.length) return true;

    // Check if all elements in a are in b
    for (var item in a) {
      if (!b.any((e) => compare(e, item))) return true;
    }

    // Check if all elements in b are in a
    for (var item in b) {
      if (!a.any((e) => compare(e, item))) return true;
    }

    return false;
  }
}
