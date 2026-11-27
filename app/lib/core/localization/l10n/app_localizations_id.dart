// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Ashvin FleetOS';

  @override
  String get appSubtitle =>
      'Sistem Informasi dan Penjualan Rental Mobil Terintegrasi';

  @override
  String get navCatalog => 'Katalog';

  @override
  String get navMyBookings => 'Pesanan Saya';

  @override
  String get navFieldTasks => 'Operasional Lapangan';

  @override
  String get navAdminDashboard => 'Dasbor';

  @override
  String get navFleet => 'Armada';

  @override
  String get navCorporate => 'Korporasi B2B';

  @override
  String get navFinance => 'Keuangan';

  @override
  String get navAuditLogs => 'Log Audit';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get roleCustomer => 'Pelanggan';

  @override
  String get roleFieldStaff => 'Staf Lapangan';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleOwner => 'Pemilik';

  @override
  String get statusAvailable => 'Tersedia';

  @override
  String get statusBooked => 'Dipesan';

  @override
  String get statusOnRental => 'Sedang Disewa';

  @override
  String get statusMaintenanceRequired => 'Perlu Servis';

  @override
  String get statusDecommissioned => 'Tidak Beroperasi';

  @override
  String get packageSelfDrive => 'Lepas Kunci';

  @override
  String get packageWithDriver => 'Dengan Sopir';

  @override
  String get packageInTown => 'Dalam Kota';

  @override
  String get packageOutOfTown => 'Luar Kota';

  @override
  String get packageFuelExcluded => 'BBM Luar (Exclude)';

  @override
  String get packageFuelIncluded => 'BBM Dalam (Include)';

  @override
  String get btnBookNow => 'Pesan Sekarang';

  @override
  String get btnConfirm => 'Konfirmasi';

  @override
  String get btnCancel => 'Batal';

  @override
  String get btnSave => 'Simpan';

  @override
  String get btnCheckOut => 'Serah Terima (Check-Out)';

  @override
  String get btnCheckIn => 'Pengembalian (Check-In)';

  @override
  String get btnSignAgreement => 'Tanda Tangan Digital';

  @override
  String get btnClearSignature => 'Hapus TTD';

  @override
  String get labelOdometer => 'Odometer (KM)';

  @override
  String get labelFuelLevel => 'Level BBM';

  @override
  String get labelLicensePlate => 'Plat Nomor';

  @override
  String get labelBrandModel => 'Merek & Model';

  @override
  String get labelDailyRate => 'Tarif Harian';

  @override
  String get labelDeposit => 'Uang Jaminan (Deposit)';

  @override
  String get labelInspectionNotes => 'Catatan Inspeksi';

  @override
  String get labelCustomerSignature => 'Tanda Tangan Penyewa';

  @override
  String get labelStaffSignature => 'Tanda Tangan Staf';

  @override
  String get msgOdometerValidation =>
      'KM Akhir tidak boleh lebih kecil dari KM Awal';

  @override
  String get msgHandoverSuccess => 'Serah terima unit berhasil disimpan';

  @override
  String get msgReturnSuccess => 'Pengembalian unit berhasil dicatat';

  @override
  String get msgAuditProtected =>
      'Log sistem bersifat permanen dan terlindungi secara atomik';
}
