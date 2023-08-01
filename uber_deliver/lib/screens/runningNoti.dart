import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber_deliver/cubits/app_cubit.dart';
import 'package:uber_deliver/cubits/service_cubit.dart';
import 'package:uber_deliver/repository/server.dart';

import '../models/delivery_man.dart';
import '../models/delivery_request.dart';
import '../repository/cache.dart';

class RunningNotiScreen extends StatefulWidget {
  final DeliveryRequest deliveryRequest;

  static go(DeliveryRequest deliveryRequest) => MaterialPageRoute(
        builder: (ctx) => RunningNotiScreen(deliveryRequest: deliveryRequest),
      );

  RunningNotiScreen({
    Key? key,
    required this.deliveryRequest,
  }) : super(key: key);

  @override
  State<RunningNotiScreen> createState() => _RunningNotiScreenState();
}

class _RunningNotiScreenState extends State<RunningNotiScreen> {
  final MapController _mapController = MapController();

  Function()? tobeDisposed;

  List<LatLng> get directionPoints => [
        ...widget.deliveryRequest.toSeller.points,
        ...widget.deliveryRequest.toClient.points
      ];

  @override
  void initState() {
    super.initState();

    Server().listenToOrder(widget.deliveryRequest.order.id, (updates) {
      if (updates.deliveryManID != null) {
        tobeDisposed?.call();
        exit();
      }
    }).then((stop) => tobeDisposed = stop);
  }

  void accept() async {
    tobeDisposed?.call();
    final deliveryMan = context.read<AppCubit>().state.deliveryMan!;
    // todo consider moving this to the cubit!
    await Server().setDeliver(
      deliveryMan,
      widget.deliveryRequest.order,
      Cache.availabilityLocation!, // dangerous
    );

    context.read<ServiceCubit>().startDelivery(widget.deliveryRequest);

    exit();
  }

  void exit() {
    context.read<ServiceCubit>().unselectRequest();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    tobeDisposed?.call();
    super.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        context.read<ServiceCubit>().unselectRequest();
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                onMapReady: initMap,
                rotation: 0,
                enableMultiFingerGestureRace: false,
                interactiveFlags: InteractiveFlag.none,
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
                  ],
                )
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
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 600),
                  switchInCurve: Curves.easeInOutExpo,
                  switchOutCurve: Curves.easeInOutExpo,
                  child: DeliveryRequestPanel(
                    accept: accept,
                    deliveryFromDistance:
                        (widget.deliveryRequest.toSeller.distance / 1000)
                            .round(),
                    deliveryFromDuration:
                        widget.deliveryRequest.toSeller.duration.inMinutes,
                    deliveryToDistance:
                        (widget.deliveryRequest.toClient.distance / 1000)
                            .round(),
                    deliveryToDuration:
                        widget.deliveryRequest.toClient.duration.inMinutes,
                    deliveryPrice: distanceToPrice(
                          widget.deliveryRequest.toClient.distance / 1000,
                        ) +
                        0.0,
                    totalPrice: distanceToPrice(
                          widget.deliveryRequest.toClient.distance / 1000,
                        ) +
                        double.parse(widget.deliveryRequest.order.bagPrice),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

class DeliveryRequestPanel extends StatelessWidget {
  final int deliveryFromDuration;
  final int deliveryFromDistance;

  final int deliveryToDuration;
  final int deliveryToDistance;

  final double deliveryPrice;

  final double totalPrice;

  final VoidCallback accept;

  const DeliveryRequestPanel({
    super.key,
    required this.deliveryFromDuration,
    required this.deliveryFromDistance,
    required this.deliveryToDuration,
    required this.deliveryToDistance,
    required this.deliveryPrice,
    required this.totalPrice,
    required this.accept,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Hero(
        tag: "availability",
        child: Container(
          margin: const EdgeInsets.all(20).copyWith(
            bottom: 0,
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                textColor: Colors.white70,
                title: Text("Deliver from"),
                trailing: Text(
                    "${deliveryFromDistance} km ${deliveryFromDuration} min"),
                style: ListTileStyle.drawer,
                visualDensity: VisualDensity.compact,
              ),
              ListTile(
                textColor: Colors.white70,
                title: Text("Deliver to"),
                trailing:
                    Text("${deliveryToDistance} km ${deliveryToDuration} min"),
                style: ListTileStyle.drawer,
                visualDensity: VisualDensity.compact,
              ),
              ListTile(
                textColor: Colors.white70,
                title: Text("Deliver Price"),
                trailing: Text("\$${deliveryPrice}"),
                style: ListTileStyle.drawer,
                visualDensity: VisualDensity.compact,
              ),
              Divider(
                color: Colors.white54,
              ),
              ListTile(
                textColor: Colors.white,
                style: ListTileStyle.drawer,
                title: Text("Total"),
                trailing: Text("\$${totalPrice}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: accept,
                      child: Text(
                        "Accept",
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

int distanceToPrice(double distance) {
  if (distance < 1)
    return 10;
  else if (distance < 5)
    return 20;
  else if (distance < 10)
    return 30;
  else if (distance < 15)
    return 40;
  else if (distance < 20)
    return 50;
  else if (distance < 25)
    return 60;
  else if (distance < 30)
    return 70;
  else if (distance < 35)
    return 80;
  else if (distance < 40)
    return 90;
  else
    return 100;
}
