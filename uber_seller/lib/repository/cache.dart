import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/order.dart';
import '../model/seller.dart';

class Cache {
  static late SharedPreferences _instance;
  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
    _instance.clear();
  }

  static bool get isFirstRun {
    final isIt = _instance.getBool("isFirstRun") ?? true;
    _instance.setBool("isFirstRun", false);

    return isIt;
  }

  static Seller? get seller {
    // saved as json
    final userJson = _instance.getString('user');
    if (userJson == null) {
      return null;
    }
    return Seller.fromJson(jsonDecode(userJson));
  }

  static set seller(Seller? user) {
    if (user == null) {
      _instance.remove('user');
    } else {
      _instance.setString('user', jsonEncode(user.toJson()));
    }
  }

  static Future<void> pushRunningOrder(Order order) async {
    // get running orders then add the new one and save it
    final runningOrdersJson = _instance.getStringList('runningOrders') ?? [];
    runningOrdersJson.add(jsonEncode(order.toJson()));
    await _instance.setStringList('runningOrders', runningOrdersJson);
  }

  static Future<void> recache() async {
    await _instance.reload();
  }

  static Future<void> clear() async {
    await _instance.clear();
  }

  static List<Order> get runningOrders {
    final runningOrdersJson = _instance.getStringList('runningOrders') ?? [];
    return runningOrdersJson.map((e) => Order.fromJson(jsonDecode(e))).toList();
  }

  static List<Order> get prevOrders {
    final prevOrdersJson = _instance.getStringList('prevOrders') ?? [];
    return prevOrdersJson.map((e) => Order.fromJson(jsonDecode(e))).toList();
  }

  static DateTime get lastUpdatedPrevOrders {
    final olders = prevOrders;
    if (olders.isEmpty) {
      return DateTime.now();
    }
    final t = olders
        .map((e) => e.lastUpdate)
        .reduce((value, element) => value.isAfter(element) ? value : element);

    return t;
  }

  static Future<void> updatePrevOrder(Order order) async {
    final olders = prevOrders;
    final index = olders.indexWhere((element) => element.id == order.id);
    if (index == -1) {
      olders.add(order);
    } else {
      olders[index] = order;
    }
    await _instance.setStringList(
        'prevOrders', olders.map((e) => jsonEncode(e.toJson())).toList());
  }

  static Map<String, int> get quantities {
    final quantitiesJson = _instance.getStringList('quantities') ?? [];
    return {};
    return quantitiesJson
        .map((e) => jsonDecode(e) as Map<String, int>)
        .reduce((value, element) {
      value.addAll(element);
      return value;
    });
  }

  static set quantities(Map<String, int> quantities) {
    _instance.setStringList(
        'quantities',
        quantities
            .map((key, value) => MapEntry(key, jsonEncode(value)))
            .values
            .toList());
  }
}
