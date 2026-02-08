// data/models/landpad.dart
import 'package:equatable/equatable.dart';

class Landpad extends Equatable {
  final String id;
  final String name;
  final String fullName;
  final String status;
  final String type;
  final String locality;
  final String region;
  final double? latitude;
  final double? longitude;
  final int landingAttempts;
  final int landingSuccesses;
  final String wikipedia;
  final String details;

  const Landpad({
    required this.id,
    required this.name,
    required this.fullName,
    required this.status,
    required this.type,
    required this.locality,
    required this.region,
    this.latitude,
    this.longitude,
    required this.landingAttempts,
    required this.landingSuccesses,
    required this.wikipedia,
    required this.details,
  });

  factory Landpad.fromJson(Map<String, dynamic> json) {
    return Landpad(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      fullName: json['full_name'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'unknown',
      type: json['type'] as String? ?? 'unknown',
      locality: json['locality'] as String? ?? 'Unknown',
      region: json['region'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      landingAttempts: json['landing_attempts'] as int? ?? 0,
      landingSuccesses: json['landing_successes'] as int? ?? 0,
      wikipedia: json['wikipedia'] as String? ?? '',
      details: json['details'] as String? ?? 'Нет описания',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'fullName': fullName,
    'status': status,
    'type': type,
    'locality': locality,
    'region': region,
    'latitude': latitude,
    'longitude': longitude,
    'landingAttempts': landingAttempts,
    'landingSuccesses': landingSuccesses,
    'wikipedia': wikipedia,
    'details': details,
  };

  @override
  List<Object?> get props => [id];
}