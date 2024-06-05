import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/models/bump.dart';
import '../data/repo/settings_repo.dart';
import '../utils/common_functions.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SettingsRepo _repo;

  HomeBloc(this._repo) : super(AppThemeState(getCurrentThemeMode())) {
    _initControllers();
    on<ChangeAppThemeEvent>(_changeAppTheme);
    on<GoogleMapCreatedEvent>(_googleMapCreated);
    on<SetSensorIntervalEvent>(_intervalChanged);
    on<ThresholdChangedEvent>(_thresholdChanged);
    // on<MinimumSpeedChangedEvent>(_minSpeedChanged);
    on<AddBumpToFirebaseEvent>(_addBumpToFirebase);
    on<StartLocationUpdates>(_onStartLocationUpdates);
    on<CheckProximity>(_onCheckProximity);
    on<CheckLocationPermission>(_onCheckLocationPermission);
  }

  late GoogleMapController _mapController;
  double _lastZ = 0.0;
  bool _isDetecting = false;
  final intervalController = TextEditingController();
  final thresholdController = TextEditingController();

  // final minSpeedController = TextEditingController();
  StreamSubscription<Position>? _positionStreamSubscription;
  final Set<String> _activeMarkers = <String>{};
  Set<Marker> markers = {};

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
    await _fetchMarkers();
    emit(MarkersFetchedSuccessfully());
    add(SetSensorIntervalEvent(_repo.getCurrentInterval()));
    add(StartLocationUpdates());
  }

  void _onStartLocationUpdates(
      StartLocationUpdates event, Emitter<HomeState> emit) {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      add(CheckProximity(position));
    });
  }

  void _onCheckProximity(CheckProximity event, Emitter<HomeState> emit) async {
    final position = event.position;
    Set<String> currentProximityMarkers = <String>{};

    for (var marker in markers) {
      double distance = _calculateDistance(
        position.latitude,
        position.longitude,
        marker.position.latitude,
        marker.position.longitude,
      );

      if (distance <= 20) {
        currentProximityMarkers.add(marker.markerId.value);
        if (!_activeMarkers.contains(marker.markerId.value)) {
          emit(LocationIsWithinRange());
        } else {
          debugPrint(
            'Marker ${marker.markerId.value} is already in active markers.',
          );
        }
      }
    }

    _activeMarkers
      ..clear()
      ..addAll(currentProximityMarkers);

    emit(LocationUpdateSuccess(position));
  }

  Future<void> _intervalChanged(
    SetSensorIntervalEvent event,
    Emitter<HomeState> emit,
  ) async {
    _repo.saveCurrentInterval(event.interval);
    userAccelerometerEventStream(
      samplingPeriod: Duration(milliseconds: event.interval),
    ).listen(
      (UserAccelerometerEvent event) => _detectBump(event),
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

  Future<void> _addBumpToFirebase(
    AddBumpToFirebaseEvent event,
    Emitter<HomeState> emit,
  ) async {
    final savedBump = await _repo.saveBump(
      Bump(
        lat: event.position.latitude,
        lng: event.position.longitude,
      ),
    );
    markers.add(await _convertBumpToMarker(savedBump));
    _activeMarkers.add(savedBump.id!);
    emit(BumpSavedSuccessfully());
  }

  // Future<void> _minSpeedChanged(
  //   MinimumSpeedChangedEvent event,
  //   Emitter<HomeState> emit,
  // ) async {
  //   _repo.saveMinimumSpeed(event.speed);
  //   emit(MinSpeedSetSuccess());
  // }

  void _detectBump(UserAccelerometerEvent event) async {
    if (_isDetecting) return;

    _isDetecting = true;

    try {
      double z = event.z;
      double deltaZ = (z - _lastZ).abs();

      if (deltaZ > _repo.getCurrentThreshold()) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        bool isWithinRadius = markers.any((marker) {
          double distance = _calculateDistance(
            position.latitude,
            position.longitude,
            marker.position.latitude,
            marker.position.longitude,
          );
          return distance <= 5;
        });

        if (!isWithinRadius) {
          add(
            AddBumpToFirebaseEvent(
              LatLng(position.latitude, position.longitude),
            ),
          );
        }
      }

      _lastZ = z;
    } finally {
      _isDetecting = false;
    }
  }

  void _initControllers() {
    intervalController.text = _repo.getCurrentInterval().toString();
    thresholdController.text = _repo.getCurrentThreshold().toString();
    // minSpeedController.text = _repo.getMinimumSpeed().toString();
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
    // minSpeedController.addListener(
    //   () {
    //     if (minSpeedController.text.isNotEmpty) {
    //       add(MinimumSpeedChangedEvent(int.parse(minSpeedController.text)));
    //     }
    //   },
    // );
  }

  Future<void> _fetchMarkers() async {
    final bumps = await _repo.fetchBumps();
    for (Bump bump in bumps) {
      markers.add(await _convertBumpToMarker(bump));
    }
  }

  Future<Marker> _convertBumpToMarker(Bump bump) async {
    // final BitmapDescriptor bitmapDescriptor =
    //     await BitmapDescriptor.fromAssetImage(
    //   const ImageConfiguration(devicePixelRatio: 2.0, size: Size(24, 24)),
    //   "lib/images/bumpo_logo.png",
    // );

    return Marker(
        markerId: MarkerId(bump.id!), position: LatLng(bump.lat, bump.lng));
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // const double R = 6371000; // Earth radius in meters
    // final double dLat = (lat2 - lat1) * (math.pi / 180.0);
    // final double dLon = (lon2 - lon1) * (math.pi / 180.0);
    //
    // final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
    //     math.cos(lat1 * (math.pi / 180.0)) *
    //         math.cos(lat2 * (math.pi / 180.0)) *
    //         math.sin(dLon / 2) *
    //         math.sin(dLon / 2);
    //
    // final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    // return R * c; // Distance in meters
  }

  void _onCheckLocationPermission(
      CheckLocationPermission event, Emitter<HomeState> emit) async {
    emit(PermissionCheckInProgress());

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(LocationPermissionDenied("Location services are disabled."));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(LocationPermissionDenied("Location permissions are denied."));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(LocationPermissionDenied(
          "Location permissions are permanently denied."));
      return;
    }

    emit(LocationPermissionGranted());
  }

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}
