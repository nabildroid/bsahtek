import 'package:flutter/material.dart';

class OrderTrackZone extends StatelessWidget {
  final VoidCallback onFullView;
  const OrderTrackZone({
    Key? key,
    required this.onFullView,
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
              Icons.delivery_dining,
              color: Colors.greenAccent,
            ),
            textColor: Colors.white,
            title: Text("Your order is on the way"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: onFullView,
                    icon: Icon(
                      Icons.zoom_out_map_outlined,
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
