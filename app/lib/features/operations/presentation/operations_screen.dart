import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/afos_colors.dart';
import '../../../../core/theme/afos_typography.dart';
import '../../../../core/widgets/afos_status_badge.dart';
import 'checkin_modal.dart';
import 'checkout_modal.dart';
import 'operations_controller.dart';

/// Screen for Field Staff to manage and execute vehicle dispatches, Check-Out, and Check-In
class OperationsScreen extends ConsumerWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(operationsControllerProvider);
    final notifier = ref.read(operationsControllerProvider.notifier);
    final items = state.filteredItems;

    return Scaffold(
      backgroundColor: AfosColors.slateMist,
      appBar: AppBar(
        title: const Text('Operasional Serah Terima Unit (Handover & Return)'),
        backgroundColor: Colors.white,
        foregroundColor: AfosColors.primaryNavy,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadDispatches(),
            tooltip: 'Segarkan Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip(notifier, state.activeFilter, 'ALL', 'Semua Status'),
                  const SizedBox(width: 8),
                  _filterChip(notifier, state.activeFilter, 'PENDING_CHECKOUT', 'Siap Serah Terima'),
                  const SizedBox(width: 8),
                  _filterChip(notifier, state.activeFilter, 'ON_RENTAL', 'Sedang Disewa (Aktif)'),
                  const SizedBox(width: 8),
                  _filterChip(notifier, state.activeFilter, 'COMPLETED', 'Selesai Dikembalikan'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AfosColors.borderSlate),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment_outlined, size: 48, color: AfosColors.mutedSlate),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada jadwal serah terima pada kategori ini',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => notifier.loadDispatches(),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Muat Ulang'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _buildDispatchCard(context, items[index], notifier);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(OperationsController notifier, String current, String value, String label) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => notifier.setFilter(value),
      selectedColor: AfosColors.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AfosColors.charcoalInk,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildDispatchCard(BuildContext context, Map<String, dynamic> item, OperationsController notifier) {
    final status = item['status'] as String? ?? 'DRAFT';
    final vehicle = item['vehicles'] as Map<String, dynamic>? ?? {};
    final booking = item['bookings'] as Map<String, dynamic>? ?? {};
    final customer = booking['user_profiles'] as Map<String, dynamic>? ?? {};
    final package = item['rental_packages'] as Map<String, dynamic>? ?? {};
    final checkout = item['handovers_checkout'] as Map<String, dynamic>?;
    final returnCheckin = item['returns_checkin'] as Map<String, dynamic>?;

    final plate = vehicle['license_plate'] as String? ?? '-';
    final vehicleName = '${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}'.trim();
    final customerName = customer['full_name'] as String? ?? 'Pelanggan';
    final customerPhone = customer['phone_number'] as String? ?? '-';
    final bookingCode = booking['booking_code'] as String? ?? '-';
    final packageName = package['name'] as String? ?? 'Paket Rental';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      plate,
                      style: AfosTypography.licensePlate.copyWith(fontSize: 14, color: AfosColors.primaryNavy),
                    ),
                    const SizedBox(width: 8),
                    Text(vehicleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                _statusBadge(status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AfosColors.mutedSlate),
                const SizedBox(width: 4),
                Text(customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text('($customerPhone)', style: const TextStyle(fontSize: 12, color: AfosColors.mutedSlate)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 16, color: AfosColors.mutedSlate),
                const SizedBox(width: 4),
                Text('Order: $bookingCode', style: const TextStyle(fontSize: 12, color: AfosColors.mutedSlate)),
                const SizedBox(width: 12),
                Text(packageName, style: const TextStyle(fontSize: 12, color: AfosColors.jogjaTeal, fontWeight: FontWeight.w600)),
              ],
            ),
            if (checkout != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.speed, size: 16, color: AfosColors.jogjaTeal),
                  const SizedBox(width: 4),
                  Text(
                    'Start KM: ${checkout['checkout_odometer_km']} | BBM: ${checkout['checkout_fuel_level']}/8',
                    style: AfosTypography.odometer.copyWith(fontSize: 12, color: AfosColors.primaryNavy),
                  ),
                ],
              ),
            ],
            if (returnCheckin != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AfosColors.emeraldVerified),
                  const SizedBox(width: 4),
                  Text(
                    'End KM: ${returnCheckin['checkin_odometer_km']} (ΔKM: +${returnCheckin['distance_traveled_km']} KM)',
                    style: AfosTypography.odometer.copyWith(fontSize: 12, color: AfosColors.emeraldVerified),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'CONFIRMED' || status == 'PENDING_VERIFICATION' || status == 'DRAFT')
                  ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => CheckoutModal(item: item),
                    ),
                    icon: const Icon(Icons.key, size: 16),
                    label: const Text('Serah Terima (Check-Out)'),
                    style: ElevatedButton.styleFrom(backgroundColor: AfosColors.jogjaTeal),
                  )
                else if (status == 'ON_RENTAL')
                  ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => CheckinModal(item: item),
                    ),
                    icon: const Icon(Icons.assignment_return, size: 16),
                    label: const Text('Pengembalian (Check-In)'),
                    style: ElevatedButton.styleFrom(backgroundColor: AfosColors.emeraldVerified),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.done_all, size: 16, color: AfosColors.mutedSlate),
                    label: const Text('Selesai'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final (label, fg, bg) = switch (status) {
      'ON_RENTAL' => ('Sedang Disewa', AfosColors.jogjaTeal, Color(0xFFE0F2FE)),
      'COMPLETED' => ('Selesai', AfosColors.emeraldVerified, Color(0xFFDCFCE7)),
      'CONFIRMED' => ('Siap Check-Out', AfosColors.warmAmber, Color(0xFFFEF3C7)),
      _ => ('Menunggu', AfosColors.mutedSlate, Color(0xFFF1F5F9)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
