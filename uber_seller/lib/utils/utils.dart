abstract class Utils {
  static List<T> removeDeplication<T>(
      List<T> list, dynamic Function(T item) getID) {
    final result = <T>[];

    for (var item in list) {
      if (!result.any((e) => getID(e) == getID(item))) {
        result.add(item);
      }
    }

    return result;
  }
}
