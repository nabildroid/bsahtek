import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/order.dart';
import '../model/seller.dart';

class Cache {
  final SharedPreferences _sharedPreferences;
  Cache(this._sharedPreferences);

  bool get isFirstRun {
    return true;
    final isit = _sharedPreferences.getBool('isFirstRun') ?? false;
    if (!isit) {
      _sharedPreferences.setBool('isFirstRun', true);
    }
    return isit;
  }

  Seller? get user {
    // saved as json
    final userJson = _sharedPreferences.getString('user');
    if (userJson == null) {
      return null;
    }
    return Seller.fromJson(jsonDecode(userJson));
  }

  set user(Seller? user) {
    if (user == null) {
      _sharedPreferences.remove('user');
    } else {
      _sharedPreferences.setString('user', jsonEncode(user.toJson()));
    }
  }

  Future<void> pushRunningOrder(Order order) async {
    // get running orders then add the new one and save it
    final runningOrdersJson =
        _sharedPreferences.getStringList('runningOrders') ?? [];
    runningOrdersJson.add(jsonEncode(order.toJson()));
    await _sharedPreferences.setStringList('runningOrders', runningOrdersJson);
  }

  Future<void> recache() async {
    await _sharedPreferences.reload();
  }

  Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  List<Order> get runningOrders {
    final runningOrdersJson =
        _sharedPreferences.getStringList('runningOrders') ?? [];
    return runningOrdersJson.map((e) => Order.fromJson(jsonDecode(e))).toList();
  }

  List<Order> get prevOrders {
    final prevOrdersJson = _sharedPreferences.getStringList('prevOrders') ?? [];
    return prevOrdersJson.map((e) => Order.fromJson(jsonDecode(e))).toList();
  }

  DateTime get lastUpdatedPrevOrders {
    final olders = prevOrders;
    if (olders.isEmpty) {
      return DateTime.now();
    }
    final t = olders
        .map((e) => e.lastUpdate)
        .reduce((value, element) => value.isAfter(element) ? value : element);

    return t;
  }

  Future<void> updatePrevOrder(Order order) async {
    final olders = prevOrders;
    final index = olders.indexWhere((element) => element.id == order.id);
    if (index == -1) {
      olders.add(order);
    } else {
      olders[index] = order;
    }
    await _sharedPreferences.setStringList(
        'prevOrders', olders.map((e) => jsonEncode(e.toJson())).toList());
  }

  Map<String, int> get quantities {
    final quantitiesJson = _sharedPreferences.getStringList('quantities') ?? [];
    return {};
    return quantitiesJson
        .map((e) => jsonDecode(e) as Map<String, int>)
        .reduce((value, element) {
      value.addAll(element);
      return value;
    });
  }

  set quantities(Map<String, int> quantities) {
    _sharedPreferences.setStringList(
        'quantities',
        quantities
            .map((key, value) => MapEntry(key, jsonEncode(value)))
            .values
            .toList());
  }
}
