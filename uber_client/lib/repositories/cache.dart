import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/client.dart';
import '../models/order.dart';

class Cache {
  static late SharedPreferences _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
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
}
