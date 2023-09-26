import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GpsRepository {
  static Future<Offset?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition().then((value) {
        return Offset(value.longitude, value.latitude);
      });
    } catch (e) {
      return await Geolocator.getLastKnownPosition().then((value) {
        if (value != null) return Offset(value.longitude, value.latitude);
      });
    }
  }

  void subscibeToPositionChanges(Function(Offset) callback) {}

  static Future<bool> isPermitted() async {
    final permssion = await Geolocator.checkPermission();
    return permssion == LocationPermission.always ||
        permssion == LocationPermission.whileInUse;
  }

  static Future<bool> isBlocked() async {
    final permssion = await Geolocator.checkPermission();
    return permssion ==
        LocationPermission
            .deniedForever; // || permssion == LocationPermission.denied  ;
  }

  static Future<bool> requestPermission() async {
    final permssion = await Geolocator.requestPermission();
    return permssion == LocationPermission.always ||
        permssion == LocationPermission.whileInUse;
  }

  static Future<LatLng?> getLocation(BuildContext? context) async {
    var allowed = await isPermitted();
    var blocked = await isBlocked();

    if (context != null && blocked) {
      await showDialog(context: context, builder: (ctx) => GPSSettingPopup());
      allowed = await isPermitted();
      blocked = await isBlocked();
    } else if (context != null && !allowed) {
      await showDialog(context: context, builder: (ctx) => AllowGPSPopup());
    }

    var refusedToUseLocation =
        blocked || !allowed && !await requestPermission();

    if (refusedToUseLocation) {
      return null;
    } else {
      final coords = await getCurrentPosition();
      if (coords == null) return null;
      return LatLng(coords.dy, coords.dx);
    }
  }
}

class AllowGPSPopup extends StatefulWidget {
  const AllowGPSPopup({super.key});

  @override
  State<AllowGPSPopup> createState() => _AllowGPSPopupState();
}

class _AllowGPSPopupState extends State<AllowGPSPopup> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      insetPadding: EdgeInsets.all(16),
      title: Text(
        AppLocalizations.of(context)!.home_gps_confirm_title,
        style: TextStyle(
          fontSize: 21,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            AppLocalizations.of(context)!.home_gps_confirm_description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.home_gps_confirm_action,
                style: TextStyle(
                  fontSize: 16,
                )),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class GPSSettingPopup extends StatefulWidget {
  const GPSSettingPopup({super.key});

  @override
  State<GPSSettingPopup> createState() => _GPSSettingPopupState();
}

// todo subscribe to the app Settings
class _GPSSettingPopupState extends State<GPSSettingPopup>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (await GpsRepository.isPermitted()) {
        Navigator.of(context).pop();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      insetPadding: EdgeInsets.all(16),
      title: Text(
        'We Need Your Permission to use your Location',
        style: TextStyle(
          fontSize: 21,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'To see stores around you, please turn on location access or choose a location',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              await Geolocator.openAppSettings();
            },
            child: Text("Settings",
                style: TextStyle(
                  fontSize: 16,
                )),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel",
                style: TextStyle(fontSize: 16, color: Colors.black)),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
