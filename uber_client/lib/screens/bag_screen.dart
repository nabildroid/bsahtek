import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/models/bag.dart';
import 'package:uber_client/repositories/orders_remote.dart';

import '../cubits/app_cubit.dart';
import '../repositories/server.dart';

class BagScreen extends StatefulWidget {
  final Bag bag;

  static go(BuildContext context, Bag bag) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return BagScreen(
          bag: bag,
        );
      },
    ));
  }

  const BagScreen({
    Key? key,
    required this.bag,
  }) : super(key: key);

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  int quantity = 1;
  bool goingToReserve = false;

  bool isPickup = false;

  void reserveNow() async {
    final appCubit = context.read<AppCubit>();
    final location = await context.read<BagsQubit>().getLocation();

    if (location == null) {
      return;
    }

    final newOrder = widget.bag.toOrder(
      appCubit.state.client!,
      quantity: quantity,
      isPickup: isPickup,
      location: location,
    );

    await appCubit.orderBag(newOrder);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (goingToReserve) {
          setState(() {
            goingToReserve = false;
          });
          return false;
        } else {
          return true;
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(widget.bag.sellerName),
            leading: AppBarButton(
              icon: Icons.arrow_back,
            ),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                widget.bag.photo,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: Hero(
                                    tag: "Bag-Seller-Photo${widget.bag.id}",
                                    child: CircleAvatar(
                                      radius: 26,
                                      backgroundImage:
                                          NetworkImage(widget.bag.sellerPhoto),
                                    ),
                                  ),
                                  title: Text(widget.bag.sellerName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          )),
                                ),
                              ),
                            )
                          ],
                        )),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          ListTile(
                            visualDensity: VisualDensity.compact,
                            leading: Icon(Icons.shopping_bag_outlined),
                            title: Text(widget.bag.name),
                            horizontalTitleGap: 0,
                            trailing: Column(
                              children: [
                                Text(
                                  "\$" + widget.bag.originalPrice.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  "\$" + widget.bag.price.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.star),
                            title: Text("4.6"),
                            horizontalTitleGap: 0,
                            visualDensity: VisualDensity.compact,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.green.shade700),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              goingToReserve = true;
                            });
                          },
                          child: Text("Order"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (goingToReserve)
                Positioned.fill(
                    child: Container(
                  color: Colors.black38,
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: .6,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.bag.sellerName + "\n" + widget.bag.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Divider(height: 32),
                          Text(
                            "Select Quanitity",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade900),
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: Center(
                              child: Row(
                                // create 2 icon button in cirlceAvarat and in center number of quantity
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: quantity < 2
                                        ? Colors.black12
                                        : Colors.green.shade700,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (quantity > 1) {
                                            quantity--;
                                          }
                                        });
                                      },
                                      icon: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "monospace",
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.green.shade700,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          quantity++;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // isPickup
                            ),
                          ),
                          ListTile(
                            title: Text("Pickup"),
                            trailing: Switch(
                              value: isPickup,
                              onChanged: (value) {
                                setState(() {
                                  isPickup = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: Text("Total"),
                            trailing: Text(
                              "\$" +
                                  (widget.bag.price * quantity)
                                      .toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green.shade700),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                  ),
                                  onPressed: reserveNow,
                                  child: Text("Reserve Now"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarButton extends StatelessWidget {
  final IconData icon;
  const AppBarButton({
    Key? key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        backgroundColor: Colors.white30,
        radius: 20,
        child: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(icon),
        ),
      ),
    );
  }
}
