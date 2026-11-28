import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/operations_repository.dart';
import '../domain/inspection_point.dart';

class OperationsState {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final String? errorMessage;
  final String activeFilter; // 'ALL', 'PENDING_CHECKOUT', 'ON_RENTAL', 'COMPLETED'

  const OperationsState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeFilter = 'ALL',
  });

  OperationsState copyWith({
    List<Map<String, dynamic>>? items,
    bool? isLoading,
    String? errorMessage,
    String? activeFilter,
  }) {
    return OperationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  List<Map<String, dynamic>> get filteredItems {
    if (activeFilter == 'ALL') return items;
    if (activeFilter == 'PENDING_CHECKOUT') {
      return items.where((it) {
        final status = it['status'] as String? ?? '';
        return status == 'CONFIRMED' || status == 'PENDING_VERIFICATION' || status == 'DRAFT';
      }).toList();
    }
    return items.where((it) => (it['status'] as String? ?? '') == activeFilter).toList();
  }
}

final operationsControllerProvider =
    StateNotifierProvider<OperationsController, OperationsState>((ref) {
  final repo = ref.watch(operationsRepositoryProvider);
  return OperationsController(repo);
});

class OperationsController extends StateNotifier<OperationsState> {
  final OperationsRepository _repository;

  OperationsController(this._repository) : super(const OperationsState()) {
    loadDispatches();
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> loadDispatches() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.fetchDispatchItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> executeCheckout({
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.executeCheckout(
        bookingItemId: bookingItemId,
        staffId: staffId,
        checkoutOdometerKm: checkoutOdometerKm,
        checkoutFuelLevel: checkoutFuelLevel,
        inspection: inspection,
        photos: photos,
        customerSignatureUrl: customerSignatureUrl,
        staffSignatureUrl: staffSignatureUrl,
        notes: notes,
      );
      await loadDispatches();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> executeCheckin({
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.executeCheckin(
        bookingItemId: bookingItemId,
        staffId: staffId,
        checkinOdometerKm: checkinOdometerKm,
        checkinFuelLevel: checkinFuelLevel,
        overtimeHours: overtimeHours,
        overtimePenaltyFee: overtimePenaltyFee,
        fuelPenaltyFee: fuelPenaltyFee,
        damagePenaltyFee: damagePenaltyFee,
        inspection: inspection,
        photos: photos,
        customerSignatureUrl: customerSignatureUrl,
        staffSignatureUrl: staffSignatureUrl,
      );
      await loadDispatches();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
