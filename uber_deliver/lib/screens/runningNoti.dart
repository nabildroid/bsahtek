import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber_deliver/cubits/service_cubit.dart';

import '../models/delivery_request.dart';
import '../repository/direction.dart';

class RunningNotiScreen extends StatefulWidget {
  final DeliveryRequest deliveryRequest;

  RunningNotiScreen({
    Key? key,
    required this.deliveryRequest,
  }) : super(key: key);

  @override
  State<RunningNotiScreen> createState() => _RunningNotiScreenState();
}

class _RunningNotiScreenState extends State<RunningNotiScreen> {
  final MapController _mapController = MapController();

  List<LatLng> get directionPoints => [
        ...widget.deliveryRequest.toSeller.points,
        ...widget.deliveryRequest.toClient.points
      ];

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
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
                urlTemplate: 'https://a.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
              onPressed: () {},
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
              child: true
                  ? DeliveryRequestPanel(
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
                      pricePerKM: 15,
                      totalPrice: 25,
                    )
                  : AcceptedOrderPanel(
                      deliveryAt: TimeOfDay.now(),
                      clientName: "John Doe",
                      clientPhone: "+213 555 555 555",
                      clientPhoto:
                          "https://cdn.pixabay.com/photo/2015/03/04/22/35/head-659651_960_720.png",
                      sellerName: "John Doe",
                      sellerPhone: "+213 555 555 555",
                      sellerPhoto:
                          "https://cdn.pixabay.com/photo/2015/03/04/22/35/head-659651_960_720.png",
                    ),
            ),
          )
        ],
      ),
    );
  }
}

class AcceptedOrderPanel extends StatelessWidget {
  final TimeOfDay deliveryAt;
  final int stage = 0;

  final String clientName;
  final String? sellerName;

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
                  onPressed: () {},
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
                    onPressed: () {},
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

class DeliveryRequestPanel extends StatelessWidget {
  final int deliveryFromDuration;
  final int deliveryFromDistance;

  final int deliveryToDuration;
  final int deliveryToDistance;

  final int pricePerKM;

  final int totalPrice;

  const DeliveryRequestPanel({
    super.key,
    required this.deliveryFromDuration,
    required this.deliveryFromDistance,
    required this.deliveryToDuration,
    required this.deliveryToDistance,
    required this.pricePerKM,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        context.read<ServiceCubit>().unselectRequest();
        return Future.value(true);
      },
      child: Material(
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
                  trailing: Text(
                      "${deliveryToDistance} km ${deliveryToDuration} min"),
                  style: ListTileStyle.drawer,
                  visualDensity: VisualDensity.compact,
                ),
                ListTile(
                  textColor: Colors.white70,
                  title: Text("Deliver Pricing"),
                  trailing: Text("\$${pricePerKM} / km"),
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
                        onPressed: () {},
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
      ),
    );
  }
}
