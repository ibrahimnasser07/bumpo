import 'dart:async';

import 'package:bumpo/data/models/bump.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../utils/constants.dart';

class SettingsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Bump> saveBump(Bump bump) async {
    final bumpRef =
        await _firestore.collection(bumpsCollection).add(bump.toJson());
    await bumpRef.set({'id': bumpRef.id}, SetOptions(merge: true));
    final bumpJson = (await bumpRef.get()).data();
    return Bump.fromJson(bumpJson!);
  }

  Future<List<Bump>> fetchBumps() async {
    final querySnapshot = await _firestore.collection(bumpsCollection).get();
    final List<Bump> bumps = querySnapshot.docs
        .map((doc) => Bump.fromJson(doc.data()))
        .toList();
    return bumps;
  }

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
