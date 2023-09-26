import 'package:flutter/material.dart';

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

  static String splitTranslation(String text, BuildContext context) {
    List<String> parts = text.split(RegExp('---+'));
    parts.removeWhere((element) => element.trim().isEmpty);

    if (parts.length == 1) return parts[0];

    final isArabic = Directionality.of(context) == TextDirection.rtl;

    RegExp arabicRegExp = RegExp(r'[\u0600-\u06FF]');
    List<String> arabicParts = [];
    List<String> otherParts = [];
    for (String part in parts) {
      if (arabicRegExp.hasMatch(part)) {
        arabicParts.add(part);
      } else {
        otherParts.add(part);
      }
    }

    if (isArabic && arabicParts.isNotEmpty)
      return arabicParts[0];
    else if (otherParts.isNotEmpty)
      return otherParts[0];
    else
      return text;
  }
}
