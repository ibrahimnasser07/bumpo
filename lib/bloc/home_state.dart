part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class AppThemeState extends HomeState {
  final ThemeMode themeMode;

  AppThemeState(this.themeMode);

  @override
  String toString() {
    return "AppThemeChanged($themeMode)";
  }
}

class LocationUpdateSuccess extends HomeState {
  final Position position;

  LocationUpdateSuccess(this.position);

  @override
  String toString() {
    return "LocationUpdateSuccess"
        "(lat: ${position.latitude} - lng: ${position.longitude})";
  }
}

final class MarkersFetchedSuccessfully extends HomeState {}

final class SensorIntervalSetSuccess extends HomeState {}

final class ThresholdSetSuccess extends HomeState {}

final class MinSpeedSetSuccess extends HomeState {}

final class BumpSavedSuccessfully extends HomeState {}

class LocationPermissionGranted extends HomeState {}

class LocationPermissionDenied extends HomeState {
  final String message;

  LocationPermissionDenied(this.message);

  @override
  String toString() {
    return "LocationPermissionDenied( $message )";
  }
}

class PermissionCheckInProgress extends HomeState {}
