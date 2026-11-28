// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ashvin FleetOS';

  @override
  String get appSubtitle => 'Integrated Car Rental Operating System';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navMyBookings => 'My Bookings';

  @override
  String get navFieldTasks => 'Field Operations';

  @override
  String get navAdminDashboard => 'Dashboard';

  @override
  String get navFleet => 'Fleet';

  @override
  String get navCorporate => 'Corporate B2B';

  @override
  String get navFinance => 'Finance';

  @override
  String get navAuditLogs => 'Audit Logs';

  @override
  String get navSettings => 'Settings';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignUp => 'Register';

  @override
  String get authSignOut => 'Sign Out';

  @override
  String get authEmail => 'Email Address';

  @override
  String get authPassword => 'Password';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authPhone => 'Phone Number';

  @override
  String get authNationality => 'Nationality';

  @override
  String get authQuickDemo => 'Quick Demo Logins';

  @override
  String get authNoAccount => 'Don\'t have an account? Register';

  @override
  String get authHaveAccount => 'Already have an account? Sign In';

  @override
  String get authLoggedInAs => 'Logged in as';

  @override
  String get catalogAll => 'All';

  @override
  String get catalogTransmission => 'Transmission';

  @override
  String get catalogManual => 'Manual';

  @override
  String get catalogAutomatic => 'Automatic';

  @override
  String get catalogCapacity => 'Capacity';

  @override
  String get catalogSeats => 'Seats';

  @override
  String get catalogPerDay => '/ day';

  @override
  String get catalogSelectPackage => 'Select Package';

  @override
  String get catalogNoVehicles => 'No vehicles found for the selected criteria';

  @override
  String get catalogSearch => 'Search vehicles by brand or model...';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get roleFieldStaff => 'Field Staff';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleOwner => 'Owner';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusBooked => 'Booked';

  @override
  String get statusOnRental => 'On Rental';

  @override
  String get statusMaintenanceRequired => 'Maintenance Required';

  @override
  String get statusDecommissioned => 'Decommissioned';

  @override
  String get packageSelfDrive => 'Self-Drive';

  @override
  String get packageWithDriver => 'With Driver';

  @override
  String get packageInTown => 'In-Town';

  @override
  String get packageOutOfTown => 'Out-of-Town';

  @override
  String get packageFuelExcluded => 'Fuel Excluded';

  @override
  String get packageFuelIncluded => 'Fuel Included';

  @override
  String get bookingTitle => 'Reserve Vehicle';

  @override
  String get bookingStartDate => 'Start Date & Time';

  @override
  String get bookingEndDate => 'End Date & Time';

  @override
  String get bookingDuration => 'Duration';

  @override
  String get bookingIdCard => 'ID Card / Passport Number';

  @override
  String get bookingDriverLicense => 'Driver License (SIM A / IDP)';

  @override
  String get bookingEmergencyContact => 'Emergency Contact Name & Phone';

  @override
  String get bookingUploadIdCard => 'Upload ID Card / Passport';

  @override
  String get bookingUploadLicense => 'Upload Driver License';

  @override
  String get bookingDepositNotice =>
      'Refundable security deposit is held upon handover';

  @override
  String get bookingSubmitSuccess => 'Booking submitted successfully!';

  @override
  String get bookingSummary => 'Rental Cost Summary';

  @override
  String get bookingTotalFee => 'Total Rental Fee';

  @override
  String get bookingDownPayment => 'Down Payment (30%)';

  @override
  String get btnBookNow => 'Book Now';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnSave => 'Save';

  @override
  String get btnCheckOut => 'Check-Out Handover';

  @override
  String get btnCheckIn => 'Check-In Return';

  @override
  String get btnSignAgreement => 'Sign Digital Agreement';

  @override
  String get btnClearSignature => 'Clear Signature';

  @override
  String get labelOdometer => 'Odometer (KM)';

  @override
  String get labelFuelLevel => 'Fuel Level';

  @override
  String get labelLicensePlate => 'License Plate';

  @override
  String get labelBrandModel => 'Brand & Model';

  @override
  String get labelDailyRate => 'Daily Rate';

  @override
  String get labelDeposit => 'Security Deposit';

  @override
  String get labelInspectionNotes => 'Inspection Notes';

  @override
  String get labelCustomerSignature => 'Customer Signature';

  @override
  String get labelStaffSignature => 'Staff Signature';

  @override
  String get msgOdometerValidation => 'End KM cannot be less than start KM';

  @override
  String get msgHandoverSuccess => 'Handover check-out completed successfully';

  @override
  String get msgReturnSuccess => 'Return check-in completed successfully';

  @override
  String get msgAuditProtected =>
      'System logs are append-only and cryptographically secured';
}
