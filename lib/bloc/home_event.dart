part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class ChangeAppThemeEvent extends HomeEvent {
  final ThemeMode themeMode;

  ChangeAppThemeEvent(this.themeMode);
}

class GoogleMapCreatedEvent extends HomeEvent {
  final GoogleMapController mapController;

  GoogleMapCreatedEvent(this.mapController);
}

class SetSensorIntervalEvent extends HomeEvent {
  final int interval;

  SetSensorIntervalEvent(this.interval);
}

class ThresholdChangedEvent extends HomeEvent {
  final int threshold;

  ThresholdChangedEvent(this.threshold);
}

class MinimumSpeedChangedEvent extends HomeEvent {
  final int speed;

  MinimumSpeedChangedEvent(this.speed);
}