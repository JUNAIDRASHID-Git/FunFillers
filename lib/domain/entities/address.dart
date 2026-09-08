import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String name;
  final String fullAddress;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final String label; // 'Home', 'Work', 'Other'
  final bool isDefault;
  final String country;
  final double latitude;
  final double longitude;
  final double altitude; // Elevation in meters

  const AddressEntity({
    required this.id,
    this.name = 'John Doe',
    required this.fullAddress,
    required this.city,
    this.state = 'Karnataka',
    this.pincode = '560001',
    this.phone = '+91 9876543210',
    String? title,
    this.label = 'Home',
    this.isDefault = false,
    this.country = 'India',
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.altitude = 920.0,
  });

  String get title => label.isNotEmpty ? label : name;

  @override
  List<Object?> get props => [
        id,
        name,
        fullAddress,
        city,
        state,
        pincode,
        phone,
        label,
        isDefault,
        country,
        latitude,
        longitude,
        altitude,
      ];
}

typedef Address = AddressEntity;
