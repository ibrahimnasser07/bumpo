import 'package:bumpo/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';

import 'geolocator.dart';

ThemeMode getCurrentThemeMode() {
  final currentMode = Hive.box(settingsBox).get(currentTheme) ?? "light";
  if (currentMode == "light") {
    return ThemeMode.light;
  }
  return ThemeMode.dark;
}

void saveCurrentThemeMode(ThemeMode themeMode) {
  final mode = themeMode == ThemeMode.dark ? "dark" : "light";
  Hive.box(settingsBox).put(currentTheme, mode);
}

Future<LatLng?> getCurrentLocation() async {
  final LocationManager appLocation = LocationManager.get();
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    // Request location permission if not granted
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position? position = await appLocation.determinePosition();
      if (position != null) {
        LatLng info = LatLng(position.latitude, position.longitude);
        return info;
      } else {
        return null;
      }
    } else {
      return null;
    }
  } catch (e) {
    debugPrint("Error occurred while getting location: $e");
    return null;
  }
}
