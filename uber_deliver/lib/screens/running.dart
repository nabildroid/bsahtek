import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_deliver/cubits/service_cubit.dart';
import 'package:uber_deliver/repository/gps.dart';
import 'package:uber_deliver/screens/runningNoti.dart';
import '../models/delivery_request.dart';
import '../repository/cache.dart';
import '../repository/server.dart';

class RunningScreen extends StatefulWidget {
  final DeliveryRequest deliveryRequest;

  static go(BuildContext ctx, DeliveryRequest deliveryRequest) {
    return Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (ctx) => RunningScreen(
          deliveryRequest: deliveryRequest,
        ),
      ),
    );
  }

  RunningScreen({
    Key? key,
    required this.deliveryRequest,
  }) : super(key: key);

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  final MapController _mapController = MapController();

  List<LatLng> get directionPoints => [
        ...widget.deliveryRequest.toSeller.points,
        ...widget.deliveryRequest.toClient.points
      ];

  @override
  void initState() {
    super.initState();
  }

  TimeOfDay estimitedDelivery = TimeOfDay.now();

  LatLng? currentLocation;
  bool isCloseToClient = false;

  void exit() {
    context.read<ServiceCubit>().unfocusFromRunning();
    Navigator.of(context).pop();
  }

  void stop() {
    context.read<ServiceCubit>().killDelivery();
    Navigator.of(context).pop();
  }

  void handover() async {
    final location = await GpsRepository.getLocation();
    if (location == null) return;

    await Server().finishTrack(widget.deliveryRequest.order, location);
    context.read<ServiceCubit>().finishDelivery();
    exit();
  }

  void initMap() {
    final zoom = _mapController.centerZoomFitBounds(
      LatLngBounds.fromPoints(directionPoints),
      options: FitBoundsOptions(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ).copyWith(
          top: 100,
          bottom: MediaQuery.of(context).size.height * .5,
        ),
      ),
    );

    _mapController.move(
        LatLng(
          zoom.center.latitude,
          zoom.center.longitude,
        ),
        zoom.zoom);

    setState(() {
      estimitedDelivery =
          TimeOfDay.fromDateTime(widget.deliveryRequest.order.lastUpdate.add(
        Duration(
          seconds: widget.deliveryRequest.toClient.duration.inSeconds +
              widget.deliveryRequest.toSeller.duration.inSeconds,
        ),
      ));
    });

    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (widget.deliveryRequest.order.expired) {
        stop();
        timer.cancel();
        return;
      }

      Cache.trackingLocation = await GpsRepository.getLocation();
      final trackLocation = Cache.trackingLocation;

      final alreadyFromSeller = Cache.trackedToSeller != null;

      if (trackLocation == null) return;

      final distanceToClient = Geolocator.distanceBetween(
        trackLocation.latitude,
        trackLocation.longitude,
        widget.deliveryRequest.order.clientAddress.latitude,
        widget.deliveryRequest.order.clientAddress.longitude,
      );

      setState(() {
        currentLocation = trackLocation;
        isCloseToClient = distanceToClient < 500 && alreadyFromSeller;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // todo the client is sending the order information via the notification, we don't have any information to verify the pricing
    final totalPrice = distanceToPrice(
          widget.deliveryRequest.toSeller.distance / 1000,
        ) +
        int.parse(widget.deliveryRequest.order.bagPrice);

    return WillPopScope(
      onWillPop: () {
        context.read<ServiceCubit>().unfocusFromRunning();
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                rotation: 0,
                enableMultiFingerGestureRace: false,
                interactiveFlags: InteractiveFlag.none,
                onMapReady: initMap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: directionPoints,
                      strokeWidth: 4,
                      color: Colors.blueGrey.shade900,
                    ),
                  ],
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: directionPoints.first,
                      color: Colors.green.shade400,
                      borderColor: Colors.blueGrey.shade900,
                      borderStrokeWidth: 4,
                      radius: 8,
                    ),
                    CircleMarker(
                      point: widget.deliveryRequest.toSeller.points.last,
                      color: Colors.green.shade200,
                      borderColor: Colors.blueGrey.shade900,
                      borderStrokeWidth: 2,
                      radius: 6,
                    ),
                    CircleMarker(
                      point: directionPoints.last,
                      color: Colors.green.shade400,
                      borderColor: Colors.blueGrey.shade900,
                      borderStrokeWidth: 4,
                      radius: 8,
                    ),
                    if (currentLocation != null)
                      CircleMarker(
                        point: currentLocation!,
                        color: Colors.yellow,
                        radius: 8,
                      ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment(-.9, -.9),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade900,
                  foregroundColor: Colors.white,
                ),
                onPressed: exit,
                icon: Icon(Icons.arrow_back),
                label: Text("Back"),
              ),
            ),
            Align(
              alignment: Alignment(.9, -.9),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade900,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
                icon: Icon(Icons.stop),
                label: Text("\$$totalPrice"),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Hero(
                tag: "running",
                child: AcceptedOrderPanel(
                  handOver: isCloseToClient ? handover : null,
                  clientLocation: widget.deliveryRequest.order.clientAddress,
                  sellerLocation: widget.deliveryRequest.order.sellerAddress,
                  deliveryAt: estimitedDelivery,
                  clientName: widget.deliveryRequest.order.clientName,
                  clientPhone: widget.deliveryRequest.order.clientPhone,
                  clientPhoto:
                      "https://cdn.pixabay.com/photo/2015/03/04/22/35/head-659651_960_720.png",
                  sellerName: widget.deliveryRequest.order.sellerName,
                  sellerPhone: widget.deliveryRequest.order.sellerPhone,
                  sellerPhoto:
                      "https://cdn.pixabay.com/photo/2015/03/04/22/35/head-659651_960_720.png",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AcceptedOrderPanel extends StatelessWidget {
  final TimeOfDay deliveryAt;
  final int stage = 0;

  final String clientName;
  final String? sellerName;

  final LatLng? sellerLocation;
  final LatLng clientLocation;

  final VoidCallback? handOver;

  final String clientPhone;
  final String? sellerPhone;

  final String clientPhoto;
  final String? sellerPhoto;

  const AcceptedOrderPanel({
    super.key,
    required this.deliveryAt,
    required this.clientName,
    this.sellerName,
    this.sellerPhone,
    this.sellerPhoto,
    required this.clientLocation,
    this.sellerLocation,
    this.handOver,
    required this.clientPhone,
    required this.clientPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20).copyWith(
        bottom: 0,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          "Estimated delivey time at ${deliveryAt.format(context)}",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          sellerName != null
              ? "Seller and the Client are waiting for you"
              : "Your order is already on its way to you!",
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
        Divider(
          color: Colors.white54,
        ),
        SizedBox(
          height: 12,
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: List.generate(
        //     3,
        //     (index) => Icon(
        //       Icons.shopping_bag_rounded,
        //       color: Colors.green,
        //     ),
        //   ),
        // ),
        // SizedBox(
        //   height: 12,
        // ),
        ListTile(
          textColor: Colors.white,
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              clientPhoto,
            ),
          ),
          title: Text(
            clientName,
          ),
          subtitle: Text(
            "Client",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white70,
                child: IconButton(
                  onPressed: () {
                    // go to google map with the client location and start the navigation, use clientLocation
                    AndroidIntent(
                      action: 'action_view',
                      data:
                          'geo:${clientLocation.latitude},${clientLocation.longitude}',
                    ).launch();
                  },
                  icon: Icon(
                    Icons.gps_fixed_outlined,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      AndroidIntent(
                        action: 'android.intent.action.DIAL',
                        data: 'tel:${clientPhone}',
                      ).launch();
                    },
                    icon: Icon(
                      Icons.phone,
                      color: Colors.blueGrey.shade900,
                    ),
                  )),
            ],
          ),
          style: ListTileStyle.drawer,
        ),

        if (handOver != null)
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: handOver,
                  icon: Icon(Icons.download_done_outlined),
                  label: Text("hand over"),
                ),
              ),
            ],
          ),

        if (sellerName != null && handOver == null)
          ListTile(
            textColor: Colors.white,
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                sellerPhoto!,
              ),
            ),
            title: Text(
              sellerName!,
            ),
            subtitle: Text(
              "Seller",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white70,
                  child: IconButton(
                    onPressed: () {
                      AndroidIntent(
                        action: 'action_view',
                        data:
                            'geo:${sellerLocation!.latitude},${sellerLocation!.longitude}',
                      ).launch();
                    },
                    icon: Icon(
                      Icons.gps_fixed_outlined,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        AndroidIntent(
                          action: 'android.intent.action.DIAL',
                          data: 'tel:${sellerPhone}',
                        ).launch();
                      },
                      icon: Icon(
                        Icons.phone,
                        color: Colors.blueGrey.shade900,
                      ),
                    )),
              ],
            ),
            style: ListTileStyle.drawer,
          ),
      ]),
    );
  }
}
