import 'dart:convert';

import 'package:uber_client/models/autosuggestion.dart';
import 'package:uber_client/models/bag.dart';

// ignore: library_prefixes
import 'package:http/http.dart' as Http;

endpoint(String path) {
  return Uri.parse("https://wastnothin.vercel.app/api/$path");
}

class BagRemote {
  Future<List<Bag>> getByCoordinations(int x, int y) async {
    final response = await Http.get(endpoint("map/$x,$y,30"));
    final data = jsonDecode(response.body)["foods"] as List<dynamic>;

    return data.map((e) => Bag.fromJson(e)).toList();
  }

  Future<List<Autosuggestion>> getAutosuggestions() async {
    return [];
  }

  Future<List<String>> getAllByWilaya(String wilaya) async {
    return [];
  }

  Future<List<Bag>> getHotByWilaya(String wilaya) async {
    final response = await Http.get(endpoint("map/hot/$wilaya"));
    final data = jsonDecode(response.body)["foods"] as List<dynamic>;

    return data.map((e) => Bag.fromJson(e)).toList();
  }
}
