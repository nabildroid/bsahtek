import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Utils {
  static String? nullIsEmpty(String? txt) {
    if (txt == null || txt == "") return null;
    return txt;
  }

  static Map<String, dynamic> goodFirestoreJson(Map<String, dynamic> json) {
    return json.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, goodFirestoreJson(value));
      } else if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      } else {
        return MapEntry(key, value);
      }
    });
  }
}
