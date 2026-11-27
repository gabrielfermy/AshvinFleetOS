import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ashvin FleetOS'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Integrated Car Rental Operating System'**
  String get appSubtitle;

  /// No description provided for @navCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navCatalog;

  /// No description provided for @navMyBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get navMyBookings;

  /// No description provided for @navFieldTasks.
  ///
  /// In en, this message translates to:
  /// **'Field Operations'**
  String get navFieldTasks;

  /// No description provided for @navAdminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navAdminDashboard;

  /// No description provided for @navFleet.
  ///
  /// In en, this message translates to:
  /// **'Fleet'**
  String get navFleet;

  /// No description provided for @navCorporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate B2B'**
  String get navCorporate;

  /// No description provided for @navFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get navFinance;

  /// No description provided for @navAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get navAuditLogs;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @roleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get roleCustomer;

  /// No description provided for @roleFieldStaff.
  ///
  /// In en, this message translates to:
  /// **'Field Staff'**
  String get roleFieldStaff;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// No description provided for @statusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statusBooked;

  /// No description provided for @statusOnRental.
  ///
  /// In en, this message translates to:
  /// **'On Rental'**
  String get statusOnRental;

  /// No description provided for @statusMaintenanceRequired.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Required'**
  String get statusMaintenanceRequired;

  /// No description provided for @statusDecommissioned.
  ///
  /// In en, this message translates to:
  /// **'Decommissioned'**
  String get statusDecommissioned;

  /// No description provided for @packageSelfDrive.
  ///
  /// In en, this message translates to:
  /// **'Self-Drive'**
  String get packageSelfDrive;

  /// No description provided for @packageWithDriver.
  ///
  /// In en, this message translates to:
  /// **'With Driver'**
  String get packageWithDriver;

  /// No description provided for @packageInTown.
  ///
  /// In en, this message translates to:
  /// **'In-Town'**
  String get packageInTown;

  /// No description provided for @packageOutOfTown.
  ///
  /// In en, this message translates to:
  /// **'Out-of-Town'**
  String get packageOutOfTown;

  /// No description provided for @packageFuelExcluded.
  ///
  /// In en, this message translates to:
  /// **'Fuel Excluded'**
  String get packageFuelExcluded;

  /// No description provided for @packageFuelIncluded.
  ///
  /// In en, this message translates to:
  /// **'Fuel Included'**
  String get packageFuelIncluded;

  /// No description provided for @btnBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get btnBookNow;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check-Out Handover'**
  String get btnCheckOut;

  /// No description provided for @btnCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-In Return'**
  String get btnCheckIn;

  /// No description provided for @btnSignAgreement.
  ///
  /// In en, this message translates to:
  /// **'Sign Digital Agreement'**
  String get btnSignAgreement;

  /// No description provided for @btnClearSignature.
  ///
  /// In en, this message translates to:
  /// **'Clear Signature'**
  String get btnClearSignature;

  /// No description provided for @labelOdometer.
  ///
  /// In en, this message translates to:
  /// **'Odometer (KM)'**
  String get labelOdometer;

  /// No description provided for @labelFuelLevel.
  ///
  /// In en, this message translates to:
  /// **'Fuel Level'**
  String get labelFuelLevel;

  /// No description provided for @labelLicensePlate.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get labelLicensePlate;

  /// No description provided for @labelBrandModel.
  ///
  /// In en, this message translates to:
  /// **'Brand & Model'**
  String get labelBrandModel;

  /// No description provided for @labelDailyRate.
  ///
  /// In en, this message translates to:
  /// **'Daily Rate'**
  String get labelDailyRate;

  /// No description provided for @labelDeposit.
  ///
  /// In en, this message translates to:
  /// **'Security Deposit'**
  String get labelDeposit;

  /// No description provided for @labelInspectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Inspection Notes'**
  String get labelInspectionNotes;

  /// No description provided for @labelCustomerSignature.
  ///
  /// In en, this message translates to:
  /// **'Customer Signature'**
  String get labelCustomerSignature;

  /// No description provided for @labelStaffSignature.
  ///
  /// In en, this message translates to:
  /// **'Staff Signature'**
  String get labelStaffSignature;

  /// No description provided for @msgOdometerValidation.
  ///
  /// In en, this message translates to:
  /// **'End KM cannot be less than start KM'**
  String get msgOdometerValidation;

  /// No description provided for @msgHandoverSuccess.
  ///
  /// In en, this message translates to:
  /// **'Handover check-out completed successfully'**
  String get msgHandoverSuccess;

  /// No description provided for @msgReturnSuccess.
  ///
  /// In en, this message translates to:
  /// **'Return check-in completed successfully'**
  String get msgReturnSuccess;

  /// No description provided for @msgAuditProtected.
  ///
  /// In en, this message translates to:
  /// **'System logs are append-only and cryptographically secured'**
  String get msgAuditProtected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
