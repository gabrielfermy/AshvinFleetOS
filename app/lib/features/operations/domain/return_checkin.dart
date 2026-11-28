import 'inspection_point.dart';

/// Vehicle check-in return record completed upon return handover
class ReturnCheckin {
  final String id;
  final String bookingItemId;
  final String vehicleId;
  final String staffId;
  final int checkinOdometerKm;
  final int checkinFuelLevel; // Scale 1 to 8
  final int distanceTraveledKm;
  final double overtimeHours;
  final double overtimePenaltyFee;
  final double fuelPenaltyFee;
  final double damagePenaltyFee;
  final List<InspectionPoint> bodyInspection;
  final List<String> photos;
  final String customerSignatureUrl;
  final String staffSignatureUrl;
  final DateTime checkinTimestamp;

  const ReturnCheckin({
    required this.id,
    required this.bookingItemId,
    required this.vehicleId,
    required this.staffId,
    required this.checkinOdometerKm,
    required this.checkinFuelLevel,
    required this.distanceTraveledKm,
    required this.overtimeHours,
    required this.overtimePenaltyFee,
    required this.fuelPenaltyFee,
    required this.damagePenaltyFee,
    required this.bodyInspection,
    required this.photos,
    required this.customerSignatureUrl,
    required this.staffSignatureUrl,
    required this.checkinTimestamp,
  });

  double get totalPenalty => overtimePenaltyFee + fuelPenaltyFee + damagePenaltyFee;

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_item_id': bookingItemId,
        'vehicle_id': vehicleId,
        'staff_id': staffId,
        'checkin_odometer_km': checkinOdometerKm,
        'checkin_fuel_level': checkinFuelLevel,
        'distance_traveled_km': distanceTraveledKm,
        'overtime_hours': overtimeHours,
        'overtime_penalty_fee': overtimePenaltyFee,
        'fuel_penalty_fee': fuelPenaltyFee,
        'damage_penalty_fee': damagePenaltyFee,
        'body_inspection_json': bodyInspection.map((e) => e.toJson()).toList(),
        'photos_json': photos,
        'customer_signature_url': customerSignatureUrl,
        'staff_signature_url': staffSignatureUrl,
        'checkin_timestamp': checkinTimestamp.toIso8601String(),
      };

  factory ReturnCheckin.fromJson(Map<String, dynamic> json) {
    final rawInspection = json['body_inspection_json'];
    final inspectionList = (rawInspection is List)
        ? rawInspection.map((e) => InspectionPoint.fromJson(e as Map<String, dynamic>)).toList()
        : InspectionPoint.createDefaultChecklist();

    final rawPhotos = json['photos_json'];
    final photosList = (rawPhotos is List) ? List<String>.from(rawPhotos) : <String>[];

    return ReturnCheckin(
      id: json['id'] as String? ?? '',
      bookingItemId: json['booking_item_id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      staffId: json['staff_id'] as String? ?? '',
      checkinOdometerKm: json['checkin_odometer_km'] as int? ?? 0,
      checkinFuelLevel: json['checkin_fuel_level'] as int? ?? 8,
      distanceTraveledKm: json['distance_traveled_km'] as int? ?? 0,
      overtimeHours: (json['overtime_hours'] as num?)?.toDouble() ?? 0.0,
      overtimePenaltyFee: (json['overtime_penalty_fee'] as num?)?.toDouble() ?? 0.0,
      fuelPenaltyFee: (json['fuel_penalty_fee'] as num?)?.toDouble() ?? 0.0,
      damagePenaltyFee: (json['damage_penalty_fee'] as num?)?.toDouble() ?? 0.0,
      bodyInspection: inspectionList,
      photos: photosList,
      customerSignatureUrl: json['customer_signature_url'] as String? ?? '',
      staffSignatureUrl: json['staff_signature_url'] as String? ?? '',
      checkinTimestamp: DateTime.tryParse(json['checkin_timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
