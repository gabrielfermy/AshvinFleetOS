import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/afos_colors.dart';
import '../../../../core/theme/afos_typography.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/inspection_point.dart';
import '../domain/operations_penalty_calculator.dart';
import 'operations_controller.dart';
import 'widgets/fuel_gauge_picker.dart';
import 'widgets/inspection_checklist_widget.dart';
import 'widgets/signature_pad_widget.dart';

/// Modal dialog for Field Staff to execute Check-In Return
class CheckinModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;

  const CheckinModal({super.key, required this.item});

  @override
  ConsumerState<CheckinModal> createState() => _CheckinModalState();
}

class _CheckinModalState extends ConsumerState<CheckinModal> {
  late final TextEditingController _odometerCtrl;
  final _damageFeeCtrl = TextEditingController(text: '0');
  int _fuelLevel = 8;
  List<InspectionPoint> _inspection = InspectionPoint.createDefaultChecklist();
  String _customerSig = '';
  String _staffSig = '';
  String? _errorMessage;
  bool _isSubmitting = false;

  int _startOdo = 0;
  int _startFuel = 8;
  double _dailyRate = 350000;

  @override
  void initState() {
    super.initState();
    final checkout = widget.item['handovers_checkout'] as Map<String, dynamic>? ?? {};
    _startOdo = checkout['checkout_odometer_km'] as int? ?? 0;
    _startFuel = checkout['checkout_fuel_level'] as int? ?? 8;
    _fuelLevel = _startFuel;
    _odometerCtrl = TextEditingController(text: '${_startOdo + 50}');
    final pkg = widget.item['rental_packages'] as Map<String, dynamic>? ?? {};
    _dailyRate = (pkg['base_price'] as num?)?.toDouble() ?? 350000;
  }

  @override
  void dispose() {
    _odometerCtrl.dispose();
    _damageFeeCtrl.dispose();
    super.dispose();
  }

  int get _enteredOdo => int.tryParse(_odometerCtrl.text.trim()) ?? 0;
  int get _deltaKm => _enteredOdo >= _startOdo ? _enteredOdo - _startOdo : 0;
  double get _damageFee => double.tryParse(_damageFeeCtrl.text.trim()) ?? 0.0;

  double get _fuelPenalty => OperationsPenaltyCalculator.calculateFuelPenalty(
        checkoutFuel: _startFuel,
        checkinFuel: _fuelLevel,
      );

  double get _totalPenalties => _fuelPenalty + _damageFee;

  Future<void> _handleSubmit() async {
    if (_enteredOdo < _startOdo) {
      setState(() => _errorMessage = 'Odometer akhir ($_enteredOdo KM) tidak boleh kurang dari KM awal ($_startOdo KM)');
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

    final success = await ref.read(operationsControllerProvider.notifier).executeCheckin(
          bookingItemId: widget.item['id'] as String,
          staffId: staffId.isNotEmpty ? staffId : '00000000-0000-0000-0000-000000000000',
          checkinOdometerKm: _enteredOdo,
          checkinFuelLevel: _fuelLevel,
          overtimeHours: 0.0,
          overtimePenaltyFee: 0.0,
          fuelPenaltyFee: _fuelPenalty,
          damagePenaltyFee: _damageFee,
          inspection: _inspection,
          photos: const [],
          customerSignatureUrl: _customerSig,
          staffSignatureUrl: _staffSig,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengembalian unit (Check-In) berhasil diselesaikan!')),
        );
      } else {
        final err = ref.read(operationsControllerProvider).errorMessage;
        setState(() => _errorMessage = err ?? 'Gagal memproses check-in');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.item['vehicles'] as Map<String, dynamic>? ?? {};
    final plate = vehicle['license_plate'] as String? ?? '-';
    final vehicleName = '${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}'.trim();
    final isOdoInvalid = _enteredOdo < _startOdo;

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
                    'Pengembalian Unit (Check-In)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AfosColors.primaryNavy),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 12),
              // Header card with delta KM highlight
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
                        Text('Start KM: $_startOdo | BBM Awal: $_startFuel/8',
                            style: const TextStyle(fontSize: 12, color: AfosColors.mutedSlate)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(plate, style: AfosTypography.licensePlate.copyWith(fontSize: 13, color: AfosColors.primaryNavy)),
                        Text(
                          'ΔKM: +$_deltaKm KM',
                          style: AfosTypography.odometer.copyWith(
                            fontSize: 14,
                            color: isOdoInvalid ? AfosColors.crimsonAlert : AfosColors.emeraldVerified,
                          ),
                        ),
                      ],
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
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Odometer Akhir (KM)',
                  prefixIcon: const Icon(Icons.speed_outlined),
                  errorText: isOdoInvalid ? 'End KM tidak boleh < $_startOdo KM' : null,
                ),
              ),
              const SizedBox(height: 16),
              FuelGaugePicker(
                selectedLevel: _fuelLevel,
                label: 'Level Bahan Bakar Saat Kembali',
                onLevelChanged: (lvl) => setState(() => _fuelLevel = lvl),
              ),
              const SizedBox(height: 16),
              InspectionChecklistWidget(
                points: _inspection,
                onChanged: (pts) => setState(() => _inspection = pts),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _damageFeeCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Biaya Klaim Kerusakan Fisik (Rp)',
                  prefixIcon: Icon(Icons.build_circle_outlined),
                ),
              ),
              const SizedBox(height: 16),
              // Penalties Summary Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _totalPenalties > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _totalPenalties > 0 ? Colors.orange.shade200 : Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Denda / Penggantian BBM:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      'Rp ${_totalPenalties.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _totalPenalties > 0 ? AfosColors.crimsonAlert : AfosColors.emeraldVerified,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SignaturePadWidget(
                label: 'Tanda Tangan Digital Pelanggan (Pengembalian)',
                onSignatureChanged: (sig) => _customerSig = sig,
              ),
              const SizedBox(height: 12),
              SignaturePadWidget(
                label: 'Tanda Tangan Digital Petugas / Field Staff',
                onSignatureChanged: (sig) => _staffSig = sig,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting || isOdoInvalid ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Konfirmasi & Selesaikan Sewa (Check-In)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
