import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/bag.dart';
import '../models/mapSquare.dart';
import '../utils/utils.dart';

class SquaresMap extends StatefulWidget {
  final void Function(MapSquare square) onSquareVisible;
  final void Function(Bag spot) onSpotVisible;
  final void Function(LatLng location) onLocationChange;
  final Widget Function(BuildContext context) mapLoader;

  final List<Bag> spots;
  final LatLng? location;

  const SquaresMap({
    Key? key,
    required this.onSquareVisible,
    required this.onSpotVisible,
    required this.onLocationChange,
    required this.spots,
    this.location,
    required this.mapLoader,
  }) : super(key: key);

  @override
  State<SquaresMap> createState() => _SquaresMapState();
}

class _SquaresMapState extends State<SquaresMap> {
  late GoogleMapController mapController;

  CameraPosition? lastCameraPosition;

  List<double>? centerZone;
  List<MapSquare> visibleSquares = [];

  LatLng scaleRatio = const LatLng(1, 1);

  void initMap(GoogleMapController controller) {
    mapController = controller;
  }

  void checkVisibleSpots(LatLngBounds bounds) {
    final visibleSpots = widget.spots.where((spot) {
      final spotPosition = LatLng(spot.latitude, spot.longitude);

      return bounds.contains(spotPosition);
    }).toList();

    visibleSpots.forEach(widget.onSpotVisible);
  }

  void checkVisibleSquares(LatLng center, LatLngBounds bounds) {
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

    setState(() {
      centerZone = [lat[0], lat[1], lon[0], lon[1]];
    });

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

    setState(() {
      visibleSquares = visited;
    });
  }

  void updateMapScaleRatio(LatLngBounds bounds) {
    setState(() {
      scaleRatio = LatLng(
        bounds.northeast.latitude - bounds.southwest.latitude,
        bounds.northeast.longitude - bounds.southwest.longitude,
      );
    });
  }

  void onCameraStopMoving(CameraPosition position) async {
    widget.onLocationChange(position.target);

    final bounds = await mapController.getVisibleRegion();

    checkVisibleSpots(bounds);
    checkVisibleSquares(position.target, bounds);
    updateMapScaleRatio(bounds);
  }

  Set<Circle> convertSpotsToCircles() {
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

    print(citizens.length);
    final circles = <Circle>{};

    for (var citizen in citizens) {
      if (citizen.length == 1) {
        circles.add(Circle(
          circleId: CircleId(citizen.first.id.toString()),
          center: LatLng(citizen.first.latitude, citizen.first.longitude),
          radius: 500,
          strokeWidth: 0,
          zIndex: 2555555555,
          fillColor: Colors.green.shade800,
        ));
      } else {
        // find center
        final lat = citizen.map((e) => e.latitude).reduce((a, b) => a + b) /
            citizen.length;
        final lon = citizen.map((e) => e.longitude).reduce((a, b) => a + b) /
            citizen.length;

        circles.add(Circle(
          circleId: CircleId(citizen.first.id.toString()),
          center: LatLng(lat, lon),
          radius: 1000,
          strokeWidth: 0,
          zIndex: 2555555555,
          fillColor: Colors.blue.shade800,
        ));
      }
    }

    return circles;
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
      minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
      onCameraMove: (pos) {
        setState(() => lastCameraPosition = pos);
      },
      polygons: !debug
          ? Set()
          : (Set()
            ..addAll(
              centerZone != null
                  ? [
                      Polygon(
                        polygonId: PolygonId('center'),
                        points: [
                          LatLng(centerZone![0], centerZone![2]),
                          LatLng(centerZone![0], centerZone![3]),
                          LatLng(centerZone![1], centerZone![3]),
                          LatLng(centerZone![1], centerZone![2]),
                        ],
                        zIndex: 2,
                        strokeWidth: 0,
                        fillColor: Colors.yellow.shade800.withOpacity(0.5),
                      ),
                    ]
                  : [],
            )
            ..addAll(
              visibleSquares.map(
                (square) => Polygon(
                  polygonId: PolygonId(square.id),
                  fillColor: widget.location == null
                      ? Colors.teal
                      : square.isWithin(widget.location!)
                          ? Colors.red.withOpacity(.5)
                          : Colors.green.withOpacity(.5),
                  strokeColor: Colors.green.shade800,
                  zIndex: 1,
                  strokeWidth: 2,
                  points: square.toPoints(),
                ),
              ),
            )),
      onCameraIdle: () {
        if (lastCameraPosition != null) {
          setState(() {
            onCameraStopMoving(lastCameraPosition!);
            lastCameraPosition = null;
          });
        }
      },
      onMapCreated: initMap,
      circles: convertSpotsToCircles(),
    );
  }
}
