import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/comman_functions.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(AppThemeState(getCurrentThemeMode())) {
    on<ChangeAppThemeEvent>(_changeAppTheme);
    on<GoogleMapCreatedEvent>(_googleMapCreated);
  }

  late GoogleMapController _mapController;

  void _changeAppTheme(
    ChangeAppThemeEvent event,
    Emitter<HomeState> emit,
  ) {
    saveCurrentThemeMode(event.themeMode);
    emit(AppThemeState(event.themeMode));
  }

  Future<void> _googleMapCreated(
    GoogleMapCreatedEvent event,
    Emitter<HomeState> emit,
  ) async {
    _mapController = event.mapController;
    final currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      _mapController.animateCamera(CameraUpdate.newLatLng(currentLocation));
    }
  }
}
