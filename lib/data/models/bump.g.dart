// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bump.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bump _$BumpFromJson(Map<String, dynamic> json) => Bump(
      id: json['id'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$BumpToJson(Bump instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['lat'] = instance.lat;
  val['lng'] = instance.lng;
  return val;
}
