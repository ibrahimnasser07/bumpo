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
