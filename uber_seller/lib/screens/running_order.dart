import 'dart:convert';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_seller/cubits/home_cubit.dart';
import 'package:uber_seller/repository/server.dart';

import '../model/order.dart';

class RunningOrder extends StatefulWidget {
  final Order order;
  final int index;

  final bool isPickup;

  static go(
    BuildContext context, {
    required Order order,
    required int index,
    bool isPickup = false,
  }) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<HomeCubit>(),
            child: RunningOrder(
              order: order,
              index: index,
              isPickup: isPickup,
            ),
          ),
        ),
      );

  RunningOrder({
    Key? key,
    required this.order,
    required this.index,
    this.isPickup = false,
  }) : super(key: key);

  @override
  State<RunningOrder> createState() => _RunningOrderState();
}

class _RunningOrderState extends State<RunningOrder> {
  bool goingToExit = false;

  String clientTown = "";

  @override
  void initState() {
    Server().getCityName(widget.order.clientAddress).then((value) {
      if (mounted) setState(() => clientTown = value);
    });

    // Future.delayed(Duration(seconds: 10000), () {
    //   setState(() {
    //     goingToExit = true;
    //   });
    // }).then((value) => Future.delayed(Duration(seconds: 1), () async {
    //       if (Navigator.of(context).canPop()) {
    //         Navigator.of(context).pop();
    //       } else {
    //         await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    //       }
    //     }));

    super.initState();
  }

  bool get isOld =>
      widget.order.isDelivered == true ||
      DateTime.now().difference(widget.order.createdAt).inMinutes > 10;

  bool get isWaiting =>
      widget.order.isDelivered == null && widget.order.acceptedAt != null;

  bool get isWaitingAndGoodToHandover =>
      isWaiting && (widget.isPickup || widget.order.deliveryManID != null);

  void handleAccept() async {
    if (widget.isPickup == false && !isWaiting) {
      context.read<HomeCubit>().acceptOrder(widget.order);
      setState(() => goingToExit = true);
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        Navigator.of(context).pop();
      });
    } else {
      context.read<HomeCubit>().handOver(widget.order);
      setState(() => goingToExit = true);
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        Navigator.of(context).pop();
      });
    }
  }

  void handleReport() {}

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height - 1 * 60;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOutExpo,
          color: Colors.white,
          height: goingToExit ? height * .5 : height,
          padding: const EdgeInsets.all(16),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 16),
                  // dashed bottom border only
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Order #${widget.order.id}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(widget.order.bagImage),
                  ),
                  title: Text(widget.order.clientName),
                  subtitle: Text(widget.order.clientPhone),
                  trailing: IconButton(
                    onPressed: () {
                      // open the phone app at the client phone number
                      AndroidIntent intent = AndroidIntent(
                        action: 'action_view',
                        data: 'tel:${widget.order.clientPhone}',
                      );
                      intent.launch();
                    },
                    icon: const Icon(
                      Icons.phone,
                      color: Colors.green,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),

                // show the client location
                ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                  title: Text(
                    clientTown,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),

                // show the client location
                ListTile(
                  leading: const Icon(
                    Icons.production_quantity_limits,
                    color: Colors.green,
                  ),
                  subtitle: Text("quanitity"),
                  title: Text(
                    widget.order.quantity.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontFamily: "monospace"),
                  ),
                ),

                // report abusing

                Spacer(),

                if (widget.order.isDelivered == true) ...[
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    leading: const Icon(
                      Icons.shopping_basket_outlined,
                      color: Colors.green,
                    ),
                    title: Text(
                      widget.order.createdAt.toString(),
                    ),
                    subtitle: Text(
                      'Ordered at',
                    ),
                  ),
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    leading: const Icon(
                      Icons.thumb_up_alt_outlined,
                      color: Colors.green,
                    ),
                    title: Text(
                      widget.order.acceptedAt.toString(),
                    ),
                    subtitle: Text(
                      'Accepted At',
                    ),
                  ),
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    leading: const Icon(
                      Icons.done_all_outlined,
                      color: Colors.green,
                    ),
                    title: Text(
                      widget.order.lastUpdate.toString(),
                    ),
                    subtitle: Text(
                      'Finished  At',
                    ),
                  ),
                ],

                if (isOld && widget.order.isDelivered != true) ...[
                  // show something that indicates that the order is expired before get accepted
                  Text(
                    'Expired',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],

                if (isOld == false &&
                    (!isWaiting || isWaitingAndGoodToHandover)) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            iconColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.all(16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          onPressed: handleAccept,
                          icon: const Icon(
                            Icons.move_down_outlined,
                          ),
                          label: Text(
                            isWaiting ? 'Hand Over' : 'Accept Order',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                      iconColor: Colors.white,
                    ),
                    onPressed: handleReport,
                    icon: const Icon(
                      Icons.report,
                    ),
                    label: const Text(
                      'Report Abusing',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
