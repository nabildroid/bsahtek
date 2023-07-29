import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uber_client/cubits/home_cubit.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prevOrders = context.watch<HomeCubit>().state.prevOrders;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Your Orders",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: prevOrders.length,
                    itemBuilder: (context, index) {
                      final order = prevOrders[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(order.bagName),
                            Text(order.bagPrice.toString()),
                          ],
                        ),
                      );
                    }),
              ),
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
