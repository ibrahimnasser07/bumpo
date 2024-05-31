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