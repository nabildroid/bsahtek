import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uber_client/cubits/app_cubit.dart';
import 'package:uber_client/cubits/home_cubit.dart';

import '../../repositories/cache.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Cache.lastUpdatePrevOrders;

    final prevOrders = context.watch<HomeCubit>().state.prevOrders;
    prevOrders.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));

    final app = context.read<AppCubit>().state;

    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            "Your Orders",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(app.client!.photo),
            ),
            SizedBox(width: 10),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.green.shade300.withOpacity(.8),
                padding: EdgeInsets.only(top: 80, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: prevOrders.length,
                        itemBuilder: (BuildContext context, int index) {
                          final order = prevOrders[index];
                          return Container(
                              width: MediaQuery.of(context).size.width * .7,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.95),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        order.createdAt
                                            .toString()
                                            .split(" ")[0],
                                      ),
                                      Opacity(
                                          opacity: .6,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(200),
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                      Colors.green.shade600
                                                          .withOpacity(.3),
                                                      BlendMode.srcOver),
                                                  child: CircleAvatar(
                                                    radius: 10,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      order.bagImage,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 7),
                                              Text(order.sellerName ??
                                                  order.bagName)
                                            ],
                                          ))
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 26,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "\$${order.bagPrice}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " ×${order.quantity}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "#${order.id.substring(0, 7)}",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontFamily: "monospace",
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        order.expired
                                            ? "EXPIRED"
                                            : order.inProgress
                                                ? "IN PROGRESS"
                                                : order.isPickup
                                                    ? "PICKUP"
                                                    : "DELIVERED",
                                        style: TextStyle(
                                          color: order.expired
                                              ? Colors.red.shade600
                                              : order.inProgress
                                                  ? Colors.green.shade800
                                                  : Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text(" Settings"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => context.push("/me/settings"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
