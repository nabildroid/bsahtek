import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';

import '../models/order.dart';
import '../repository/server.dart';

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
        title: Text(
          'Order Delivered',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(Server.auth.currentUser!.photoURL!),
          ),
          SizedBox(width: 8),
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
                  leading: Icon(
                    Icons.price_check_outlined,
                    color: Colors.blueGrey.shade900,
                  ),
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
                  leading: Icon(
                    Icons.map,
                    color: Colors.blueGrey.shade500,
                  ),
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
                  leading: Icon(
                    Icons.store,
                    color: Colors.blueGrey.shade900,
                  ),
                  title: Text(order.sellerName),
                  subtitle: Text("Store Name"),
                  trailing: IconButton(
                    onPressed: () {
                      AndroidIntent(
                        action: 'action_view',
                        data: 'tel:${order.sellerPhone}',
                      ).launch();
                    },
                    icon: Icon(
                      Icons.call,
                      color: Colors.green.shade500,
                    ),
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
