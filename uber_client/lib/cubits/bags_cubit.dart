import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/models/autosuggestion.dart';
import 'package:uber_client/models/mapSquare.dart';
import 'package:uber_client/repositories/geocoding.dart';
import 'package:uber_client/repositories/gps.dart';

import '../models/bag.dart';
import '../repositories/server.dart';

class BagsFilter {
  final String search;
  final bool hideSoldout;
  final String bagType;
  final bool isVegan;
  final bool isVegetarian;

  BagsFilter({
    this.search = "",
    this.hideSoldout = false,
    this.bagType = "",
    this.isVegan = false,
    this.isVegetarian = false,
  });

  BagsFilter copyWith({
    String? search,
    bool? hideSoldout,
    String? bagType,
    bool? isVegan,
    bool? isVegetarian,
  }) {
    return BagsFilter(
      search: search ?? this.search,
      hideSoldout: hideSoldout ?? this.hideSoldout,
      bagType: bagType ?? this.bagType,
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
    );
  }

  @override
  String toString() {
    return "search: $search, hideSoldout: $hideSoldout, bagType: $bagType, isVegan: $isVegan, isVegetarian: $isVegetarian";
  }
}

class Area {
  final LatLng center;
  final String name;
  final int radius;

  Area({
    required this.center,
    required this.name,
    required this.radius,
  });

  @override
  String toString() {
    return "center: $center, name: $name, radius: $radius";
  }
}

class BagsState extends Equatable {
  final List<Bag> bags;
  final List<Bag> visibleBags;
  final List<Autosuggestion> autosuggestions = [];

  final LatLng? currentLocation;
  final Area? currentArea;
  final Map<String, int> quantities;

  final List<MapSquare> squares;
  List<MapSquare> visibleSquares;

  final List<void Function(CameraUpdate)> attachedCameras;

  final BagsFilter filter;

  BagsState({
    required this.bags,
    required this.visibleBags,
    this.currentLocation,
    required this.squares,
    required this.visibleSquares,
    required this.filter,
    required this.attachedCameras,
    this.currentArea,
    required this.quantities,
  });

  @override
  List<Object> get props => [
        ...bags.map((e) => e.id).toList(),
        currentLocation.toString(),
        ...squares.map((e) => e.id).toList(),
        ...attachedCameras.map((e) => e.toString()).toList(),
        filter.toString(),
        visibleBags.map((e) => e.id).toList(),
        visibleSquares.map((e) => e.id).toList(),
        currentArea.toString(),
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
    BagsFilter? filter,
    Area? currentArea,
    Map<String, int>? quantities,
  }) {
    return BagsState(
      bags: bags ?? this.bags,
      currentLocation: currentLocation ?? this.currentLocation,
      squares: squares ?? this.squares,
      visibleSquares: visibleSquares ?? this.visibleSquares,
      attachedCameras: attachedCameras ?? this.attachedCameras,
      filter: filter ?? this.filter,
      visibleBags: visibleBags ?? this.visibleBags,
      currentArea: currentArea ?? this.currentArea,
      quantities: quantities ?? this.quantities,
    );
  }

  BagsState addBags(List<Bag> newBag) {
    for (var bag in newBag) {
      if (bags.every((element) => element.id != bag.id)) {
        bags.add(bag);
      }
    }

    return copyWith(
      bags: [...bags],
    );
  }

  BagsState addSquares(List<MapSquare> squares) {
    for (var square in squares) {
      if (this.squares.every((element) => element.id != square.id)) {
        this.squares.add(square);
      }
    }

    return copyWith(
      squares: [...this.squares],
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
          bags: [],
          squares: [],
          filter: BagsFilter(),
          attachedCameras: [],
          visibleBags: [],
          visibleSquares: [],
          quantities: {},
        ));

  Future<void> init() async {
    print("hello world");

    // get cached location and set it right away without fetching any data!
    final gpsLocation = await GpsRepository.getLocation();
    if (gpsLocation == null) return _fetchHot("alger");

    emit(state.copyWith(currentLocation: gpsLocation));

    await updateMapVisibilty(
      gpsLocation,
      MapSquare.createBounds(gpsLocation, 10),
    );

    final city = (await Geocoding.getCityName(gpsLocation)).split(",")[0];
    emit(state.copyWith(
      currentLocation: gpsLocation,
      currentArea: Area(
        center: gpsLocation,
        name: city,
        radius: 10,
      ),
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
    for (final square in freshSquares) {
      bags.addAll(await _fetchSquare(square));
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

  void updateFilter(BagsFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void setArea(Area area) {
    emit(state.copyWith(currentArea: area));
    // this is a hack to make sure the camera is moved after the state is updated
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
    int closeDistance = 5,
    int maxDistance = 20,
  }) {
    print("checking visible spots");
    final visibleSpots = spots.where((spot) {
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

    // todo don't forget to check for new ones then fetch them
    return visibles;
  }
}
