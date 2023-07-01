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
}
