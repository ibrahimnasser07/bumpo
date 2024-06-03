import 'package:json_annotation/json_annotation.dart';

part 'bump.g.dart';

@JsonSerializable(includeIfNull: false)
class Bump {
  String? id;
  double lat;
  double lng;

  Bump({this.id, required this.lat, required this.lng});

  factory Bump.fromJson(Map<String, dynamic> json) => _$BumpFromJson(json);

  Map<String, dynamic> toJson() => _$BumpToJson(this);
}
