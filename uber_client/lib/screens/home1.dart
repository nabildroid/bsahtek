import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/cubits/bags_cubit.dart';

import '../widgets/squaresmap.dart';

class Home1 extends StatefulWidget {
  const Home1({Key? key}) : super(key: key);

  @override
  State<Home1> createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  LatLng? position;

  late GoogleMapController mapController;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suprise Bags'),
      ),
      body: BlocBuilder<BagsQubit, BagsState>(builder: (context, state) {
        return SquaresMap(
          location: state.currentLocation,
          mapLoader: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
          onLocationChange: (location) {},
          onSpotVisible: (spot) {},
          onSquareVisible: (square) {
            context.read<BagsQubit>().visiteSquare(square);
          },
          spots: state.bags,
        );
      }),
    );
  }
}
