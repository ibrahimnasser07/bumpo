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

final class GoogleMapCreatedSuccess extends HomeState {}

final class SensorIntervalSetSuccess extends HomeState {}

final class ThresholdSetSuccess extends HomeState {}

final class MinSpeedSetSuccess extends HomeState {}

