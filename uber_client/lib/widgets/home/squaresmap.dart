import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/cubits/bags_cubit.dart';

import '../../models/bag.dart';
import '../../models/mapSquare.dart';
import '../../utils/mapMark.dart';
import '../../utils/utils.dart';

class MinimunMarker {
  final String id;
  final LatLng position;
  final BitmapDescriptor icon;

  MinimunMarker({
    required this.id,
    required this.position,
    required this.icon,
  });
}

class SquaresMap extends StatefulWidget {
  final Widget Function(BuildContext context) mapLoader;
  final bool Function(Bag) filterBags;

  const SquaresMap({
    Key? key,
    required this.mapLoader,
    required this.filterBags,
  }) : super(key: key);

  @override
  State<SquaresMap> createState() => _SquaresMapState();
}

class _SquaresMapState extends State<SquaresMap> {
  late GoogleMapController mapController;

  CameraPosition? lastCameraPosition;

  Set<MinimunMarker> markers = {};

  LatLng scaleRatio = const LatLng(1, 1);

  void initMap(GoogleMapController controller) {
    mapController = controller;
    context.read<BagsQubit>().attachCameraEvent((p0) {
      mapController.animateCamera(p0);
    });
  }

  // need to be here
  updateMapScaleRatio(LatLngBounds bounds) {
    scaleRatio = LatLng(
      bounds.northeast.latitude - bounds.southwest.latitude,
      bounds.northeast.longitude - bounds.southwest.longitude,
    );
  }

  // need to be here
  onCameraStopMoving(CameraPosition position, BagsQubit bagsQubit) async {
    final bounds = await mapController.getVisibleRegion();
    await bagsQubit.updateMapVisibilty(position.target, bounds);

    updateMapScaleRatio(bounds);
  }

  // convert spots to marks and group Marks if needed
  convertSpotsToMarks(BuildContext context) async {
    final visibleSpots = context.read<BagsQubit>().state.visibleBags;

    final citizens = Utils.groupSpots(visibleSpots, (a, b) {
      final latDiff = (a.latitude - b.latitude).abs();
      final lonDiff = (a.longitude - b.longitude).abs();

      final latRatio = latDiff / scaleRatio.latitude;
      final lonRatio = lonDiff / scaleRatio.longitude;

      if (latRatio < 0.04 && lonRatio < 0.05) return true;
      return false;
    });

    final Set<MinimunMarker> tempMarkers = {};

    for (var citizen in citizens) {
      if (citizen.length == 1) {
        tempMarkers.add(MinimunMarker(
            id: citizen.first.name,
            position: LatLng(
              citizen.first.latitude,
              citizen.first.longitude,
            ), //position of marker
            icon: BitmapDescriptor.defaultMarker));
      } else {
        final centerPos = MapSquare.getCenter(
            citizen.map((e) => LatLng(e.latitude, e.longitude)).toList());

        tempMarkers.add(MinimunMarker(
          //add start location marker
          id: "Group" + citizen.first.name,
          position: centerPos,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
      }
    }

    setState(() {
      markers.clear();
      markers = tempMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    const debug = false;
    print("Building The Map Widget, agin :()");

    final state = context.read<BagsQubit>().state;

    return BlocListener<BagsQubit, BagsState>(
      listenWhen: (old, n) =>
          old.visibleBags != n.visibleBags || old.quantities != n.quantities,
        listener: (context, state) async {
          convertSpotsToMarks(context);
        },
      child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: state.currentLocation!,
              zoom: 15,
            ),
            zoomControlsEnabled: false,
            compassEnabled: false,
            rotateGesturesEnabled: false,
            onCameraMove: (pos) {
          lastCameraPosition = pos;
            },
            onCameraIdle: () async {
              if (lastCameraPosition != null) {
            onCameraStopMoving(
                  lastCameraPosition!,
                  context.read<BagsQubit>(),
                );
                  lastCameraPosition = null;
              }
            },
            polygons: {
              if (debug)
                ...state.visibleSquares.map(
                  (e) => Polygon(
                    polygonId: PolygonId(e.id),
                    points: e.toPoints(),
                    fillColor: Colors.black12,
                    strokeWidth: 1,
                    strokeColor: Colors.black,
                  ),
                )
            },
            onMapCreated: initMap,
        markers: (Set()
          ..addAll(
                markers.map(
                  (e) => Marker(
                flat: true,
                    markerId: MarkerId(e.id),
                    position: e.position,
                    icon: e.icon,
                consumeTapEvents: false,
                draggable: false,

                visible: !e.hidden,
                    // visible: Random().nextBool(),
                    anchor: const Offset(0.5, 0.5),
                  ),
                ),
              )),
      ),
          );
        });
  }
}
