import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/catalog_repository.dart';
import '../domain/vehicle.dart';
import '../domain/rental_package.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

class CatalogState {
  final bool isLoading;
  final List<Vehicle> vehicles;
  final List<RentalPackage> packages;
  final String selectedServiceType; // 'ALL', 'SELF_DRIVE', 'WITH_DRIVER'
  final String searchQuery;
  final String? errorMessage;

  const CatalogState({
    this.isLoading = true,
    this.vehicles = const [],
    this.packages = const [],
    this.selectedServiceType = 'ALL',
    this.searchQuery = '',
    this.errorMessage,
  });

  List<Vehicle> get filteredVehicles {
    return vehicles.where((v) {
      final matchesSearch = v.displayName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          v.licensePlate.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  CatalogState copyWith({
    bool? isLoading,
    List<Vehicle>? vehicles,
    List<RentalPackage>? packages,
    String? selectedServiceType,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CatalogState(
      isLoading: isLoading ?? this.isLoading,
      vehicles: vehicles ?? this.vehicles,
      packages: packages ?? this.packages,
      selectedServiceType: selectedServiceType ?? this.selectedServiceType,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class CatalogController extends StateNotifier<CatalogState> {
  final CatalogRepository _repo;

  CatalogController(this._repo) : super(const CatalogState()) {
    loadCatalog();
  }

  Future<void> loadCatalog() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final vehicles = await _repo.fetchVehicles();
      final packages = await _repo.fetchPackages();
      state = state.copyWith(
        isLoading: false,
        vehicles: vehicles,
        packages: packages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setServiceType(String type) {
    state = state.copyWith(selectedServiceType: type);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final catalogControllerProvider =
    StateNotifierProvider<CatalogController, CatalogState>((ref) {
  return CatalogController(ref.watch(catalogRepositoryProvider));
});
