import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderConfirmedZone extends StatelessWidget {
  final String phone;
  final LatLng address;

  const OrderConfirmedZone({
    Key? key,
    required this.phone,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueGrey.shade900,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: TweenAnimationBuilder(
          duration: Duration(milliseconds: 500),
          tween: Tween<double>(begin: -1, end: 0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(value, 0),
              child: child,
            );
          },
          child: ListTile(
            leading: Icon(
              Icons.check,
              color: Colors.greenAccent,
            ),
            textColor: Colors.white,
            title: Text("Order Confirmed"),
            subtitle: Text("go pick it up"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      AndroidIntent(
                        action: 'action_view',
                        data: 'tel:$phone',
                      ).launch();
                    },
                    icon: Icon(
                      Icons.phone,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      AndroidIntent(
                        action: 'action_view',
                        data: 'geo:${address.latitude},${address.longitude}',
                      ).launch();
                    },
                    icon: Icon(
                      Icons.location_searching_outlined,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
