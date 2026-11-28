import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../domain/vehicle.dart';
import 'catalog_controller.dart';

class CatalogScreen extends ConsumerWidget {
  final void Function(Vehicle vehicle)? onSelectVehicle;

  const CatalogScreen({super.key, this.onSelectVehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(catalogControllerProvider);
    final isCompact = ResponsiveLayout.getDeviceType(context) == DeviceScreenType.compact;

    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(context, ref, l10n, state),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? _buildErrorView(ref, state.errorMessage!)
                    : state.filteredVehicles.isEmpty
                        ? Center(child: Text(l10n.catalogNoVehicles))
                        : _buildGrid(context, state.filteredVehicles, isCompact, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
      BuildContext context, WidgetRef ref, AppLocalizations l10n, CatalogState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => ref.read(catalogControllerProvider.notifier).setSearchQuery(val),
            decoration: InputDecoration(
              hintText: l10n.catalogSearch,
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(ref, l10n.catalogAll, 'ALL', state.selectedServiceType == 'ALL'),
                const SizedBox(width: 8),
                _filterChip(ref, l10n.packageSelfDrive, 'SELF_DRIVE',
                    state.selectedServiceType == 'SELF_DRIVE'),
                const SizedBox(width: 8),
                _filterChip(ref, l10n.packageWithDriver, 'WITH_DRIVER',
                    state.selectedServiceType == 'WITH_DRIVER'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(WidgetRef ref, String label, String value, bool isSelected) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: AppTheme.primaryNavy.withValues(alpha: 0.12),
      onSelected: (_) => ref.read(catalogControllerProvider.notifier).setServiceType(value),
    );
  }

  Widget _buildGrid(BuildContext context, List<Vehicle> vehicles, bool isCompact, AppLocalizations l10n) {
    final crossAxisCount = isCompact ? 1 : 3;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isCompact ? 1.5 : 1.15,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(context, vehicle, l10n);
      },
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.displayName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        vehicle.licensePlate,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(vehicle.status, l10n),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _specPill(Icons.airline_seat_recline_normal, '${vehicle.seatingCapacity} ${l10n.catalogSeats}'),
                _specPill(Icons.settings, vehicle.transmission),
                _specPill(Icons.speed, '${vehicle.currentOdometerKm} KM'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Mulai dari', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(
                        'Rp 350.000 ${l10n.catalogPerDay}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.accentTeal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: vehicle.isAvailable ? () => onSelectVehicle?.call(vehicle) : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: Text(l10n.btnBookNow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _specPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, AppLocalizations l10n) {
    final isAvailable = status == 'AVAILABLE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAvailable ? Colors.green.shade300 : Colors.amber.shade300),
      ),
      child: Text(
        isAvailable ? l10n.statusAvailable : (status == 'ON_RENTAL' ? l10n.statusOnRental : l10n.statusBooked),
        style: TextStyle(
          color: isAvailable ? Colors.green.shade800 : Colors.amber.shade800,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorView(WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.read(catalogControllerProvider.notifier).loadCatalog(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
