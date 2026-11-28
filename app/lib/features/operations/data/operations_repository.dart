import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_service.dart';
import '../domain/handover_checkout.dart';
import '../domain/inspection_point.dart';
import '../domain/return_checkin.dart';

final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  return OperationsRepository();
});

/// Data access layer for Check-Out (Handover) and Check-In (Return)
class OperationsRepository {
  final SupabaseClient? _client;

  OperationsRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService().clientOrNull;

  /// Fetches active booking items with vehicle and handover details for field dispatch
  Future<List<Map<String, dynamic>>> fetchDispatchItems() async {
    final client = _client;
    if (client == null) return [];

    final response = await client
        .from('booking_items')
        .select('''
          id,
          booking_id,
          vehicle_id,
          package_id,
          driver_id,
          start_time,
          end_time,
          unit_price,
          status,
          bookings!inner (
            id,
            booking_code,
            order_type,
            status,
            customer_id,
            user_profiles (
              full_name,
              phone_number
            )
          ),
          vehicles!inner (
            id,
            license_plate,
            brand,
            model,
            current_odometer_km,
            status
          ),
          rental_packages!inner (
            id,
            name,
            service_type,
            base_price
          ),
          handovers_checkout (
            id,
            checkout_odometer_km,
            checkout_fuel_level,
            checkout_timestamp,
            body_inspection_json
          ),
          returns_checkin (
            id,
            checkin_odometer_km,
            checkin_fuel_level,
            distance_traveled_km,
            checkin_timestamp
          )
        ''')
        .order('start_time', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Processes atomic check-out handover
  Future<Map<String, dynamic>> executeCheckout({
    required String bookingItemId,
    required String staffId,
    required int checkoutOdometerKm,
    required int checkoutFuelLevel,
    required List<InspectionPoint> inspection,
    required List<String> photos,
    required String customerSignatureUrl,
    required String staffSignatureUrl,
    String notes = '',
  }) async {
    final client = _client;
    if (client == null) throw StateError('Supabase client not initialized');

    final result = await client.rpc(
      'rpc_process_checkout_atomic',
      params: {
        'p_booking_item_id': bookingItemId,
        'p_staff_id': staffId,
        'p_checkout_odometer_km': checkoutOdometerKm,
        'p_checkout_fuel_level': checkoutFuelLevel,
        'p_body_inspection_json': inspection.map((e) => e.toJson()).toList(),
        'p_photos_json': photos,
        'p_customer_signature_url': customerSignatureUrl,
        'p_staff_signature_url': staffSignatureUrl,
        'p_checkout_notes': notes,
      },
    );

    return Map<String, dynamic>.from(result as Map);
  }

  /// Processes atomic check-in return
  Future<Map<String, dynamic>> executeCheckin({
    required String bookingItemId,
    required String staffId,
    required int checkinOdometerKm,
    required int checkinFuelLevel,
    required double overtimeHours,
    required double overtimePenaltyFee,
    required double fuelPenaltyFee,
    required double damagePenaltyFee,
    required List<InspectionPoint> inspection,
    required List<String> photos,
    required String customerSignatureUrl,
    required String staffSignatureUrl,
  }) async {
    final client = _client;
    if (client == null) throw StateError('Supabase client not initialized');

    final result = await client.rpc(
      'rpc_process_checkin_atomic',
      params: {
        'p_booking_item_id': bookingItemId,
        'p_staff_id': staffId,
        'p_checkin_odometer_km': checkinOdometerKm,
        'p_checkin_fuel_level': checkinFuelLevel,
        'p_overtime_hours': overtimeHours,
        'p_overtime_penalty_fee': overtimePenaltyFee,
        'p_fuel_penalty_fee': fuelPenaltyFee,
        'p_damage_penalty_fee': damagePenaltyFee,
        'p_body_inspection_json': inspection.map((e) => e.toJson()).toList(),
        'p_photos_json': photos,
        'p_customer_signature_url': customerSignatureUrl,
        'p_staff_signature_url': staffSignatureUrl,
      },
    );

    return Map<String, dynamic>.from(result as Map);
  }
}
