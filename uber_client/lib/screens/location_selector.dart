import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bsahtak/cubits/bags_cubit.dart';
import 'package:bsahtak/models/mapSquare.dart';
import 'package:bsahtak/repositories/geocoding.dart';

class LocationSelector extends StatefulWidget {
  static go(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) {
        return const LocationSelector();
      },
    ));
  }

  const LocationSelector({super.key});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  bool isExpanded = false;

  final TextEditingController _searchEditingController =
      TextEditingController();
  final FocusNode _focusSearch = FocusNode();

  Map<String, LatLng> suggestions = {};

  LatLng centre = LatLng(
    36.777609783186975,
    2.9853606820318834,
  );
  int distance = 20;

  GoogleMapController? mapController;

  Future<void> search(String query) async {
    final data = await Geocoding.searchAddress(query);
    if (!mounted) return;
    setState(() {
      suggestions = data;
    });
  }

  void selectSuggestion(String key) {
    setState(() {
      centre = suggestions[key]!;

      isExpanded = false;
      _searchEditingController.clear();
      _focusSearch.unfocus();
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: centre,
            zoom: 14,
          ),
        ),
      );
    });
  }

  void applyLocation() async {
    final bagsCubit = context.read<BagsQubit>();

    final prevArea = bagsCubit.state.currentArea;

    bagsCubit.setArea(Area(
      center: centre,
      radius: distance,
      name: bagsCubit.state.currentArea?.name ?? "Beni Messous",
    ));

    // not sure if this pattern is good
    Navigator.of(context).pop();

    final locationName = await Geocoding.getCityName(centre);

    if (locationName != "") {
      bagsCubit.setArea(Area(
        center: centre,
        radius: distance,
        name: locationName,
      ));
    } else {
      bagsCubit.setArea(prevArea!);
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      distance = context.read<BagsQubit>().state.currentArea?.radius ?? 30;
      centre = context.read<BagsQubit>().state.currentArea?.center ??
          LatLng(36.777609783186975, 2.9853606820318834);
    });

    Timer? debouncer;

    _searchEditingController.addListener(() {
      final query = _searchEditingController.text;

      if (debouncer != null) debouncer!.cancel();
      if (debouncer?.isActive ?? false) debouncer?.cancel();

      debouncer = Timer(const Duration(seconds: 1), () {
        if (!mounted) return;

        if (query.isEmpty) {
          setState(() {
            suggestions = {};
          });
        } else if (query.length > 2) {
          search(query);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Theme(
        data: Theme.of(context).copyWith(
          bottomSheetTheme: Theme.of(context)
              .bottomSheetTheme
              .copyWith(backgroundColor: Colors.transparent),
        ),
        child: Scaffold(
          body: FractionallySizedBox(
            heightFactor: .7,
            child: Stack(
              clipBehavior: Clip.antiAlias,
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: BlocConsumer<BagsQubit, BagsState>(
                      listener: (context, state) {
                        setState(() {
                          centre = state.currentLocation ?? centre;
                          mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: centre,
                                zoom: MapSquare.calculateZoomLevel(
                                  distance + 0.0,
                                  MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                          );
                        });
                      },
                      listenWhen: (o, n) =>
                          o.currentLocation != n.currentLocation,
                      buildWhen: (o, n) => o != n,
                      builder: (context, state) {
                        if (state.currentLocation == null)
                          return Center(child: CircularProgressIndicator());
                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: state.currentLocation!,
                            zoom: 14,
                          ),
                          compassEnabled: false,
                          onCameraMove: (position) {
                            if (mounted) {
                              setState(() {
                                centre = position.target;
                              });
                            }
                          },
                          onMapCreated: (controller) {
                            mapController = controller;
                            mapController?.moveCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: centre,
                                  zoom: MapSquare.calculateZoomLevel(
                                    distance + 0.0,
                                    MediaQuery.of(context).size.width,
                                  ),
                                ),
                              ),
                            );
                          },
                          zoomControlsEnabled: false,
                          myLocationEnabled: false,
                        );
                      }),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedSlide(
                    offset: isExpanded ? Offset(0, -2) : Offset(0, 0),
                    duration: Duration(milliseconds: 800),
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.home_location_title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.close),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 30,
                    child: AnimatedSlide(
                        offset: isExpanded ? Offset(0, 0) : Offset(0, -2),
                        duration: Duration(milliseconds: 350),
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isExpanded = false;
                                _searchEditingController.clear();
                                _focusSearch.unfocus();
                              });
                            },
                            icon: Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
          bottomSheet: AnimatedFractionallySizedBox(
            duration: Duration(milliseconds: 450),
            heightFactor: isExpanded ? 0.8 : .42,
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 350),
                    child: isExpanded
                        ? SizedBox.shrink()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppLocalizations.of(context)!
                                  .home_location_distance_select),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: distance.toDouble(),
                                      max: 30,
                                      min: 5,
                                      divisions: 3,
                                      onChanged: (value) {
                                        setState(() {
                                          distance = value.toInt();

                                          mapController?.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                target: centre,
                                                zoom: MapSquare
                                                    .calculateZoomLevel(
                                                  distance + 0.0,
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                  Text("$distance " +
                                      AppLocalizations.of(context)!
                                          .home_location_km),
                                ],
                              ),
                            ],
                          ),
                  ),

                  // rounded with 20 radius and grey with opacity 0.2 input with icon of search at left and centre placeholder "Search for a city"
                  TextField(
                    onTap: () {
                      _focusSearch.unfocus();
                      Future.delayed(Duration(milliseconds: 350), () {
                        _focusSearch.requestFocus();
                      });
                      setState(() => isExpanded = true);
                    },
                    controller: _searchEditingController,
                    focusNode: _focusSearch,
                    textAlign: !isExpanded ? TextAlign.center : TextAlign.start,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      prefixIcon: Icon(Icons.search),
                      hintText:
                          AppLocalizations.of(context)!.home_location_search,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.read<BagsQubit>().init(context);
                    },
                    icon: Icon(Icons.location_on_outlined),
                    label: Text(
                        AppLocalizations.of(context)!.home_location_useGPS),
                  ),
                  if (!isExpanded)
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: applyLocation,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .home_location_select,
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: StadiumBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (isExpanded && suggestions.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...suggestions.keys.map(
                              (key) => ListTile(
                                minVerticalPadding: 0,
                                dense: true,
                                leading: Icon(Icons.location_on_outlined),
                                onTap: () => selectSuggestion(key),
                                title: Text(key),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchEditingController.dispose();
    _focusSearch.dispose();
    super.dispose();
  }
}
