import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class IConnecitivity {
  Future<bool> isConnected();

  void subscibeToConnectivityChanges(Function(bool) callback);
  void dispose();
}

class ConnectivityRepository implements IConnecitivity {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  Future<bool> isConnected() async {
    return true;
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  void subscibeToConnectivityChanges(Function(bool) callback) {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      callback(result != ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
