import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/client.dart';

class Cache {
  static late SharedPreferences _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static bool get isFirstRun {
    return true;
    final isit = _instance.getBool("isFirstRun") ?? true;
    _instance.setBool("isFirstRun", false);

    return isit;
  }

  static Client? get currentClient {
    final data = _instance.getString("currentClient");
    if (data == null) {
      return null;
    }
    return Client.fromJson(jsonDecode(data));
  }

  static set currentClient(Client? client) {
    if (client == null) {
      _instance.remove("currentClient");
    } else {
      _instance.setString("currentClient", jsonEncode(client.toJson()));
    }
  }

  static bool get isLogin {
    final data = _instance.getBool("isLogin");
    if (data == null) {
      return false;
    }
    return data;
  }

  static set isLogin(bool? isLogin) {
    if (isLogin == null) {
      _instance.remove("isLogin");
    } else {
      _instance.setBool("isLogin", isLogin);
    }
  }

  static void clear() async {
    await _instance.clear();
  }
}
