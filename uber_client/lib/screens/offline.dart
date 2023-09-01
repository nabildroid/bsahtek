import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  VoidCallback? cancleConnectivityCecher;
  @override
  void initState() {
    super.initState();
    cancleConnectivityCecher =
        Connectivity().onConnectivityChanged.listen((event) {
      if (event != ConnectivityResult.none) {
        context.replace("/loading");
      }
    }).cancel;
  }

  @override
  void dispose() {
    cancleConnectivityCecher?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You are Offline"),
            Icon(
              Icons.wifi_off_outlined,
            )
          ],
        ),
      ),
    );
  }
}
