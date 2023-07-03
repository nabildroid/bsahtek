import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/models/bag.dart';

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
  List<Bag> visibleSpotsInMap = [];

  bool showFilters = false;

  @override
  void initState() {
    context.read<BagsQubit>().init();

    super.initState();
  }

  void initMap(GoogleMapController controller) {
    mapController = controller;
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
                  location: state.currentLocation,
                  mapLoader: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  onLocationChange: (location) {},
                  onSpotsVisible: (spots) {
                    setState(() => visibleSpotsInMap = spots);
                  },
                  onSquareVisible: (square) {
                    context.read<BagsQubit>().visiteSquare(square);
                  },
                  spots: state.bags,
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
                          final spot = visibleSpotsInMap[index];
                          return SuggestionCard(
                            title: spot.name,
                            subtitle: "Bag 1",
                            chip: "Bag 1",
                            discountPrice: "12.00",
                            distance: "15",
                            picture:
                                "https://images.unsplash.com/photo-1687220297381-f8fddaa09163?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=870&q=80",
                            price: "15.00",
                            rating: "4.5",
                            storeName: spot.sellerName,
                            storePicture: "https://arib.shop/logo1.png",
                            onTap: () {},
                          );
                        },
                        itemCount: visibleSpotsInMap.length,
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
                    onTap: () {},
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
                      onView: (elm) {},
                      suggestions: [
                        ...visibleSpotsInMap,
                      ]
                          .map(
                            (e) => InlineSuggestion(
                              id: e.idd,
                              title: e.sellerName,
                              subtitle: e.name,
                              image: "https://arib.shop/logo1.png",
                              thirdtitle: "Nothin gt sace tovade",
                              quantity: 2,
                              onTap: () {},
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
