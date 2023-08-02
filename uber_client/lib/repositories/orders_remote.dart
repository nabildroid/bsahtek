// ignore: library_prefixes
import 'dart:convert';

import 'package:http/http.dart' as Http;

endpoint(String path) {
  return Uri.parse("https://wastnothin.vercel.app/api/$path");
}

class OrdersRemote {
  static void createOrder() async {
    await Http.post(endpoint("order"),
        body: jsonEncode({
          "id": "fzefzef",
          "client": "fzefzef",
          "bag": "fzefzef",
          "location": {"latitude": 0.0, "longitude": 0.0},
          "quantity": 0,
          "seller": "zefzefze"
        }),
        headers: {
          "Content-Type": "application/json",
        });
  }

  void getOrders() {}
}
