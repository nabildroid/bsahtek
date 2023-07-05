import 'package:flutter/material.dart';
import 'package:uber_client/repositories/orders_remote.dart';

class BagScreen extends StatelessWidget {
  static go(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return const BagScreen();
      },
    ));
  }

  const BagScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          OrdersRemote.createOrder();
        },
        label: Text("Order"),
      ),
    );
  }
}
