import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_service.dart';
import '../domain/booking_order.dart';

class BookingRepository {
  final SupabaseClient? _client;

  BookingRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService().clientOrNull;

  Future<BookingOrder> createRetailBooking({
    required String customerId,
    required String vehicleId,
    required String packageId,
    required DateTime startTime,
    required DateTime endTime,
    required double unitPrice,
    required double depositAmount,
    required String idCardNumber,
    required String driverLicenseNumber,
    required String emergencyContact,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase client not initialized');
    }

    // 1. Update customer profile with KYC information if needed
    await client.from('user_profiles').update({
      'id_card_number': idCardNumber,
      'driver_license_number': driverLicenseNumber,
      'emergency_contact_name': emergencyContact,
    }).eq('id', customerId);

    // 2. Generate unique booking code
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final bookingCode = 'AFOS-B2C-$timestamp';
    final downPayment = unitPrice * 0.3; // 30% Down Payment

    // 3. Create parent booking
    final bookingRes = await client.from('bookings').insert({
      'booking_code': bookingCode,
      'order_type': 'B2C_RETAIL',
      'customer_id': customerId,
      'status': 'PENDING_VERIFICATION',
      'total_amount': unitPrice,
      'security_deposit_amount': depositAmount,
      'down_payment_amount': downPayment,
    }).select().single();

    final booking = BookingOrder.fromJson(bookingRes);

    // 4. Create child booking item
    await client.from('booking_items').insert({
      'booking_id': booking.id,
      'vehicle_id': vehicleId,
      'package_id': packageId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'unit_price': unitPrice,
      'status': 'PENDING_VERIFICATION',
    });

    return booking;
  }

  Future<List<Map<String, dynamic>>> fetchUserBookings(String customerId) async {
    final client = _client;
    if (client == null) return [];

    final response = await client
        .from('bookings')
        .select('*, booking_items(*, vehicles(*), rental_packages(*))')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
