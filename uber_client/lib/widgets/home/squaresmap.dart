import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final void Function(MapSquare square) onSquareVisible;
  final void Function(List<Bag> spots) onSpotsVisible;
  final void Function(LatLng location) onLocationChange;
  final Widget Function(BuildContext context) mapLoader;
  final bool Function(Bag) filterBags;

  final List<Bag> spots;
  final LatLng? location;

  const SquaresMap({
    Key? key,
    required this.onSquareVisible,
    required this.onSpotsVisible,
    required this.onLocationChange,
    required this.spots,
    this.location,
    required this.mapLoader,
    required this.filterBags,
  }) : super(key: key);

  @override
  State<SquaresMap> createState() => _SquaresMapState();
}

class _SquaresMapState extends State<SquaresMap> {
  late GoogleMapController mapController;

  CameraPosition? lastCameraPosition;

  List<double>? centerZone;
  List<MapSquare> visibleSquares = [];
  Set<MinimunMarker> markers = {};

  LatLng scaleRatio = const LatLng(1, 1);

  void initMap(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  // void didUpdateWidget(SquaresMap oldWidget) {
  //   if (oldWidget.location.toString() != widget.location.toString()) {
  //     mapController.animateCamera(
  //       CameraUpdate.newLatLng(widget.location!),
  //     );
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  checkVisibleSpots(LatLngBounds bounds) async {
    final visibleSpots = widget.spots.where((spot) {
      final spotPosition = LatLng(spot.latitude, spot.longitude);

      final isWithinScreen = bounds.contains(spotPosition);
      final isFiltred = widget.filterBags(spot);

      return isWithinScreen && isFiltred;
    }).toList();

    widget.onSpotsVisible(visibleSpots);
  }

  checkVisibleSquares(LatLng center, LatLngBounds bounds) {
    final lat = [bounds.northeast.latitude, bounds.southwest.latitude];
    final lon = [bounds.northeast.longitude, bounds.southwest.longitude];
    const visibility = 45; // 50km

    while (MapSquare.calculateDifferenceInKm(lat[0], lat[1]) > visibility) {
      lat[0] = lat[0] - 0.01;
      lat[1] = lat[1] + 0.01;
    }

    while (MapSquare.calculateDifferenceInKm(lon[0], lon[1]) > visibility) {
      lon[0] = lon[0] - 0.01;
      lon[1] = lon[1] + 0.01;
    }

    print(MapSquare.calculateDifferenceInKm(lat[0], lat[1]));
    print(MapSquare.calculateDifferenceInKm(lon[0], lon[1]));

    centerZone = [lat[0], lat[1], lon[0], lon[1]];

    final List<MapSquare> visited = [];

    for (var i = lat[1]; i < lat[0]; i += 0.01) {
      for (var j = lon[1]; j < lon[0]; j += 0.01) {
        final targetSquare = MapSquare.fromOffset(Offset(j, i), 30);
        if (visited.every((element) => element.id != targetSquare.id)) {
          visited.add(targetSquare);
          widget.onSquareVisible(targetSquare);
        }
      }
    }

    visibleSquares = visited;
  }

  updateMapScaleRatio(LatLngBounds bounds) {
    scaleRatio = LatLng(
      bounds.northeast.latitude - bounds.southwest.latitude,
      bounds.northeast.longitude - bounds.southwest.longitude,
    );
  }

  onCameraStopMoving(CameraPosition position) async {
    widget.onLocationChange(position.target);

    final bounds = await mapController.getVisibleRegion();

    await checkVisibleSpots(bounds);
    await checkVisibleSquares(position.target, bounds);
    await updateMapScaleRatio(bounds);
    await convertSpotsToMarks();
  }

  convertSpotsToMarks() async {
    final visibleSpots = widget.spots.where((spot) {
      final spotPosition = LatLng(spot.latitude, spot.longitude);

      return visibleSquares.any((square) => square.isWithin(spotPosition));
    }).toList();

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
        // find center
        final lat = citizen.map((e) => e.latitude).reduce((a, b) => a + b) /
            citizen.length;
        final lon = citizen.map((e) => e.longitude).reduce((a, b) => a + b) /
            citizen.length;

        tempMarkers.add(
          MinimunMarker(
              //add start location marker
              id: "Group",
              position: LatLng(lat, lon),
              icon: BitmapDescriptor.defaultMarker),
        );
      }
    }

    markers.clear();
    markers = tempMarkers;
  }

  @override
  Widget build(BuildContext context) {
    const debug = false;

    if (widget.location == null) return widget.mapLoader(context);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.location!,
        zoom: 14.4746,
      ),
      zoomControlsEnabled: false,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      onCameraMove: (pos) {
        setState(() => lastCameraPosition = pos);
      },
      onCameraIdle: () async {
        if (lastCameraPosition != null) {
          await onCameraStopMoving(lastCameraPosition!);
          mapController.clearTileCache(TileOverlayId('mapbox-satellite'));
          setState(() {
            lastCameraPosition = null;
          });
        }
      },
      polygons: {
        if (centerZone != null)
          Polygon(
            polygonId: PolygonId('test'),
            points: [
              LatLng(centerZone![0], centerZone![2]),
              LatLng(centerZone![0], centerZone![3]),
              LatLng(centerZone![1], centerZone![3]),
              LatLng(centerZone![1], centerZone![2]),
            ],
            strokeWidth: 2,
            strokeColor: Colors.red,
            fillColor: Colors.red.withOpacity(0.5),
          )
      },
      onMapCreated: initMap,
      markers: (<Marker>{}..addAll(
          markers.map(
            (e) => Marker(
              markerId: MarkerId(e.id),
              position: e.position,
              icon: e.icon,
              // visible: Random().nextBool(),
              anchor: const Offset(0.5, 0.5),
            ),
          ),
        )),
    );
  }
}
