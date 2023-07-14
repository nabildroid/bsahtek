import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uber_deliver/cubits/app_cubit.dart';
import 'package:uber_deliver/cubits/service_cubit.dart';
import 'package:uber_deliver/screens/runningNoti.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    context.read<AppCubit>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<ServiceCubit>();

    return BlocListener<ServiceCubit, ServiceState>(
      listenWhen: (o, n) => o.selectedRequest != n.selectedRequest,
      listener: (ctx, state) {
        if (state.selectedRequest == null) return;

        final selected = state.deliveryRequest
            .firstWhere((element) => element.order.id == state.selectedRequest);
        Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (ctx) => BlocProvider.value(
              value: service,
              child: RunningNotiScreen(
                deliveryRequest: selected,
              ),
            ),
          ),
        );
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text("Hello, Nabil",
                style: TextStyle(
                  color: Colors.black,
                )),
            actions: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://avatars.githubusercontent.com/u/19208222?v=4"),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<ServiceCubit, ServiceState>(
                        builder: (context, state) {
                      return Card(
                        id: "defzefze",
                        isAvailable: state.isAvailable,
                        onSwitch: () => service.toggleAvailability(context),
                      );
                    }),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Past Deliveries",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...List.generate(
                      10,
                      (index) => ListTile(
                        leading: Icon(
                          Icons.delivery_dining,
                          color: Colors.green,
                        ),
                        title: Text("Carfour"),
                        subtitle: Text("#565685"),
                        trailing: RichText(
                          text: TextSpan(
                            text: "2.5km ",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                            children: [
                              TextSpan(
                                text: " + \$15",
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.delivery_dining),
                label: "Deliveries",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Card extends StatelessWidget {
  final String id;
  final bool isAvailable;
  final VoidCallback onSwitch;
  const Card({
    required this.id,
    required this.isAvailable,
    required this.onSwitch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Material(
          color: Colors.transparent,
          child: Hero(
            tag: "availability",
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                // use gradient instead
                gradient: LinearGradient(
                  colors: [
                    Colors.blueGrey.shade900,
                    Colors.blueGrey.shade500,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomCenter,
                ),
                // color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "FOODGOOD",
                      children: [
                        TextSpan(
                          text: "#$id",
                          style: TextStyle(
                            color: Colors.blueGrey.shade300,
                          ),
                        )
                      ],
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "monospace",
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: Duration(seconds: 1),
                          child: isAvailable
                              ? Text(
                                  "Available for Delivery orders from Stores/Shops to Customers",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ))
                              : Text(
                                  "You are not available for delivery orders, so you won't receive any orders",
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Switch(
                          value: isAvailable,
                          onChanged: (_) {
                            onSwitch();
                          }),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
