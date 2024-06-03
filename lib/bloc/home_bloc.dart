import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/repo/settings_repo.dart';
import '../utils/common_functions.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SettingsRepo _repo;

  HomeBloc(this._repo) : super(AppThemeState(getCurrentThemeMode())) {
    on<ChangeAppThemeEvent>(_changeAppTheme);
    on<GoogleMapCreatedEvent>(_googleMapCreated);
    on<SetSensorIntervalEvent>(_intervalChanged);
    on<ThresholdChangedEvent>(_thresholdChanged);
    on<MinimumSpeedChangedEvent>(_minSpeedChanged);
    _initControllers();
  }

  final intervalController = TextEditingController();
  final thresholdController = TextEditingController();
  final minSpeedController = TextEditingController();

  void _initControllers() {
    intervalController.text = _repo.getCurrentInterval().toString();
    thresholdController.text = _repo.getCurrentThreshold().toString();
    minSpeedController.text = _repo.getMinimumSpeed().toString();
    intervalController.addListener(
      () {
        if (intervalController.text.isNotEmpty) {
          add(SetSensorIntervalEvent(int.parse(intervalController.text)));
        }
      },
    );
    thresholdController.addListener(
      () {
        if (thresholdController.text.isNotEmpty) {
          add(ThresholdChangedEvent(int.parse(thresholdController.text)));
        }
      },
    );
    minSpeedController.addListener(
      () {
        if (minSpeedController.text.isNotEmpty) {
          add(MinimumSpeedChangedEvent(int.parse(minSpeedController.text)));
        }
      },
    );
  }

  late GoogleMapController _mapController;
  double _lastZ = 0.0;
  bool isDetecting = false;

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
    await Future.delayed(const Duration(seconds: 2));
    emit(GoogleMapCreatedSuccess());
    add(SetSensorIntervalEvent(_repo.getCurrentInterval()));
  }

  Future<void> _intervalChanged(
    SetSensorIntervalEvent event,
    Emitter<HomeState> emit,
  ) async {
    _repo.saveCurrentInterval(event.interval);
    userAccelerometerEventStream(
      samplingPeriod: Duration(milliseconds: event.interval),
    ).listen(
      (UserAccelerometerEvent event) {
        _detectBump(event);
      },
      onError: (e) => debugPrint("This is an error $e"),
      cancelOnError: true,
    );
    emit(SensorIntervalSetSuccess());
  }

  Future<void> _thresholdChanged(
    ThresholdChangedEvent event,
    Emitter<HomeState> emit,
  ) async {
    _repo.saveCurrentThreshold(event.threshold);
    emit(ThresholdSetSuccess());
  }

  Future<void> _minSpeedChanged(
    MinimumSpeedChangedEvent event,
    Emitter<HomeState> emit,
  ) async {
    _repo.saveMinimumSpeed(event.speed);
    emit(MinSpeedSetSuccess());
  }

  void _detectBump(UserAccelerometerEvent event) async {
    if (isDetecting) return;

    isDetecting = true;

    try {
      double z = event.z;
      double deltaZ = (z - _lastZ).abs();

      if (deltaZ > _repo.getCurrentThreshold()) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (position.speed >= (_repo.getMinimumSpeed() * (5 / 18))) {
          print("deltaZ: $deltaZ - speed: ${position.speed}");
        }
      }

      _lastZ = z;
    } finally {
      isDetecting = false;
    }
  }
}
