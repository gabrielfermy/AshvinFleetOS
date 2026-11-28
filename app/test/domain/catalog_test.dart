import 'package:flutter_test/flutter_test.dart';
import 'package:afos_app/features/catalog/domain/vehicle.dart';
import 'package:afos_app/features/catalog/domain/rental_package.dart';
import 'package:afos_app/features/catalog/presentation/catalog_controller.dart';

void main() {
  group('Catalog Domain & State Tests', () {
    test('Vehicle parses from json and validates availability', () {
      final json = {
        'id': 'v-101',
        'license_plate': 'AB 1010 XY',
        'brand': 'Toyota',
        'model': 'Innova Reborn',
        'year': 2023,
        'transmission': 'AUTOMATIC',
        'seating_capacity': 7,
        'current_odometer_km': 32000,
        'status': 'AVAILABLE',
      };

      final vehicle = Vehicle.fromJson(json);
      expect(vehicle.id, 'v-101');
      expect(vehicle.displayName, 'Toyota Innova Reborn (2023)');
      expect(vehicle.isAvailable, isTrue);
    });

    test('RentalPackage parses from json and identifies service type', () {
      final json = {
        'id': 'pkg-1',
        'name': 'Lepas Kunci 24 Jam',
        'service_type': 'SELF_DRIVE',
        'service_area': 'IN_TOWN',
        'duration_hours': 24,
        'base_price': 350000,
        'deposit_amount': 500000,
        'includes_fuel': false,
      };

      final pkg = RentalPackage.fromJson(json);
      expect(pkg.isSelfDrive, isTrue);
      expect(pkg.isWithDriver, isFalse);
      expect(pkg.basePrice, 350000.0);
    });

    test('CatalogState filters vehicles by search query', () {
      const v1 = Vehicle(
        id: '1',
        licensePlate: 'AB 1111 AA',
        brand: 'Toyota',
        model: 'Avanza',
        year: 2022,
        transmission: 'MANUAL',
        seatingCapacity: 7,
        currentOdometerKm: 40000,
        status: 'AVAILABLE',
      );
      const v2 = Vehicle(
        id: '2',
        licensePlate: 'AB 2222 BB',
        brand: 'Honda',
        model: 'Brio',
        year: 2023,
        transmission: 'AUTOMATIC',
        seatingCapacity: 5,
        currentOdometerKm: 15000,
        status: 'AVAILABLE',
      );

      final state = CatalogState(
        vehicles: const [v1, v2],
        searchQuery: 'brio',
      );

      expect(state.filteredVehicles.length, 1);
      expect(state.filteredVehicles.first.model, 'Brio');
    });
  });
}
