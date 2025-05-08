import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/equatable.dart';

part 'get_routes_request_model.g.dart';

@JsonSerializable()
class GetRoutesRequestModel extends Equatable {
  @JsonKey(ignore: true)
  LatLng? fromLocation;

  @JsonKey(name: 'origin')
  String origin;

  @JsonKey(ignore: true)
  LatLng? toLocation;

  @JsonKey(name: 'destination')
  String destination;

  @JsonKey(name: 'mode', includeIfNull: false)
  final String mode;

  GetRoutesRequestModel({
    this.fromLocation,
    required this.origin,
    this.toLocation,
    required this.destination,
    this.mode = 'driving',
  }) : super([origin, destination, mode]) {
    // Si origin vide et fromLocation défini, génère origin
    if (origin.isEmpty && fromLocation != null) {
      origin = '${fromLocation!.latitude},${fromLocation!.longitude}';
    }
    // Si fromLocation non défini mais origin présent, parse LatLng
    else if (fromLocation == null && origin.contains(',')) {
      final parts = origin.split(',');
      if (parts.length == 2) {
        fromLocation = LatLng(
          double.parse(parts[0]),
          double.parse(parts[1]),
        );
      }
    }

    // Même logique pour destination ↔ toLocation
    if (destination.isEmpty && toLocation != null) {
      destination = '${toLocation!.latitude},${toLocation!.longitude}';
    } else if (toLocation == null && destination.contains(',')) {
      final parts = destination.split(',');
      if (parts.length == 2) {
        toLocation = LatLng(
          double.parse(parts[0]),
          double.parse(parts[1]),
        );
      }
    }
  }

  factory GetRoutesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GetRoutesRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetRoutesRequestModelToJson(this);
}
