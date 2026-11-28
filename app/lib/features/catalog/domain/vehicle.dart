/// Vehicle domain model mapped to vehicles table
class Vehicle {
  final String id;
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final String transmission; // 'MANUAL', 'AUTOMATIC'
  final int seatingCapacity;
  final int currentOdometerKm;
  final String status; // 'AVAILABLE', 'BOOKED', 'ON_RENTAL', 'MAINTENANCE_REQUIRED'
  final String? imageUrl;

  const Vehicle({
    required this.id,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.transmission,
    required this.seatingCapacity,
    required this.currentOdometerKm,
    required this.status,
    this.imageUrl,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      licensePlate: json['license_plate'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      transmission: json['transmission'] as String,
      seatingCapacity: json['seating_capacity'] as int,
      currentOdometerKm: json['current_odometer_km'] as int,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  bool get isAvailable => status == 'AVAILABLE';
  String get displayName => '$brand $model ($year)';
}
