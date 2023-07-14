abstract class Utils {
  static String? nullIsEmpty(String? txt) {
    if (txt == null || txt == "") return null;
    return txt;
  }
}
