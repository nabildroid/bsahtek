import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bsahtak/cubits/bags_cubit.dart';
import 'package:bsahtak/cubits/home_cubit.dart';
import 'package:bsahtak/screens/bag_screen.dart';
import 'package:bsahtak/screens/location_selector.dart';

import '../repositories/notifications.dart';
import '../widgets/home/orderConfirmedZone.dart';
import '../widgets/home/inline_filters.dart';
import '../widgets/home/inline_suggestion.dart';
import '../widgets/shared/location_picker.dart';
import '../widgets/home/orderTrackZone.dart';
import '../widgets/home/squaresmap.dart';
import '../widgets/home/view_mode.dart';
import '../widgets/shared/suggestion_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static go() => MaterialPageRoute(builder: (context) => const HomeScreen());

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  LatLng? position;

  late GoogleMapController mapController;

  bool isMap = true;

  bool showFilters = false;

  bool showRunning = false;

  @override
  void initState() {
    context.read<HomeCubit>().init(); // not sure if this pattern is good
    context.read<BagsQubit>().init(context); // not sure if this pattern is good

    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HomeCubit>().recheckRunningOrder();
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<HomeCubit>().setContext(context);

    return Column(
      children: [
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.runningOrder?.isPickup == true) {
              return OrderConfirmedZone(
                address: state.runningOrder!.sellerAddress!,
                phone: state.runningOrder!.sellerPhone!,
              );
            } else if (state.runningOrder?.deliveryManID != null) {
              return OrderTrackZone(
                onFullView: () {
                  context.read<HomeCubit>().focusOnRunningOrder();
                },
              );
            }

            return SizedBox(height: MediaQuery.of(context).padding.top);
          },
        ),
        Expanded(
          child: Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: Stack(fit: StackFit.expand, children: [
              AnimatedSlide(
                offset: Offset(isMap ? 0 : 1, 0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: BlocBuilder<BagsQubit, BagsState>(
                    buildWhen: (previous, current) =>
                        previous.currentLocation == null &&
                        current.currentLocation != null,
                    builder: (context, state) {
                      if (state.currentLocation == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return SizedBox.expand(
                        child: SquaresMap(
                          filterBags: (bag) {
                            return true;
                          },
                        ),
                      );
                    }),
              ),
              AnimatedSlide(
                offset: Offset(isMap ? 1 : 0, 0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: BlocBuilder<BagsQubit, BagsState>(
                  builder: (context, state) {
                    return SizedBox.expand(
                      child: FractionallySizedBox(
                          alignment: Alignment.bottomCenter,
                          heightFactor: .65,
                          child: ListView.builder(
                            itemBuilder: (ctx, index) {
                              final spot = state.filtredBags[index];
                              return SuggestionCard(
                                id: spot.id,
                                title: spot.name,
                                subtitle: spot.sellerAddress,
                                chip: "Bag 1",
                                discountPrice: spot.originalPrice.toString(),
                                distance: (Geolocator.distanceBetween(
                                          spot.latitude,
                                          spot.longitude,
                                          state.currentLocation!.latitude,
                                          state.currentLocation!.longitude,
                                        ) /
                                        1000)
                                    .toStringAsFixed(2),
                                picture: spot.photo,
                                price: spot.price.toString(),
                                rating: spot.rating.toStringAsFixed(1),
                                storeName: spot.sellerName,
                                storePicture: spot.sellerPhoto,
                                onTap: () => BagScreen.go(context, spot),
                                onFavoriteTap: () =>
                                    context.read<HomeCubit>().toggleLiked(spot),
                              );
                            },
                            itemCount: state.filtredBags.length,
                          )),
                    );
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16),
                      LocationPicker(
                        onTap: () {
                          context.push("/home/location-picker");
                        },
                        bottomBar: ViewMode(
                          leftLabel: "List",
                          rightLabel: "Map",
                          leftSelected: !isMap,
                          onClick: (isLeft) => setState(() => isMap = !isLeft),
                        ),
                      ),
                      SizedBox(height: 8),
                      InlineFilters(),
                    ],
                  ),
                  AnimatedSlide(
                    curve: Curves.fastOutSlowIn,
                    duration: Duration(milliseconds: 400),
                    offset: Offset(0, isMap ? 0 : 1),
                    child: BlocBuilder<BagsQubit, BagsState>(
                      builder: (context, state) {
                        return InlineSuggestions(
                          onView: (index) {
                            final cubit = context.read<BagsQubit>();
                            if (cubit.state.filtredBags.isEmpty) return;
                            final spot = cubit.state.filtredBags[index];

                            cubit.moveCamera(CameraUpdate.newLatLng(LatLng(
                              spot.latitude,
                              spot.longitude,
                            )));
                          },
                          suggestions: [
                            ...state.filtredBags,
                          ]
                              .map(
                                (e) => InlineSuggestion(
                                  id: e.id.toString(),
                                  title: e.sellerName,
                                  subtitle: e.name,
                                  image: e.sellerPhoto,
                                  thirdtitle: e.description,
                                  quantity:
                                      state.quantities[e.id.toString()] ?? 0,
                                  onTap: () {
                                    BagScreen.go(context, e);
                                  },
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
