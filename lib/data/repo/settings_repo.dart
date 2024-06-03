import 'package:hive/hive.dart';

import '../../utils/constants.dart';

class SettingsRepo {
  int getCurrentInterval() {
    return Hive.box(settingsBox).get(currentInterval) ?? 15;
  }

  Future<void> saveCurrentInterval(int interval) async {
    await Hive.box(settingsBox).put(currentInterval, interval);
  }

  int getCurrentThreshold() {
    return Hive.box(settingsBox).get(currentThreshold) ?? 20;
  }

  Future<void> saveCurrentThreshold(int threshold) async {
    await Hive.box(settingsBox).put(currentThreshold, threshold);
  }

  int getMinimumSpeed() {
    return Hive.box(settingsBox).get(minimumSpeed) ?? 10;
  }

  Future<void> saveMinimumSpeed(int speed) async {
    await Hive.box(settingsBox).put(minimumSpeed, speed);
  }
}
