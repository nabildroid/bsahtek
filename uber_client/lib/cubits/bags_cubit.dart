import 'dart:async';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_client/models/autosuggestion.dart';
import 'package:uber_client/models/mapSquare.dart';
import 'package:uber_client/repositories/bags_remote.dart';
import 'package:uber_client/repositories/gps.dart';

import '../models/bag.dart';

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

class BagsState extends Equatable {
  final List<Bag> bags;
  final List<Autosuggestion> autosuggestions = [];

  final LatLng? currentLocation;
  final List<MapSquare> squares;

  final BagsFilter filter;

  BagsState({
    required this.bags,
    this.currentLocation,
    required this.squares,
    required this.filter,
  });

  @override
  List<Object> get props => [
        ...bags.map((e) => e.id).toList(),
        currentLocation.toString(),
        ...squares.map((e) => e.id).toList(),
      ];

  BagsState copyWith({
    List<Bag>? bags,
    List<Autosuggestion>? autosuggestions,
    LatLng? currentLocation,
    List<MapSquare>? squares,
    BagsFilter? filter,
  }) {
    return BagsState(
      bags: bags ?? this.bags,
      currentLocation: currentLocation ?? this.currentLocation,
      squares: squares ?? this.squares,
      filter: filter ?? this.filter,
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

  BagsState addSquare(MapSquare square) {
    if (squares.every((element) => element.id != square.id)) {
      squares.add(square);
    }

    return copyWith(
      squares: [...squares],
    );
  }
}

class BagsQubit extends Cubit<BagsState> {
  final GpsRepository gps;
  final BagRemote bagRemote;

  BagsQubit(
    this.gps,
    this.bagRemote,
  ) : super(BagsState(
          bags: [],
          squares: [],
          filter: BagsFilter(),
        ));

  Future<void> init() async {
    print("hello world");

    // get cached location and set it right away without fetching any data!
    await _getLocation().then((location) {
      if (location == null) return _fetchHot("alger");
      return _handleAllandFetch(location);
    });
  }

  Future<LatLng?> _getLocation() async {
    final refusedToUseLocation =
        !await gps.isPermitted() && !await gps.requestPermission();

    if (refusedToUseLocation) {
      return null;
    } else {
      final coords = await gps.getCurrentPosition();
      if (coords == null) return null;
      return LatLng(coords.dy, coords.dx);
    }
  }

  void _handleAllandFetch(LatLng pos) async {
    final square =
        MapSquare.fromOffset(Offset(pos.longitude, pos.latitude), 10);

    final bags = await bagRemote.getByCoordinations(
      square.longitude,
      square.latitude,
    );

    emit(
      state.addBags(bags).addSquare(square).copyWith(currentLocation: pos),
    );
  }

  void _fetchHot(String wilaya) async {
    final bags = await bagRemote.getHotByWilaya(wilaya);

    if (bags.isNotEmpty) {
      final centerPos = LatLng(bags.first.latitude, bags.first.longitude);
      final square = MapSquare.fromOffset(
          Offset(centerPos.longitude, centerPos.latitude), 1);

      emit(
        state.addSquare(square).copyWith(currentLocation: centerPos),
      );
    }
    emit(state.addBags(bags));
  }

  void visiteSquare(MapSquare square) {
    final isNewSquare =
        state.squares.every((element) => element.id != square.id);

    if (isNewSquare) {
      final center = square.toOffset();
      print("new square ${square.latitude},${square.longitude}");
      _handleAllandFetch(
        LatLng(center.dy, center.dx),
      );
    }
  }

  void updateFilter(BagsFilter filter) {
    emit(state.copyWith(filter: filter));
  }
}
