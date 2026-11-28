import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../catalog/domain/vehicle.dart';
import '../../catalog/domain/rental_package.dart';
import '../../catalog/presentation/catalog_controller.dart';
import '../data/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository());

class BookingModal extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const BookingModal({super.key, required this.vehicle});

  @override
  ConsumerState<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends ConsumerState<BookingModal> {
  RentalPackage? _selectedPackage;
  DateTime _startDate = DateTime.now().add(const Duration(hours: 2));
  DateTime _endDate = DateTime.now().add(const Duration(hours: 26));
  final _idCardCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authControllerProvider).profile;
    if (profile != null) {
      _idCardCtrl.text = profile.idCardNumber ?? '';
      _licenseCtrl.text = profile.driverLicenseNumber ?? '';
      _emergencyCtrl.text = profile.emergencyContactName ?? '';
    }
  }

  @override
  void dispose() {
    _idCardCtrl.dispose();
    _licenseCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final catalogState = ref.watch(catalogControllerProvider);
    final packages = catalogState.packages;

    if (_selectedPackage == null && packages.isNotEmpty) {
      _selectedPackage = packages.first;
    }

    final double rentalFee = _selectedPackage?.basePrice ?? 350000.0;
    final double deposit = _selectedPackage?.depositAmount ?? 500000.0;
    final double downPayment = rentalFee * 0.3;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.bookingTitle,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 12),
              // Vehicle summary header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, color: AppTheme.accentTeal, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.vehicle.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${widget.vehicle.licensePlate} • ${widget.vehicle.transmission}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Package selector
              DropdownButtonFormField<RentalPackage>(
                initialValue: _selectedPackage,
                decoration: InputDecoration(
                  labelText: l10n.catalogSelectPackage,
                  border: const OutlineInputBorder(),
                ),
                items: packages.map((pkg) {
                  return DropdownMenuItem(
                    value: pkg,
                    child: Text('${pkg.name} - Rp ${pkg.basePrice.toStringAsFixed(0)}'),
                  );
                }).toList(),
                onChanged: (pkg) => setState(() => _selectedPackage = pkg),
              ),
              const SizedBox(height: 16),
              // KYC inputs
              TextField(
                controller: _idCardCtrl,
                decoration: InputDecoration(
                  labelText: l10n.bookingIdCard,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedPackage?.isSelfDrive ?? true) ...[
                TextField(
                  controller: _licenseCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.bookingDriverLicense,
                    prefixIcon: const Icon(Icons.drive_eta_outlined),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emergencyCtrl,
                decoration: InputDecoration(
                  labelText: l10n.bookingEmergencyContact,
                  prefixIcon: const Icon(Icons.contact_phone_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Cost Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _costRow(l10n.bookingTotalFee, 'Rp ${rentalFee.toStringAsFixed(0)}'),
                    const SizedBox(height: 6),
                    _costRow(l10n.labelDeposit, 'Rp ${deposit.toStringAsFixed(0)}'),
                    const Divider(height: 16),
                    _costRow(l10n.bookingDownPayment, 'Rp ${downPayment.toStringAsFixed(0)}', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _agreedToTerms,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                title: Text(l10n.bookingDepositNotice, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_agreedToTerms && !_isSubmitting) ? _submitBooking : null,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.btnConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _costRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? AppTheme.accentTeal : Colors.black87)),
      ],
    );
  }

  Future<void> _submitBooking() async {
    final authProfile = ref.read(authControllerProvider).profile;
    if (authProfile == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(bookingRepositoryProvider).createRetailBooking(
            customerId: authProfile.id,
            vehicleId: widget.vehicle.id,
            packageId: _selectedPackage!.id,
            startTime: _startDate,
            endTime: _endDate,
            unitPrice: _selectedPackage!.basePrice,
            depositAmount: _selectedPackage!.depositAmount,
            idCardNumber: _idCardCtrl.text,
            driverLicenseNumber: _licenseCtrl.text,
            emergencyContact: _emergencyCtrl.text,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.bookingSubmitSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
