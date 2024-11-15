import 'package:bsahtak/models/order.dart';
import 'package:bsahtak/repositories/phone_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:bsahtak/widgets/home/inline_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:bsahtak/cubits/bags_cubit.dart';
import 'package:bsahtak/cubits/home_cubit.dart';
import 'package:bsahtak/models/bag.dart';

import '../cubits/app_cubit.dart';
import '../models/clientSubmit.dart';
import '../repositories/gps.dart';
import '../repositories/server.dart';
import '../utils/utils.dart';
import '../widgets/home/order_bag/activate_account.dart';
import '../widgets/home/order_bag/reserve.dart';

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

  static replace(BuildContext context, Bag bag) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
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

// todo refactor this to cubit
class _BagScreenState extends State<BagScreen> {
  bool isOrderActionOnView =
      false; // used to animate the order button after sometime

  bool goingToReserve = false;
  int quantity = 1;
  bool isPickup = true;
  bool isLoading = false;
  bool isReserved = false;

  ConfirmationResult? ConfirmOTP;

  bool goingToActivateAccount = false;
  ClientSubmit? pendingSubmition;

  final _controller = ScrollController();
  double photoHeight = 0;
  double ratio = 0;

  Future<void> confirmOTP(String otp) async {
    if (pendingSubmition == null) return;

    final newAuthCredential = await PhoneAuth.confirm(otp);

    if (newAuthCredential == null || newAuthCredential.token == null) {
      throw Error();
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Server.auth.currentUser!.linkWithCredential(newAuthCredential);
    } catch (e) {}

    final appCubit = context.read<AppCubit>();
    final homeCubit = context.read<HomeCubit>();

    await Server().submitClient(
      appCubit.state.client!.id,
      pendingSubmition!,
    );

    homeCubit.addNotActiveOrder(pendingSubmition!.requestedOrder);

    setState(() {
      isLoading = false;
      isReserved = true;
      goingToActivateAccount = false;
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() => goingToReserve = false);
      context.go("/me");
    });
  }

  void activateAccount(String name, String phone, String address) async {
    setState(() {
      isLoading = true;
    });

    // send request to api
    final appCubit = context.read<AppCubit>();
    final location = await GpsRepository.getLocation(context);
    // validate inputs

    final newOrder = widget.bag.toOrder(
      appCubit.state.client!.copyWith(name: name).copyWith(
            phone: phone,
          ),
      quantity: quantity,
      isPickup: isPickup,
      location: location!, // todo this is unsafe
    );

    await PhoneAuth.auth("+213" + phone);

    setState(() {
      isLoading = false;
      pendingSubmition = ClientSubmit(
        name: name,
        phone: phone,
        address: address,
        requestedOrder: newOrder,
      );
    });
  }

  void reserveNow() async {
    setState(() => isLoading = true);
    final location = await GpsRepository.getLocation(context);

    final homeCubit = context.read<HomeCubit>();
    final appCubit = context.read<AppCubit>();

    if (location == null) {
      setState(() => isLoading = false);
      // todo add alert to inform user that he should enable gps
      return;
    }

    if (appCubit.state.client == null ||
        appCubit.state.client!.isActive == false) {
      setState(() {
        goingToActivateAccount = true;
        isLoading = false;
      });

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

    try {
      await homeCubit.orderBag(newOrder);

      setState(() => {isLoading = false, isReserved = true});
      Future.delayed(Duration(seconds: 3), () {
        setState(() => goingToReserve = false);
        context.go("/me");
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
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

    Future.delayed(Duration(seconds: 1)).then((_) {
      if (!mounted) return;
      setState(() => isOrderActionOnView = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final throttled = false;

    final isLiked = context.watch<HomeCubit>().isLiked(widget.bag.id);

    final bagsCubit = context.watch<BagsQubit>();
    final maxQuantity =
        min(bagsCubit.state.quantities[widget.bag.id.toString()] ?? 0, 9);

    // todo use gps instead of currentLocation, and move it in the reserve handler
    final distance = Geolocator.distanceBetween(
          widget.bag.latitude,
          widget.bag.longitude,
          bagsCubit.state.currentLocation!.latitude,
          bagsCubit.state.currentLocation!.longitude,
        ) /
        1000;

    var relatedBags = [...bagsCubit.state.filtredBags];
    relatedBags.sort((a, b) {
      if (a.tags.contains(widget.bag.tags) &&
          !b.tags.contains(widget.bag.tags)) {
        return 1;
      } else if (!a.tags.contains(widget.bag.tags) &&
          b.tags.contains(widget.bag.tags)) {
        return -1;
      } else {
        return Geolocator.distanceBetween(widget.bag.latitude,
                    widget.bag.longitude, a.latitude, a.longitude) >
                Geolocator.distanceBetween(widget.bag.latitude,
                    widget.bag.longitude, b.latitude, b.longitude)
            ? 1
            : -1;
      }
    });

    relatedBags = relatedBags.sublist(0, min(relatedBags.length, 7));

    return WillPopScope(
      onWillPop: () async {
        if (goingToActivateAccount) {
          setState(() {
            pendingSubmition = null;
            goingToActivateAccount = false;
            isLoading = false;
          });
          return false;
        }
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
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .tertiary
                                            .withOpacity(.2),
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
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.shopping_bag_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            Utils.splitTranslation(
                                                widget.bag.name, context),
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            widget.bag.rating
                                                .toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.bag.originalPrice.toString() +
                                        AppLocalizations.of(context)!
                                            .bag_price_unit,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: "monospace",
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    widget.bag.price.toString() +
                                        AppLocalizations.of(context)!
                                            .bag_price_unit,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            title: Text(Utils.splitTranslation(
                                widget.bag.sellerAddress, context)),
                            subtitle: Text(AppLocalizations.of(context)!
                                .bag_seller_location),
                            trailing: Icon(Icons.chevron_right),
                            onTap: () {
                              AndroidIntent(
                                action: 'action_view',
                                data:
                                    'geo:0,0?q=${widget.bag.latitude},${widget.bag.longitude}',
                              ).launch();
                            },
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 20)
                                .copyWith(),
                            child: Text(
                              AppLocalizations.of(context)!.bag_description,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(Utils.splitTranslation(
                                widget.bag.description, context)),
                          ),
                          if (maxQuantity < 1) ...[
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 20)
                                  .copyWith(),
                              child: Text(
                                AppLocalizations.of(context)!.bag_related,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InlineSuggestions(suggestions: [
                              ...relatedBags.map(
                                (e) => InlineSuggestion(
                                  id: e.id.toString(),
                                  title: e.sellerName,
                                  subtitle: e.name,
                                  image: e.sellerPhoto,
                                  thirdtitle: e.description,
                                  quantity: 100,
                                  onTap: () {
                                    BagScreen.replace(context, e);
                                  },
                                ),
                              )
                            ], onView: (_) => {}),
                          ],
                          SizedBox(height: photoHeight * .6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (context.watch<HomeCubit>().state.runningOrder == null)
                Opacity(
                  opacity: isOrderActionOnView ? 1 : 0,
                  child: AnimatedSlide(
                    duration: Duration(milliseconds: 350),
                    offset: Offset(0, isOrderActionOnView ? 0 : 2),
                    curve: Curves.easeInOutExpo,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration:
                            BoxDecoration(color: Colors.white, boxShadow: [
                          BoxShadow(
                            offset: Offset(0, -2),
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 2,
                          )
                        ]),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              maxQuantity > 0
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .secondary),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                    ),
                                    onPressed: () {
                                      if (maxQuantity == 0) {
                                        _controller.animateTo(100000,
                                            duration:
                                                Duration(milliseconds: 350),
                                            curve: Curves.easeInOutExpo);
                                        return;
                                      }
                                      setState(() {
                                        goingToReserve = true;
                                      });
                                    },
                                    child: Text(maxQuantity > 0
                                        ? AppLocalizations.of(context)!
                                            .bag_order_order
                                        : AppLocalizations.of(context)!
                                            .bag_order_nothing),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (goingToReserve || goingToActivateAccount)
                ReserveContainer(
                  child: goingToActivateAccount
                      ? ActivateAccount(
                          confirmOTP: confirmOTP,
                          isOtpScreen: pendingSubmition != null,
                          sendOTP: activateAccount,
                          isLoading: isLoading,
                        )
                      : Reserve(
                          bag: widget.bag,
                          loading: isLoading || throttled,
                          distance: distance,
                          quantity: quantity,
                          done: isReserved,
                          maxQuantity: maxQuantity,
                          reserve: distance > 50 ||
                                  throttled ||
                                  isLoading ||
                                  isReserved
                              ? () {}
                              : reserveNow,
                          setQuantity: (q) => setState(() {
                            quantity = q;
                          }),
                        ),
                  secondStage: goingToActivateAccount,
                )
            ],
          ),
        ),
      ),
    );
  }
}

class ReserveContainer extends StatelessWidget {
  final Widget child;
  final bool secondStage;
  const ReserveContainer({
    super.key,
    required this.child,
    required this.secondStage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: Container(
            color: Colors.black38,
            alignment: Alignment.bottomCenter,
            child: AnimatedFractionallySizedBox(
                duration: Duration(milliseconds: 450),
                curve: Curves.easeInOutExpo,
                heightFactor: secondStage ? 0.8 : .6,
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: child))));
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
