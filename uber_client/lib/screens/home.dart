import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/cubits/bags_cubit.dart';
import 'package:uber_client/models/mapSquare.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng? position;

  late GoogleMapController mapController;

  Map<String, MapSquare> squares = {};

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
    return BlocListener<BagsQubit, BagsState>(
      listener: (context, state) {
        if (state.currentLocation == null) return;
      },
      child: BlocBuilder<BagsQubit, BagsState>(
        bloc: BlocProvider.of<BagsQubit>(context),
        builder: (ctx, state) {
          squares.values.forEach((element) {
            if (element.isWithin(state.currentLocation!)) {
              final a = element.toPoints();
              print(a);
            }
          });
          return state.currentLocation == null
              ? const SizedBox()
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: state.currentLocation!,
                    zoom: 14.4746,
                  ),
                  zoomControlsEnabled: false,
                  polygons: Set()
                    ..addAll(
                      squares.values.map(
                        (square) => Polygon(
                          polygonId: PolygonId(square.id),
                          fillColor: state.currentLocation == null
                              ? Colors.teal
                              : square.isWithin(state.currentLocation!)
                                  ? Colors.red.withOpacity(.5)
                                  : Colors.green.withOpacity(.5),
                          strokeColor: Colors.green.shade800,
                          zIndex: 1,
                          strokeWidth: 2,
                          points: square.toPoints(),
                        ),
                      ),
                    ),
                  circles: Set()
                    ..addAll(state.bags.map(
                      (e) => Circle(
                        circleId: CircleId(e.id.toString()),
                        center: LatLng(e.latitude, e.longitude),
                        radius: 500,
                        strokeWidth: 0,
                        zIndex: 2555555555,
                        fillColor: Colors.green.shade800,
                      ),
                    ))
                    ..addAll(squares.values.map(
                      (square) => Circle(
                          circleId: CircleId(square.id),
                          center: LatLng(
                            square.toOffset().dy,
                            square.toOffset().dx,
                          ),
                          radius: 500,
                          strokeColor: Colors.black,
                          fillColor: state.currentLocation == null
                              ? Colors.teal
                              : square.isWithin(state.currentLocation!)
                                  ? Colors.red
                                  : Colors.black,
                          strokeWidth: 1,
                          zIndex: 3),
                    ))
                    ..add(Circle(
                        circleId: CircleId("Centerrr"),
                        center: state.currentLocation!,
                        radius: 500,
                        strokeColor: Colors.black,
                        fillColor: Colors.white.withOpacity(.5),
                        strokeWidth: 1,
                        zIndex: 555)),
                  onCameraMove: (position) {
                    // print(position.zoom);

                    final a = 156543.03392 *
                        cos(position.target.latitude * pi / 180) /
                        pow(2, position.zoom);

                    // print(position.target);
                    print(a);
                    print(position.zoom);
                    print("------------ ");
                  },
                  onMapCreated: initMap,
                );
        },
      ),
    );
  }
}
