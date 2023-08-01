import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
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
  bool hidden = false;

  MinimunMarker({
    required this.id,
    required this.position,
    required this.icon,
  });
}

class SquaresMap extends StatefulWidget {
  final bool Function(Bag) filterBags;

  const SquaresMap({
    Key? key,
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
    if (position.zoom < 9 || position.zoom > 18) return;

    final bounds = await mapController.getVisibleRegion();
    await bagsQubit.updateMapVisibilty(position.target, bounds);

    updateMapScaleRatio(bounds);
  }

// need to be here
  Timer? debounce1;
  setMarkers(Set<MinimunMarker> markers) async {
    if (debounce1 != null && debounce1!.isActive) debounce1!.cancel();
    debounce1 = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      if (markers.length == this.markers.length) {
        final pureRendersMarkers =
            markers.where((element) => !element.hidden).toList();

        final noChange = pureRendersMarkers.length == this.markers.length &&
            pureRendersMarkers.every(
                (element) => this.markers.any((n) => n.id == element.id));

        if (noChange) {
          print("no Change in the markers");
          return;
        }
      }

      setState(() {
        this.markers = markers;
      });
    });
  }

  // convert spots to marks and group Marks if needed
  convertSpotsToMarks(BuildContext context) async {
    final visibleSpots = context.read<BagsQubit>().state.filtredBags;
    final quantities = context.read<BagsQubit>().state.quantities;

    final citizens = Utils.groupSpots(visibleSpots, (a, b) {
      final latDiff = (a.latitude - b.latitude).abs();
      final lonDiff = (a.longitude - b.longitude).abs();

      final latRatio = latDiff / scaleRatio.latitude;
      final lonRatio = lonDiff / scaleRatio.longitude;

      if (latRatio < 0.07 && lonRatio < 0.07) return true;
      return false;
    });

    final Set<MinimunMarker> tempMarkers = {};

    for (var citizen in citizens) {
      if (citizen.length == 1) {
        tempMarkers.add(MinimunMarker(
          id: citizen.first.id.toString(),
          position: LatLng(
            citizen.first.latitude,
            citizen.first.longitude,
          ), //position of marker
          icon: await MapMark.instance.minNum(
            1,
            (quantities[citizen.first.id.toString()] ?? 0) > 0,
          ),
        ));
      } else {
        final centerPos = MapSquare.getCenter(
            citizen.map((e) => LatLng(e.latitude, e.longitude)).toList());

        final id = "Group${citizen.map((e) => e.id.toString()).join(",")}";
        tempMarkers.add(MinimunMarker(
          //add start location marker
          id: id,
          position: centerPos,
          icon: await MapMark.instance.minNum(citizen.length, true),
        ));
      }
    }

    // check if the markers changed or not
    // final pureRendersMarkers =
    //     markers.where((element) => !element.hidden).toList();

    // // final noChange = pureRendersMarkers.length == tempMarkers.length &&
    // //     pureRendersMarkers
    // //         .every((element) => tempMarkers.any((n) => n.id == element.id));

    // // final toBeRemoved = pureRendersMarkers
    // //     .where((element) => tempMarkers.every((n) => n.id != element.id))
    // //     .toList();

    setMarkers(tempMarkers);
  }

  @override
  Widget build(BuildContext context) {
    const debug = false;
    print("Building The Map Widget, agin :()");

    final state = context.read<BagsQubit>().state;

    return BlocListener<BagsQubit, BagsState>(
      listenWhen: (old, n) =>
          old.visibleBags != n.visibleBags ||
          old.quantities != n.quantities ||
          old.filtredBags.length != n.filtredBags.length,
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
  }
}
