import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bsahtak/utils/constants.dart';

import '../cubits/bags_cubit.dart';
import '../models/bag.dart';
import '../models/client.dart';
import '../models/order.dart';

class Cache {
  static late SharedPreferences _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
    // await _instance.clear();
  }

  static Future<bool> isFirstRun() async {
    final isit = _instance.getBool("isFirstRun") ?? true;
    await _instance.setBool("isFirstRun", false);

    return isit;
  }

  static Locale? get appLocale {
    final lng = _instance.getString("appLocal");
    if (lng != null) {
      return Locale(lng);
    }
    return null;
  }

  static set appLocale(Locale? locale) {
    if (locale == null) {
      _instance.remove("appLocal");
    } else {
      _instance.setString("appLocal", locale.languageCode);
    }
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

  static Future<void> clear() async {
    await _instance.clear();
  }

  // currentArea
  static Area? get currentArea {
    final data = _instance.getString("currentArea");
    if (data == null) {
      return Constants.defaultArea;
    }
    return Area.fromMap(jsonDecode(data));
  }

  static set currentArea(Area? area) {
    if (area == null) {
      _instance.remove("currentArea");
    } else {
      _instance.setString("currentArea", jsonEncode(area.toMap()));
    }
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

  static Future<void> setPrevOrders(List<Order> bags) async {
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
  static DateTime get lastUpdatePrevOrders {
    final orders = prevOrders;
    if (orders.isEmpty) {
      return DateTime(2001);
    }
    // sort by lastUpdate and get the first one
    orders.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));
    return orders.first.lastUpdate;
  }

  static DateTime? get throttlingReservation {
    final data = _instance.getString("throttlingReservation");
    if (data == null) {
      return null;
    }
    return DateTime.parse(data);
  }

  static set throttlingReservation(DateTime? date) {
    if (date == null) {
      _instance.remove("throttlingReservation");
    } else {
      _instance.setString("throttlingReservation", date.toIso8601String());
    }
  }
}
