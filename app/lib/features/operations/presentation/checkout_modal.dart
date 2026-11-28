import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/afos_colors.dart';
import '../../../../core/theme/afos_typography.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/inspection_point.dart';
import 'operations_controller.dart';
import 'widgets/fuel_gauge_picker.dart';
import 'widgets/inspection_checklist_widget.dart';
import 'widgets/signature_pad_widget.dart';

/// Modal dialog for Field Staff to execute Check-Out Handover
class CheckoutModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;

  const CheckoutModal({super.key, required this.item});

  @override
  ConsumerState<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends ConsumerState<CheckoutModal> {
  late final TextEditingController _odometerCtrl;
  final _notesCtrl = TextEditingController();
  int _fuelLevel = 8;
  List<InspectionPoint> _inspection = InspectionPoint.createDefaultChecklist();
  String _customerSig = '';
  String _staffSig = '';
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.item['vehicles'] as Map<String, dynamic>? ?? {};
    final currentOdo = vehicle['current_odometer_km'] as int? ?? 0;
    _odometerCtrl = TextEditingController(text: '$currentOdo');
  }

  @override
  void dispose() {
    _odometerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final vehicle = widget.item['vehicles'] as Map<String, dynamic>? ?? {};
    final currentOdo = vehicle['current_odometer_km'] as int? ?? 0;
    final enteredOdo = int.tryParse(_odometerCtrl.text.trim()) ?? 0;

    if (enteredOdo < currentOdo) {
      setState(() => _errorMessage = 'Odometer awal ($enteredOdo KM) tidak boleh kurang dari KM saat ini ($currentOdo KM)');
      return;
    }
    if (_customerSig.isEmpty || _staffSig.isEmpty) {
      setState(() => _errorMessage = 'Tanda tangan digital Pelanggan dan Petugas wajib dilengkapi');
      return;
    }

    final staffProfile = ref.read(authControllerProvider).profile;
    final staffId = staffProfile?.id ?? widget.item['staff_id'] ?? '';

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    final success = await ref.read(operationsControllerProvider.notifier).executeCheckout(
          bookingItemId: widget.item['id'] as String,
          staffId: staffId.isNotEmpty ? staffId : '00000000-0000-0000-0000-000000000000',
          checkoutOdometerKm: enteredOdo,
          checkoutFuelLevel: _fuelLevel,
          inspection: _inspection,
          photos: const [],
          customerSignatureUrl: _customerSig,
          staffSignatureUrl: _staffSig,
          notes: _notesCtrl.text.trim(),
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serah terima unit (Check-Out) berhasil diproses!')),
        );
      } else {
        final err = ref.read(operationsControllerProvider).errorMessage;
        setState(() => _errorMessage = err ?? 'Gagal memproses check-out');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.item['vehicles'] as Map<String, dynamic>? ?? {};
    final plate = vehicle['license_plate'] as String? ?? '-';
    final vehicleName = '${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}'.trim();
    final booking = widget.item['bookings'] as Map<String, dynamic>? ?? {};
    final bookingCode = booking['booking_code'] as String? ?? '-';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 850),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Serah Terima Unit (Check-Out)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AfosColors.primaryNavy),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 12),
              // Vehicle Header Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AfosColors.slateMist, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vehicleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Kode: $bookingCode', style: const TextStyle(fontSize: 12, color: AfosColors.mutedSlate)),
                      ],
                    ),
                    Text(
                      plate,
                      style: AfosTypography.licensePlate.copyWith(fontSize: 14, color: AfosColors.primaryNavy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade800, fontSize: 12)),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _odometerCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Odometer Awal (KM)',
                  prefixIcon: Icon(Icons.speed_outlined),
                ),
              ),
              const SizedBox(height: 16),
              FuelGaugePicker(
                selectedLevel: _fuelLevel,
                onLevelChanged: (lvl) => setState(() => _fuelLevel = lvl),
              ),
              const SizedBox(height: 16),
              InspectionChecklistWidget(
                points: _inspection,
                onChanged: (pts) => setState(() => _inspection = pts),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan Serah Terima / Kondisi Khusus',
                  hintText: 'Misal: STNK & kunci diserahkan ke pelanggan',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SignaturePadWidget(
                label: 'Tanda Tangan Digital Pelanggan',
                onSignatureChanged: (sig) => _customerSig = sig,
              ),
              const SizedBox(height: 12),
              SignaturePadWidget(
                label: 'Tanda Tangan Digital Petugas / Field Staff',
                onSignatureChanged: (sig) => _staffSig = sig,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Konfirmasi & Mulai Sewa (Check-Out)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
