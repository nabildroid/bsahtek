import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:store/cubits/app_cubit.dart';
import 'package:store/screens/running_order.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/home_cubit.dart';
import '../model/order.dart';
import '../utils/life_cycle.dart';
import '../widgets/skelaton.dart';

class HomeScreen extends StatefulWidget {
  static go() => MaterialPageRoute(builder: (context) => HomeScreen());

  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  bool isExpanded = false;

  @override
  void initState() {
    context.read<HomeCubit>().init();
    WidgetsBinding.instance.addObserver(this);

    _scrollController.addListener(() => setState(
          () => isExpanded = _scrollController.offset > 10,
        ));

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    if (appLifecycleState == AppLifecycleState.resumed) {}
    super.didChangeAppLifecycleState(appLifecycleState);
  }

  @override
  Widget build(BuildContext context) {
    context.read<HomeCubit>().setContext(context);
    final app = context.read<AppCubit>();

    return SafeArea(
        child: Scaffold(
      body: Skelaton(
          isExpanded: isExpanded,
          top: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) => AnimatedSwitcher(
                          duration: Duration(seconds: 1),
                          key: ValueKey(state.quantity),
                          child: RichText(
                            text: TextSpan(
                              text: state.quantity.toString(),
                              style: TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: ' bags',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white.withOpacity(.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "Available Bags for Clients",
                          style: TextStyle(
                            color: Colors.white.withOpacity(.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      image: DecorationImage(
                        image: NetworkImage(app.state.seller!.photo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionButton(
                      label: "Add",
                      icon: Icons.add_shopping_cart_rounded,
                      onTap: context.read<HomeCubit>().addQuantity),
                  ActionButton(
                    label: "Subtract",
                    icon: Icons.remove_circle_outline_sharp,
                    onTap: () =>
                        context.read<HomeCubit>().removeQuantity(false),
                  ),
                  SizedBox(width: 5),
                  ActionButton(
                    label: "Pause",
                    icon: Icons.remove_shopping_cart_outlined,
                    onTap: () => context.read<HomeCubit>().removeQuantity(true),
                  ),
                ],
              )
            ],
          ),
          bottom: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
            final sortedOrders = state.prevOrders.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Basket",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: 12),
                  BagPreview(),
                  SizedBox(height: 16),
                  Text(
                    "Orders",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: 12),
                  ...sortedOrders.map((e) => OrderTile(order: e)).toList(),
                  SizedBox(height: 100),
                ],
              ),
            );
          })),
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
}

class BagPreview extends StatelessWidget {
  const BagPreview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 11,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              blurRadius: 18,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
            final bag = state.bags.isEmpty ? null : state.bags.first;
            if (bag == null) return Container();

            return Column(
              children: [
                Expanded(
                    flex: 10,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.white.withOpacity(0.2), BlendMode.color),
                            child: Image.network(
                              bag.photo,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.favorite_border,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                                Row(children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(bag.photo),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      bag.sellerName,
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  )
                                ])
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
                Expanded(
                  flex: 8,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bag.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            bag.sellerAddress,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${bag.originalPrice}dz",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.green.shade800,
                              ),
                              Text(
                                bag.rating.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Divider(
                                color: Colors.black,
                                endIndent: 4,
                                indent: 4,
                                thickness: 4,
                              ),
                              Text(
                                "0 km",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "${bag.price}dz",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        ]),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final Order order;
  const OrderTile({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    Widget trailing = Text(
      "+ ${order.bagPrice}dz",
      style:
          TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
    );

    IconData icon = Icons.playlist_add_check_circle_outlined;

    if (order.isDelivered != true) {
      final isRunning = order.inProgress;

      final isWaiting = order.inProgress;

      if (isWaiting) {
        trailing = Icon(
          Icons.play_circle_outline_outlined,
          color: Colors.green,
        );
      } else if (isRunning) {
        trailing = Icon(
          Icons.pending_actions,
          color: Colors.yellow.shade800,
        );
      } else {
        trailing = Icon(
          Icons.timer_off_outlined,
          color: Colors.red.shade800,
        );
      }
    }

    if (order.isPickup) {
      icon = Icons.handshake;
    } else {
      icon = Icons.delivery_dining;
    }

    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => RunningOrder(
                    order: order,
                    index: 1,
                  )),
        );
      },
      leading: Icon(
        icon,
      ),
      title: Text(order.clientName),
      subtitle: Text(
        "#${order.id}",
      ),
      trailing: trailing,
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
    );
  }
}
