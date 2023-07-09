import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreUtils {
  static Map<String, dynamic> goodJson(Map<String, dynamic> json) {
    return json.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, goodJson(value));
      } else if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      } else {
        return MapEntry(key, value);
      }
    });
  }
}
