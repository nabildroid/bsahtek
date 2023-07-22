import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber_client/cubits/app_cubit.dart';
import 'package:uber_client/cubits/home_cubit.dart';
import 'package:uber_client/repositories/direction.dart';

import '../models/order.dart';
import '../models/tracking.dart';
import '../repositories/server.dart';

class RunningScreen extends StatefulWidget {
  final Order order;

  RunningScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  final MapController _mapController = MapController();

  Tracking? tracking;

  VoidCallback? tobeDisposed;

  List<LatLng> toClient = [];
  List<LatLng> toSeller = [];

  @override
  void dispose() {
    tobeDisposed?.call();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    tobeDisposed = Server().listenToTrack(widget.order, (tracking) {
      if (tracking.toClient) {
        exit();
      } else {
        updateTracking(tracking);
      }
    });
  }

  void updateTracking(Tracking tracking) async {
    final directions = await Future.wait([
      DirectionRepository.direction(
        LatLng(tracking.deliverLocation.latitude,
            tracking.deliverLocation.longitude),
        LatLng(tracking.sellerLocation.latitude,
            tracking.sellerLocation.longitude),
      ),
      DirectionRepository.direction(
        LatLng(tracking.sellerLocation.latitude,
            tracking.sellerLocation.longitude),
        LatLng(tracking.clientLocation.latitude,
            tracking.clientLocation.longitude),
      )
    ]);
    if (!mounted) return;

    setState(() {
      this.tracking = tracking;
      toSeller = directions[0].points;
      toClient = directions[1].points;
      initMap();
    });
  }

  void initMap() {
    final points = [...toClient, ...toSeller];
    if (points.isEmpty) return;
    final zoom = _mapController.centerZoomFitBounds(
      LatLngBounds.fromPoints(points),
      options: FitBoundsOptions(
        padding: EdgeInsets.symmetric(horizontal: 20).copyWith(
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
  }

  void exit() {
    context.read<HomeCubit>().unFocusOnRunning();
    Navigator.of(context).pop();
  }

  void stop() {
    exit();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<HomeCubit>().unFocusOnRunning();
        return true;
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
                      points: [...toSeller, ...toClient],
                      strokeWidth: 4,
                      color: Colors.blueGrey.shade900,
                    ),
                  ],
                ),
                CircleLayer(
                  circles: [
                    if (toClient.isNotEmpty)
                      CircleMarker(
                        point: toClient.last,
                        color: Colors.green.shade400,
                        borderColor: Colors.blueGrey.shade900,
                        borderStrokeWidth: 4,
                        radius: 8,
                      ),
                    if (toSeller.isNotEmpty)
                      CircleMarker(
                        point: toSeller.first,
                        color: Colors.green.shade400,
                        borderColor: Colors.blueGrey.shade900,
                        borderStrokeWidth: 4,
                        radius: 8,
                      ),
                    if (toSeller.isNotEmpty)
                      CircleMarker(
                        point: toSeller.last,
                        color: Colors.green.shade200,
                        borderColor: Colors.blueGrey.shade900,
                        borderStrokeWidth: 2,
                        radius: 6,
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
                onPressed: () {
                  exit();
                },
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
                onPressed: () {
                  exit();
                },
                icon: Icon(Icons.stop),
                label: Text("Stop (test)"),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Hero(
                tag: "running",
                child: AcceptedOrderPanel(
                  deliveryAt: TimeOfDay.now(),
                  deliverName: widget.order.deliveryName!,
                  deliverPhone: widget.order.deliveryPhone!,
                  clientPhoto:
                      "https://cdn.pixabay.com/photo/2015/03/04/22/35/head-659651_960_720.png",
                  sellerName: "seller Name",
                  sellerPhone: "+213 555 555 555",
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

  final String deliverName;
  final String? sellerName;

  final String deliverPhone;
  final String? sellerPhone;

  final String clientPhoto;
  final String? sellerPhoto;

  const AcceptedOrderPanel({
    super.key,
    required this.deliveryAt,
    required this.deliverName,
    this.sellerName,
    this.sellerPhone,
    this.sellerPhoto,
    required this.deliverPhone,
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
          "Your order is already on its way to you!",
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (index) => Icon(
              Icons.shopping_bag_rounded,
              color: Colors.green,
            ),
          ),
        ),
        SizedBox(
          height: 12,
        ),
        ListTile(
          textColor: Colors.white,
          leading: CircleAvatar(
            radius: 20,
            child: Icon(Icons.delivery_dining),
          ),
          title: Text(
            deliverName,
          ),
          subtitle: Text(
            "Deliver",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.phone,
                      color: Colors.blueGrey.shade900,
                    ),
                  )),
            ],
          ),
          style: ListTileStyle.drawer,
        ),
        if (sellerName != null)
          ListTile(
            textColor: Colors.white,
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                "https://cdn.pixabay.com/photo/2015/03/04/22/35/head-659651_960_720.png",
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
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {},
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
