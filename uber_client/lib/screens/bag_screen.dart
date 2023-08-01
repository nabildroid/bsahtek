import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/cubits/home_cubit.dart';
import 'package:uber_client/models/bag.dart';
import 'package:uber_client/repositories/orders_remote.dart';

import '../cubits/app_cubit.dart';
import '../repositories/gps.dart';
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

  final _controller = ScrollController();

  double photoHeight = 0;
  double ratio = 0;

  bool isLoading = false;
  bool isReserved = false;

  void reserveNow() async {
    setState(() => isLoading = true);
    final homeCubit = context.read<HomeCubit>();
    final appCubit = context.read<AppCubit>();
    final location = await GpsRepository.getLocation();

    if (location == null) {
      setState(() => isLoading = false);
      return;
    }

    String name = appCubit.state.client!.name;
    if (["", "user"].contains(name)) {
      final newName = await homeCubit.showEnterYourNameDialog();
      if (newName == null || ["", "user"].contains(newName)) {
        setState(() => isLoading = false);
        return;
      }

      appCubit.updateClient(
        appCubit.state.client!.copyWith(name: newName),
      );
      name = newName;
    }

    final newOrder = widget.bag.toOrder(
      appCubit.state.client!.copyWith(name: name),
      quantity: quantity,
      isPickup: isPickup,
      location: location,
    );

    await homeCubit.orderBag(newOrder);
    setState(() => {isLoading = false, isReserved = true});
    Future.delayed(Duration(seconds: 3), () {
      setState(() => goingToReserve = false);
      context.go("/me");
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (photoHeight == 0) return;
      setState(() {
        ratio = min(_controller.offset, photoHeight) / photoHeight;
        ratio = Curves.easeInOutExpo.transform(ratio);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final throttled = context
            .read<HomeCubit>()
            .state
            .throttlingReservation
            ?.isAfter(DateTime.now()) ??
        false;

    final isLiked = context.watch<HomeCubit>().isLiked(widget.bag.id);

    final bagsCubit = context.watch<BagsQubit>();
    final maxQuantity =
        bagsCubit.state.quantities[widget.bag.id.toString()] ?? 0;

    // todo use gps instead of currentLocation, and move it in the reserve handler
    final distance = Geolocator.distanceBetween(
          widget.bag.latitude,
          widget.bag.longitude,
          bagsCubit.state.currentLocation!.latitude,
          bagsCubit.state.currentLocation!.longitude,
        ) /
        1000;

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
            backgroundColor: Colors.white.withOpacity(ratio),
            centerTitle: true,
            foregroundColor: Colors.black.withOpacity(ratio),
            title: Text(
              widget.bag.sellerName,
            ),
            leading: AppBarButton(
              icon: Icons.arrow_back,
              onPressed: Navigator.of(context).pop,
            ),
            actions: [
              AppBarButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                onPressed: () {
                  context.read<HomeCubit>().toggleLiked(widget.bag);
                },
              ),
              SizedBox(width: 8),
            ],
          ),
          // todo delete this line!
          //regerg erger
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _controller,
                child: Column(
                  children: [
                    AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned.fill(
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                if (photoHeight == 0) {
                                  photoHeight = constraints.maxHeight;
                                }
                                return ColoredBox(
                                  color: Colors.grey.shade500,
                                  child: Image.network(
                                    widget.bag.photo,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Opacity(
                                  opacity: 1 - ratio,
                                  child: ListTile(
                                    leading: Hero(
                                      tag: "Bag-Seller-Photo${widget.bag.id}",
                                      child: CircleAvatar(
                                        radius: 26,
                                        backgroundImage: NetworkImage(
                                          widget.bag.sellerPhoto,
                                        ),
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
                              ),
                            )
                          ],
                        )),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            visualDensity: VisualDensity.compact,
                            leading: Icon(Icons.shopping_bag_outlined),
                            title: Text(widget.bag.name),
                            horizontalTitleGap: 0,
                            trailing: Column(
                              children: [
                                Text(
                                  widget.bag.originalPrice.toString() + "dz",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  widget.bag.price.toString() + "dz",
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
                            title: Text(widget.bag.rating.toStringAsFixed(1)),
                            horizontalTitleGap: 0,
                            visualDensity: VisualDensity.compact,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 20),
                            child: Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(widget.bag.description),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (context.watch<HomeCubit>().state.runningOrder == null)
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
                              if (maxQuantity == 0) return;
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
                                    backgroundColor: quantity >= maxQuantity
                                        ? Colors.black12
                                        : Colors.green.shade700,
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (quantity < maxQuantity)
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
                              (widget.bag.price * quantity).toStringAsFixed(2) +
                                  "dz",
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
                                    backgroundColor: distance > 50
                                        ? MaterialStateProperty.all(
                                            Colors.grey.shade600)
                                        : MaterialStateProperty.all(
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
                                  onPressed: distance > 50 ||
                                          throttled ||
                                          isLoading ||
                                          isReserved
                                      ? () {}
                                      : reserveNow,
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    child: isLoading ||
                                            (throttled && !isReserved)
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : isReserved
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              )
                                            : distance > 50
                                                ? Text("Too Far")
                                                : Text(
                                                    "Reserve Now",
                                                    key:
                                                        ValueKey("Reserve Now"),
                                                  ),
                                  ),
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
  final VoidCallback onPressed;
  const AppBarButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        backgroundColor: Colors.white38,
        radius: 20,
        child: IconButton(
          color: Colors.black,
          onPressed: () {
            onPressed();
          },
          icon: Icon(icon),
        ),
      ),
    );
  }
}
