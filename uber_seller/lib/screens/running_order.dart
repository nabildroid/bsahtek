import 'dart:convert';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_seller/cubits/app_cubit.dart';

import '../model/order.dart';

class RunningOrder extends StatefulWidget {
  final Order order;
  final int index;

  final void Function()? onAccept;
  final void Function()? onReport;

  RunningOrder({
    Key? key,
    required this.order,
    required this.index,
    this.onAccept,
    this.onReport,
  }) : super(key: key);

  @override
  State<RunningOrder> createState() => _RunningOrderState();
}

class _RunningOrderState extends State<RunningOrder> {
  bool goingToExit = false;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 10000), () {
      setState(() {
        goingToExit = true;
      });
    }).then((value) => Future.delayed(Duration(seconds: 1), () async {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        }));

    super.initState();
  }

  void handleAccept() async {
    if (widget.onAccept != null) {
      widget.onAccept!();
      setState(() => goingToExit = true);
      Future.delayed(Duration(milliseconds: 500)).then((value) {
        Navigator.of(context).pop();
      });
    } else {
      AndroidIntent intent = AndroidIntent(
        componentName: "me.laknabil.uber_seller.MainActivity",
        package: 'me.laknabil.uber_seller',
        // data: jsonEncode(widget.order.toJson()),
      );

      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      await intent.launch();
    }
  }

  void handleReport() {
    if (widget.onReport != null) {
      widget.onReport!();
    } else {}
  }

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
                      Navigator.of(context).pop();
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
                    widget.order.clientTown,
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
                        label: const Text(
                          'Accept Order',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
