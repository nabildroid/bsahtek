import 'package:flutter/material.dart';

class OrderConfirmedZone extends StatelessWidget {
  final String phone;
  final String address;

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
                    onPressed: () {},
                    icon: Icon(
                      Icons.phone,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {},
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
