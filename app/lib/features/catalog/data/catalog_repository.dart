import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_service.dart';
import '../domain/vehicle.dart';
import '../domain/rental_package.dart';

class CatalogRepository {
  final SupabaseClient? _client;

  CatalogRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService().clientOrNull;

  Future<List<Vehicle>> fetchVehicles() async {
    final client = _client;
    if (client == null) {
      return const [
        Vehicle(
          id: 'v-sample-1',
          licensePlate: 'AB 1234 XY',
          brand: 'Toyota',
          model: 'All New Avanza',
          year: 2023,
          transmission: 'AUTOMATIC',
          seatingCapacity: 7,
          currentOdometerKm: 25000,
          status: 'AVAILABLE',
        ),
        Vehicle(
          id: 'v-sample-2',
          licensePlate: 'AB 5678 ZB',
          brand: 'Honda',
          model: 'Brio RS',
          year: 2024,
          transmission: 'AUTOMATIC',
          seatingCapacity: 5,
          currentOdometerKm: 18000,
          status: 'AVAILABLE',
        ),
      ];
    }

    final response = await client
        .from('vehicles')
        .select()
        .eq('is_active', true)
        .order('brand', ascending: true);

    return (response as List)
        .map((json) => Vehicle.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<RentalPackage>> fetchPackages() async {
    final client = _client;
    if (client == null) {
      return const [
        RentalPackage(
          id: 'pkg-sample-1',
          name: 'Lepas Kunci 24 Jam',
          serviceType: 'SELF_DRIVE',
          serviceArea: 'IN_TOWN',
          durationHours: 24,
          basePrice: 350000.0,
          depositAmount: 500000.0,
          includesFuel: false,
        ),
        RentalPackage(
          id: 'pkg-sample-2',
          name: 'All-In Mobil+Driver 12 Jam',
          serviceType: 'WITH_DRIVER',
          serviceArea: 'IN_TOWN',
          durationHours: 12,
          basePrice: 550000.0,
          depositAmount: 0.0,
          includesFuel: true,
        ),
      ];
    }

    final response = await client
        .from('rental_packages')
        .select()
        .eq('is_active', true)
        .order('base_price', ascending: true);

    return (response as List)
        .map((json) => RentalPackage.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
