import 'inspection_point.dart';

/// Handover check-out record completed at initial vehicle dispatch
class HandoverCheckout {
  final String id;
  final String bookingItemId;
  final String vehicleId;
  final String staffId;
  final int checkoutOdometerKm;
  final int checkoutFuelLevel; // Scale 1 to 8
  final List<InspectionPoint> bodyInspection;
  final List<String> photos;
  final String customerSignatureUrl;
  final String staffSignatureUrl;
  final String checkoutNotes;
  final DateTime checkoutTimestamp;

  const HandoverCheckout({
    required this.id,
    required this.bookingItemId,
    required this.vehicleId,
    required this.staffId,
    required this.checkoutOdometerKm,
    required this.checkoutFuelLevel,
    required this.bodyInspection,
    required this.photos,
    required this.customerSignatureUrl,
    required this.staffSignatureUrl,
    required this.checkoutNotes,
    required this.checkoutTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_item_id': bookingItemId,
        'vehicle_id': vehicleId,
        'staff_id': staffId,
        'checkout_odometer_km': checkoutOdometerKm,
        'checkout_fuel_level': checkoutFuelLevel,
        'body_inspection_json': bodyInspection.map((e) => e.toJson()).toList(),
        'photos_json': photos,
        'customer_signature_url': customerSignatureUrl,
        'staff_signature_url': staffSignatureUrl,
        'checkout_notes': checkoutNotes,
        'checkout_timestamp': checkoutTimestamp.toIso8601String(),
      };

  factory HandoverCheckout.fromJson(Map<String, dynamic> json) {
    final rawInspection = json['body_inspection_json'];
    final inspectionList = (rawInspection is List)
        ? rawInspection.map((e) => InspectionPoint.fromJson(e as Map<String, dynamic>)).toList()
        : InspectionPoint.createDefaultChecklist();

    final rawPhotos = json['photos_json'];
    final photosList = (rawPhotos is List) ? List<String>.from(rawPhotos) : <String>[];

    return HandoverCheckout(
      id: json['id'] as String? ?? '',
      bookingItemId: json['booking_item_id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      staffId: json['staff_id'] as String? ?? '',
      checkoutOdometerKm: json['checkout_odometer_km'] as int? ?? 0,
      checkoutFuelLevel: json['checkout_fuel_level'] as int? ?? 8,
      bodyInspection: inspectionList,
      photos: photosList,
      customerSignatureUrl: json['customer_signature_url'] as String? ?? '',
      staffSignatureUrl: json['staff_signature_url'] as String? ?? '',
      checkoutNotes: json['checkout_notes'] as String? ?? '',
      checkoutTimestamp: DateTime.tryParse(json['checkout_timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
