import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/cubits/app_cubit.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/models/bag.dart';
import 'package:uber_client/models/mapSquare.dart';
import 'package:uber_client/screens/bag_screen.dart';
import 'package:uber_client/screens/location_selector.dart';

import '../widgets/home/inline_filters.dart';
import '../widgets/home/inline_suggestion.dart';
import '../widgets/home/location_picker.dart';
import '../widgets/home/squaresmap.dart';
import '../widgets/home/view_mode.dart';
import '../widgets/shared/suggestion_card.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng? position;

  late GoogleMapController mapController;

  bool isMap = true;

  bool showFilters = false;

  @override
  void initState() {
    context.read<AppCubit>().init();
    context.read<BagsQubit>().init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Stack(fit: StackFit.expand, children: [
          AnimatedSlide(
            offset: Offset(isMap ? 0 : 1, 0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: BlocBuilder<BagsQubit, BagsState>(builder: (context, state) {
              return SizedBox.expand(
                child: SquaresMap(
                  filterBags: (bag) {
                    return true;
                  },
                  mapLoader: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
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
                          final spot = state.visibleBags[index];
                          return SuggestionCard(
                            title: spot.name,
                            subtitle: "Bag 1",
                            chip: "Bag 1",
                            discountPrice: spot.originalPrice.toString(),
                            distance: MapSquare.calculateDistance(
                              LatLng(spot.latitude, spot.longitude),
                              state.currentLocation!,
                            ).toStringAsFixed(2),
                            picture: spot.photo,
                            price: spot.price.toString(),
                            rating: "4.5",
                            storeName: spot.sellerName,
                            storePicture: spot.sellerPhoto,
                            onTap: () {},
                          );
                        },
                        itemCount: state.visibleBags.length,
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
                  LocationPicker(
                    onTap: () {
                      LocationSelector.go(context);
                    },
                    subtitle: "within 20 km",
                    title: "Alger",
                  ),
                  SizedBox(height: 8),
                  ViewMode(
                    leftLabel: "List",
                    rightLabel: "Map",
                    leftSelected: !isMap,
                    onClick: (isLeft) => setState(() => isMap = !isLeft),
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
                        final spot = state.visibleBags[index];
                        context
                            .read<BagsQubit>()
                            .moveCamera(CameraUpdate.newLatLng(LatLng(
                              spot.latitude,
                              spot.longitude,
                            )));
                      },
                      suggestions: [
                        ...state.visibleBags,
                      ]
                          .map(
                            (e) => InlineSuggestion(
                              id: e.id.toString(),
                              title: e.sellerName,
                              subtitle: e.name,
                              image: e.sellerPhoto,
                              thirdtitle: e.description,
                              quantity: 2,
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
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Colors.green,
          onTap: (index) {},
        ),
      ),
    );
  }
}
