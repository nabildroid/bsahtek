import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/bag.dart';
import '../model/order.dart';
import '../model/seller.dart';
import '../model/zone.dart';

class Cache {
  static late SharedPreferences _instance;
  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
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
    // get running orders then add the new one and save it and remove duplicates
    final runningOrdersJson = _instance.getStringList('runningOrders') ?? [];
    // remove duplicates
    runningOrdersJson.removeWhere(
        (element) => Order.fromJson(jsonDecode(element)).id == order.id);
    runningOrdersJson.add(jsonEncode(order.toJson()));

    await _instance.setStringList('runningOrders', runningOrdersJson);
  }

  static Future<void> popRunningOrder(String id) async {
    // get running orders then add the new one and save it
    final runningOrdersJson = _instance.getStringList('runningOrders') ?? [];
    runningOrdersJson
        .removeWhere((element) => Order.fromJson(jsonDecode(element)).id == id);
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
      return DateTime(2001);
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

  static addZone(Zone zone) async {
    // add make json out of zone and add it to the list of zone and avoid duplicates
    final zonesJson = _instance.getStringList('zones') ?? [];
    // remove duplicates
    zonesJson.removeWhere((e) => Zone.fromJson(jsonDecode(e)).id == zone.id);

    zonesJson.add(jsonEncode(zone.toJson()));

    await _instance.setStringList('zones', zonesJson);
  }

  static List<Zone> get zones {
    final zonesJson = _instance.getStringList('zones') ?? [];
    return zonesJson.map((e) => Zone.fromJson(jsonDecode(e))).toList();
  }

  static Bag? get bag {
    // saved as json
    final bagJson = _instance.getString('bag');
    if (bagJson == null) {
      return null;
    }
    return Bag.fromJson(jsonDecode(bagJson));
  }

  static set bag(Bag? bag) {
    if (bag == null) {
      _instance.remove('bag');
    } else {
      _instance.setString('bag', jsonEncode(bag.toJson()));
    }
  }
}
