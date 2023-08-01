import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_deliver/cubits/app_cubit.dart';
import 'package:uber_deliver/cubits/service_cubit.dart';
import 'package:uber_deliver/repository/direction.dart';
import 'package:uber_deliver/screens/delivered_screen.dart';
import 'package:uber_deliver/screens/login.dart';
import 'package:uber_deliver/screens/running.dart';
import 'package:uber_deliver/screens/runningNoti.dart';

import '../models/order.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static go() => MaterialPageRoute(builder: (ctx) => HomeScreen());

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceCubit>().init(); // not sure if this pattern is good
  }

  @override
  Widget build(BuildContext context) {
    context.read<ServiceCubit>().setContext(context);

    final service = context.read<ServiceCubit>();
    final app = context.read<AppCubit>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "Hello, " + app.state.deliveryMan!.name,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                app.state.deliveryMan!.photo,
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<ServiceCubit, ServiceState>(
                    buildWhen: (_, __) => true,
                    builder: (context, state) {
                      return Card(
                        isLoading: state.loadingAvailability ||
                            state.runningRequest != null,
                        id: app.state.deliveryMan!.id.substring(0, 5),
                        isAvailable: state.isAvailable,
                        onSwitch: service.toggleAvailability,
                      );
                    }),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Past Deliveries",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                BlocBuilder<ServiceCubit, ServiceState>(
                  builder: (context, state) => Column(
                    children: state.deliveredOrders
                        .map(
                          (e) => Delivered(order: e),
                        )
                        .toList(),
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<ServiceCubit, ServiceState>(
          builder: (ctx, state) {
            if (state.runningRequest != null) {
              return FloatingActionButton(
                heroTag: "running",
                onPressed: () => ctx.read<ServiceCubit>().focusOnRunning(),
                child: Icon(Icons.delivery_dining),
              );
            }

            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class Delivered extends StatefulWidget {
  final Order order;
  const Delivered({
    super.key,
    required this.order,
  });

  @override
  State<Delivered> createState() => _DeliveredState();
}

class _DeliveredState extends State<Delivered> {
  bool isLoading = true;

  double totalDistance = 0;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    final directions = await Future.wait([
      DirectionRepository.direction(
          widget.order.sellerAddress, widget.order.clientAddress),
      DirectionRepository.direction(
          widget.order.deliveryAddress!, widget.order.sellerAddress),
    ]);

    setState(() {
      totalDistance = directions[0].distance + directions[1].distance;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: Duration(milliseconds: 350),
      curve: Curves.easeInOutExpo,
      offset: Offset(isLoading ? -1 : 0, 0),
      child: ListTile(
        onTap: () =>
            Navigator.of(context).push(DeliveredScreen.go(widget.order)),
        leading: Icon(
          Icons.delivery_dining,
          color: Colors.green,
        ),
        title: Text(widget.order.sellerName),
        subtitle: Text("#${widget.order.id.substring(0, 5)}"),
        trailing: RichText(
          text: TextSpan(
            text: "${(totalDistance / 1000).toStringAsFixed(2)}km ",
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

class Card extends StatelessWidget {
  final String id;
  final bool isAvailable;
  final VoidCallback onSwitch;
  final bool isLoading;
  const Card({
    required this.id,
    required this.isAvailable,
    required this.onSwitch,
    super.key,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Hero(
          tag: "availability",
          child: Material(
            color: Colors.transparent,
            child: AnimatedScale(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOutExpo,
              scale: isLoading ? 0.9 : 1,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: isLoading ? 0.8 : 1,
                curve: Curves.easeInOutExpo,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // use gradient instead
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.shade900,
                        Colors.blueGrey.shade500,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomCenter,
                    ),
                    // color: Colors.blueGrey.shade900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "DILDEAL",
                          children: [
                            TextSpan(
                              text: "#$id",
                              style: TextStyle(
                                color: Colors.blueGrey.shade300,
                              ),
                            )
                          ],
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "monospace",
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: Duration(seconds: 1),
                              child: isAvailable
                                  ? Text(
                                      "Available for Delivery orders from Stores/Shops to Customers",
                                      softWrap: true,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ))
                                  : Text(
                                      "You are not available for delivery orders, so you won't receive any orders",
                                      softWrap: true,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IgnorePointer(
                            ignoring: isLoading,
                            child: Switch(
                                value: isAvailable,
                                onChanged: (_) {
                                  onSwitch();
                                }),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
