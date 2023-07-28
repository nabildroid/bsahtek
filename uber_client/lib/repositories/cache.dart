import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bag.dart';
import '../models/client.dart';
import '../models/order.dart';

class Cache {
  static late SharedPreferences _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
    // await _instance.clear();
  }

  static bool get isFirstRun {
    final isit = _instance.getBool("isFirstRun") ?? true;
    _instance.setBool("isFirstRun", false);

    return isit;
  }

  static Client? get client {
    final data = _instance.getString("currentClient");
    if (data == null) {
      return null;
    }
    return Client.fromJson(jsonDecode(data));
  }

  static set client(Client? client) {
    if (client == null) {
      _instance.remove("currentClient");
    } else {
      _instance.setString("currentClient", jsonEncode(client.toJson()));
    }
  }

  static void clear() async {
    await _instance.clear();
  }

  static Order? get runningOrder {
    final data = _instance.getString("runningOrder");
    if (data == null) {
      return null;
    }
    return Order.fromJson(jsonDecode(data));
  }

  static set runningOrder(Order? order) {
    if (order == null) {
      _instance.remove("runningOrder");
    } else {
      _instance.setString("runningOrder", jsonEncode(order.toJson()));
    }
  }

  // liked bags setter and getter
  static List<Bag> get likedBags {
    final data = _instance.getStringList("likedBags");
    if (data == null) {
      return [];
    }
    return data.map((e) => Bag.fromJson(jsonDecode(e))).toList();
  }

  static set likedBags(List<Bag> bags) {
    if (bags.isEmpty) {
      _instance.remove("likedBags");
    } else {
      _instance.setStringList(
        "likedBags",
        bags.map((e) => jsonEncode(e.toJson())).toList(),
      );
    }
  }

  static List<Order> get prevOrders {
    final data = _instance.getStringList("prevOrders");
    if (data == null) {
      return [];
    }
    return data.map((e) => Order.fromJson(jsonDecode(e))).toList();
  }

  static set prevOrders(List<Order> bags) {
    if (bags.isEmpty) {
      _instance.remove("prevOrders");
    } else {
      _instance.setStringList(
        "prevOrders",
        bags.map((e) => jsonEncode(e.toJson())).toList(),
      );
    }
  }

  // get the newest order lastUpdate using prevOrders
  static DateTime get lastUpdate {
    final orders = prevOrders;
    if (orders.isEmpty) {
      return DateTime(2001);
    }
    // sort by lastUpdate and get the first one
    orders.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));
    return orders.first.lastUpdate;
  }
}
