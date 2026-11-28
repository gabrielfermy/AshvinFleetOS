/// Rental Package domain model mapped to rental_packages table
class RentalPackage {
  final String id;
  final String name;
  final String serviceType; // 'SELF_DRIVE', 'WITH_DRIVER'
  final String serviceArea; // 'IN_TOWN', 'OUT_OF_TOWN'
  final int durationHours;
  final double basePrice;
  final double depositAmount;
  final bool includesFuel;

  const RentalPackage({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.serviceArea,
    required this.durationHours,
    required this.basePrice,
    required this.depositAmount,
    required this.includesFuel,
  });

  factory RentalPackage.fromJson(Map<String, dynamic> json) {
    return RentalPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      serviceType: json['service_type'] as String,
      serviceArea: json['service_area'] as String,
      durationHours: json['duration_hours'] as int,
      basePrice: (json['base_price'] as num).toDouble(),
      depositAmount: (json['deposit_amount'] as num).toDouble(),
      includesFuel: json['includes_fuel'] as bool? ?? false,
    );
  }

  bool get isSelfDrive => serviceType == 'SELF_DRIVE';
  bool get isWithDriver => serviceType == 'WITH_DRIVER';
}
