import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bsahtak/models/autosuggestion.dart';
import 'package:bsahtak/models/mapSquare.dart';
import 'package:bsahtak/repositories/geocoding.dart';
import 'package:bsahtak/repositories/gps.dart';
import 'package:bsahtak/utils/utils.dart';

import '../models/bag.dart';
import '../repositories/cache.dart';
import '../repositories/server.dart';

class Area {
  final LatLng center;
  final String name;
  final int radius;

  const Area({
    required this.center,
    required this.name,
    required this.radius,
  });

  @override
  String toString() {
    return "center: $center, name: $name, radius: $radius";
  }

  toMap() {
    return {
      "center": {
        "latitude": center.latitude,
        "longitude": center.longitude,
      },
      "name": name,
      "radius": radius,
    };
  }

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      center: LatLng(map["center"]["latitude"], map["center"]["longitude"]),
      name: map["name"],
      radius: map["radius"],
    );
  }
}

class BagsState extends Equatable {
  final List<Bag> bags;
  final List<Bag> visibleBags;
  final List<Autosuggestion> autosuggestions = []; // todo remove this

  final LatLng? currentLocation;
  final Area? currentArea;
  final Map<String, int> quantities;

  final List<MapSquare> squares;
  List<MapSquare> visibleSquares;

  final List<void Function(CameraUpdate)> attachedCameras;

  final List<String> selectedTags;
  List<String> get availableTags {
    final tags = <String>[];

    for (var bag in bags) {
      if (!tags.contains(bag.tags) && bag.tags.trim() != "") {
        tags.add(bag.tags);
      }
    }

    return tags;
  }

  List<Bag> get filtredBags {
    if (selectedTags.isEmpty) return [...visibleBags];
    return visibleBags
        .where((element) => selectedTags.contains(element.tags))
        .toList();
  }

  BagsState({
    required this.bags,
    required this.visibleBags,
    this.currentLocation,
    required this.squares,
    required this.visibleSquares,
    required this.attachedCameras,
    this.currentArea,
    required this.quantities,
    required this.selectedTags,
  });

  @override
  List<Object> get props => [
        ...bags.map((e) => e.id).toList(),
        currentLocation.toString(),
        ...squares.map((e) => e.id).toList(),
        ...attachedCameras.map((e) => e.toString()).toList(),
        visibleBags.map((e) => e.id).toList(),
        visibleSquares.map((e) => e.id).toList(),
        currentArea.toString(),
        selectedTags.toString(),
        quantities.entries.map((e) => "${e.key};${e.value}").join(":"),
      ];

  BagsState copyWith({
    List<Bag>? bags,
    List<Autosuggestion>? autosuggestions,
    LatLng? currentLocation,
    List<MapSquare>? squares,
    List<void Function(CameraUpdate)>? attachedCameras,
    List<Bag>? visibleBags,
    List<MapSquare>? visibleSquares,
    Area? currentArea,
    Map<String, int>? quantities,
    List<String>? selectedTags,
  }) {
    return BagsState(
      bags: bags ?? this.bags,
      currentLocation: currentLocation ?? this.currentLocation,
      squares: squares ?? this.squares,
      visibleSquares: visibleSquares ?? this.visibleSquares,
      attachedCameras: attachedCameras ?? this.attachedCameras,
      visibleBags: visibleBags ?? this.visibleBags,
      currentArea: currentArea ?? this.currentArea,
      quantities: quantities ?? this.quantities,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }

  BagsState addBags(List<Bag> newBag) {
    final copy = List<Bag>.from(bags);
    for (var bag in newBag) {
      if (copy.every((element) => element.id != bag.id)) {
        copy.add(bag);
      }
    }

    return copyWith(
      bags: copy,
    );
  }

  BagsState addSquares(List<MapSquare> squares) {
    final copy = List<MapSquare>.from(this.squares);
    for (var square in squares) {
      if (copy.every((element) => element.id != square.id)) {
        copy.add(square);
      }
    }

    return copyWith(
      squares: copy,
    );
  }

  BagsState addCameraAttachment(void Function(CameraUpdate) callback) {
    return copyWith(
      attachedCameras: [...attachedCameras, callback],
    );
  }

  BagsState addQuantity(Map<String, int> tobeInserted) {
    final q = {...quantities, ...tobeInserted};

    return copyWith(
      quantities: q,
    );
  }
}

class BagsQubit extends Cubit<BagsState> {
  final List<VoidCallback> activeSubs = [];

  @override
  close() async {
    for (var sub in activeSubs) {
      sub();
    }
    super.close();
  }

  BagsQubit()
      : super(BagsState(
          bags: const [],
          squares: const [],
          attachedCameras: const [],
          visibleBags: const [],
          visibleSquares: const [],
          selectedTags: const [],
          quantities: const {},
          currentArea: Cache.currentArea,
        ));

  Future<void> init() async {
    print("hello world");

    // get cached location and set it right away without fetching any data!
    final gpsLocation =
        (await GpsRepository.getLocation() ?? Cache.currentArea?.center);
    // since we have a fall back when the gps is null, we can use it, so the bellow code is not needed
    if (gpsLocation == null) return _fetchHot("alger");

    emit(state.copyWith(currentLocation: gpsLocation));

    await updateMapVisibilty(
      gpsLocation,
      MapSquare.createBounds(gpsLocation, 10),
    );

    final defaultDistance = Cache.currentArea?.radius ?? 10;
    final defaultCityName = Cache.currentArea?.name ?? "Algeria";
    emit(state.copyWith(
      currentLocation: gpsLocation,
      currentArea: Area(
        center: gpsLocation,
        name: defaultCityName,
        radius: defaultDistance,
      ),
    ));

    if (gpsLocation.toJson() == Cache.currentArea?.center.toJson()) return;

    final city = (await Geocoding.getCityName(gpsLocation)).split(",")[0];
    final newArea = Area(
      center: gpsLocation,
      name: city,
      radius: defaultDistance,
    );

    Cache.currentArea = newArea;

    emit(state.copyWith(
      currentLocation: gpsLocation,
      currentArea: newArea,
    ));
  }

  Future<List<Bag>> _fetchSquare(MapSquare square) async {
    final bags = await Server().getBagsInCell(
      square.longitude,
      square.latitude,
    );
    // listen to the associtated

    activeSubs.add(Server().listenToZone(
      "${square.longitude},${square.latitude}",
      (data) {
        final quantites = data["quantities"];

        if (quantites == null) return;

        final q = Map<String, int>.from(quantites);

        emit(state.addQuantity(q));
      },
    ));

    return bags;
  }

  void _fetchHot(String wilaya) async {
    // final bags = await bagRemote.getHotByWilaya(wilaya);

    // if (bags.isNotEmpty) {
    //   final centerPos = LatLng(bags.first.latitude, bags.first.longitude);
    //   final square = MapSquare.fromOffset(
    //       Offset(centerPos.longitude, centerPos.latitude), 1);

    //   emit(
    //     state.addSquares([square]).copyWith(currentLocation: centerPos),
    //   );
    // }
    // emit(state.addBags(bags));
  }

  Future<List<Bag>> _visiteSquares(List<MapSquare> squares) async {
    final freshSquares =
        squares.where((a) => state.squares.every((b) => b.id != a.id)).toList();

    final bags = <Bag>[];

    final fetchedSquares =
        await Future.wait(freshSquares.map((e) => _fetchSquare(e)).toList());

    for (final items in fetchedSquares) {
      bags.addAll(items);
    }

    return bags;
  }

  void attachCameraEvent(void Function(CameraUpdate) callback) {
    emit(state.addCameraAttachment(callback));
  }

  void moveCamera(CameraUpdate cameraUpdate) {
    for (var attachedCamera in state.attachedCameras) {
      attachedCamera(cameraUpdate);
    }
  }

  void setArea(Area area) {
    emit(state.copyWith(currentArea: area));
    // this is a hack to make sure the camera is moved after the state is updated

    moveCamera(CameraUpdate.newLatLng(LatLng(
      area.center.latitude,
      area.center.longitude,
    )));
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      updateMapVisibilty(
        area.center,
        MapSquare.createBounds(area.center, area.radius),
      );
    });
  }

  Future<List<MapSquare>> updateMapVisibilty(
      LatLng cameraPosition, LatLngBounds bounds) async {
    final visibleSquares = _checkVisibleSquares(
      cameraPosition,
      bounds,
    );

    emit(state.copyWith(visibleSquares: visibleSquares));

    // sometimes concurrent calls make the await go crazy, you need to abord all the previous calls
    final freshSpots = await _visiteSquares(visibleSquares);

    final visibleSpots = _checkVisibleSpots(
      spots: [...state.bags, ...freshSpots],
      visibleSquares: visibleSquares,
      cameraPostion: cameraPosition,
      closeDistance: state.currentArea?.radius ?? 5,
      maxDistance: min(state.currentArea?.radius ?? 1 * 45, 45),
    );

    emit(state.addBags(freshSpots).addSquares(visibleSquares).copyWith(
          visibleBags: visibleSpots,
          currentLocation: cameraPosition,
        ));

    return visibleSquares;
  }

  static List<Bag> _checkVisibleSpots({
    required List<Bag> spots,
    required List<MapSquare> visibleSquares,
    required LatLng cameraPostion,
    int closeDistance = 5, // todo move it to the Constants
    int maxDistance = 20,
  }) {
    print("checking visible spots");

    final uniqueSpots =
        List<Bag>.from(Utils.removeDeplication(spots, (item) => item.id));

    final visibleSpots = uniqueSpots.where((spot) {
      print("checking visible spots");

      final spotPosition = LatLng(spot.latitude, spot.longitude);

      final isWithinRegion =
          visibleSquares.any((element) => element.isWithin(cameraPostion));

      final distance = Geolocator.distanceBetween(
            cameraPostion.latitude,
            cameraPostion.longitude,
            spotPosition.latitude,
            spotPosition.longitude,
          ) /
          1000;

      final isFiltred = true; //widget.filterBags(spot);

      if (!isFiltred || !isWithinRegion) return false;
      if (visibleSquares.length > 1 && distance < maxDistance) return true;
      if (visibleSquares.length == 1 && distance < closeDistance) return true;

      return false;
    }).toList();

    return visibleSpots;
  }

  static List<MapSquare> _checkVisibleSquares(
      LatLng center, LatLngBounds bounds) {
    final lat = [
      MapSquare.addKlmToLongitude(bounds.northeast.latitude, 10),
      MapSquare.addKlmToLongitude(bounds.southwest.latitude, -10)
    ];
    final lon = [
      MapSquare.addKlmToLongitude(bounds.northeast.longitude, 10),
      MapSquare.addKlmToLongitude(bounds.southwest.longitude, -10)
    ];

    const visibility = 30; // 50km

    // shrink it
    while (MapSquare.calculateDifferenceInKm(lat[0], lat[1]) > visibility) {
      lat[0] = lat[0] - 0.005;
      lat[1] = lat[1] + 0.005;
    }

    while (MapSquare.calculateDifferenceInKm(lon[0], lon[1]) > visibility) {
      lon[0] = lon[0] - 0.005;
      lon[1] = lon[1] + 0.005;
    }

    print(MapSquare.calculateDifferenceInKm(lat[0], lat[1]));
    print(MapSquare.calculateDifferenceInKm(lon[0], lon[1]));

    final List<MapSquare> visibles = [];

    int a = 0;
    for (var i = lat[1]; i < lat[0]; i += 0.05) {
      for (var j = lon[1]; j < lon[0]; j += 0.05) {
        a++;
        final targetSquare = MapSquare.fromOffset(Offset(j, i), 30);
        if (visibles.every((element) => element.id != targetSquare.id)) {
          visibles.add(targetSquare);
        }
      }
    }

    return visibles;
  }

  void toggleTag(String tag) {
    final tags = [...state.selectedTags];
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }

    emit(state.copyWith(selectedTags: tags));
  }
}
