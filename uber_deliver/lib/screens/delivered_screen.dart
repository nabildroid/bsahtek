import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';

import '../models/order.dart';

class DeliveredScreen extends StatelessWidget {
  static go(Order order) => MaterialPageRoute(
        builder: (context) => DeliveredScreen(order: order),
      );

  final Order order;

  const DeliveredScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Delivered'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text('#${order.id}'),
              subtitle: Text('Order ID'),
            ),
            ListTile(
              title: Text(order.lastUpdate.toLocal().toString()),
              subtitle: Text('Date'),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.price_check_outlined),
                  title: Text('15\$'),
                  subtitle: Text('Price for delivery'),
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.map),
                  title: Text('15 km'),
                  subtitle: Text('Distance'),
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.store),
                  title: Text(order.sellerName),
                  subtitle: Text("Store Name"),
                  trailing: IconButton(
                    onPressed: () {
                      AndroidIntent(
                        action: 'action_view',
                        data: 'tel:${order.sellerPhone}',
                      ).launch();
                    },
                    icon: Icon(Icons.call),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
