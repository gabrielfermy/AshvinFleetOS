import 'package:flutter/material.dart';

/// Official Brand Suite Color Tokens for Ashvin FleetOS (AFOS)
/// Startup Ashvin — Yogyakarta, Indonesia
class AfosColors {
  // Primary & Brand Identity
  static const Color primaryNavy = Color(0xFF0F2537);   // Ashvin Deep Navy
  static const Color jogjaTeal = Color(0xFF0E7C7B);      // Jogja Teal / Signal Cyan
  static const Color signalCyan = Color(0xFF0E7C7B);     // Alias
  static const Color accentTeal = Color(0xFF0E7C7B);     // Backwards-compatible alias

  // Secondary Accents & Functional
  static const Color warmAmber = Color(0xFFD97706);      // Warm Amber (Alert/Service Near)
  static const Color emeraldVerified = Color(0xFF15803D);// Emerald Verified (Success)
  static const Color successGreen = Color(0xFF15803D);   // Alias
  static const Color crimsonAlert = Color(0xFFB91C1C);   // Crimson Alert (Danger/Damage)
  static const Color alertRed = Color(0xFFB91C1C);       // Alias

  // Surfaces, Canvas & Neutrals
  static const Color slateMist = Color(0xFFF8FAFC);      // Canvas background
  static const Color bgCanvas = Color(0xFFF8FAFC);       // Alias
  static const Color pureWhite = Color(0xFFFFFFFF);      // Card / Dialog surface
  static const Color surfaceCard = Color(0xFFFFFFFF);    // Alias
  static const Color borderSlate = Color(0xFFE2E8F0);    // Card / Divider boundary
  static const Color charcoalInk = Color(0xFF1E293B);    // Primary text & dark elements
  static const Color mutedSlate = Color(0xFF64748B);     // Secondary labels & metadata
  static const Color lightBlue = Color(0xFF0284C7);      // Active rental info
}

/// ThemeExtension for Rental Semantic Status Colors
class AfosStatusColors extends ThemeExtension<AfosStatusColors> {
  final Color available;
  final Color availableBg;
  final Color rented;
  final Color rentedBg;
  final Color maintenanceDue;
  final Color maintenanceDueBg;
  final Color alert;
  final Color alertBg;
  final Color verified;
  final Color verifiedBg;
  final Color warning;
  final Color warningBg;

  const AfosStatusColors({
    required this.available,
    required this.availableBg,
    required this.rented,
    required this.rentedBg,
    required this.maintenanceDue,
    required this.maintenanceDueBg,
    required this.alert,
    required this.alertBg,
    required this.verified,
    required this.verifiedBg,
    required this.warning,
    required this.warningBg,
  });

  static const light = AfosStatusColors(
    available: AfosColors.emeraldVerified,
    availableBg: Color(0xFFDCFCE7),
    rented: Color(0xFF0284C7),
    rentedBg: Color(0xFFE0F2FE),
    maintenanceDue: AfosColors.warmAmber,
    maintenanceDueBg: Color(0xFFFEF3C7),
    alert: AfosColors.crimsonAlert,
    alertBg: Color(0xFFFEE2E2),
    verified: AfosColors.jogjaTeal,
    verifiedBg: Color(0xFFCCFBF1),
    warning: AfosColors.warmAmber,
    warningBg: Color(0xFFFEF3C7),
  );

  static AfosStatusColors of(BuildContext context) {
    return Theme.of(context).extension<AfosStatusColors>() ?? light;
  }

  @override
  ThemeExtension<AfosStatusColors> copyWith({
    Color? available,
    Color? availableBg,
    Color? rented,
    Color? rentedBg,
    Color? maintenanceDue,
    Color? maintenanceDueBg,
    Color? alert,
    Color? alertBg,
    Color? verified,
    Color? verifiedBg,
    Color? warning,
    Color? warningBg,
  }) {
    return AfosStatusColors(
      available: available ?? this.available,
      availableBg: availableBg ?? this.availableBg,
      rented: rented ?? this.rented,
      rentedBg: rentedBg ?? this.rentedBg,
      maintenanceDue: maintenanceDue ?? this.maintenanceDue,
      maintenanceDueBg: maintenanceDueBg ?? this.maintenanceDueBg,
      alert: alert ?? this.alert,
      alertBg: alertBg ?? this.alertBg,
      verified: verified ?? this.verified,
      verifiedBg: verifiedBg ?? this.verifiedBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
    );
  }

  @override
  ThemeExtension<AfosStatusColors> lerp(ThemeExtension<AfosStatusColors>? other, double t) {
    if (other is! AfosStatusColors) return this;
    return AfosStatusColors(
      available: Color.lerp(available, other.available, t)!,
      availableBg: Color.lerp(availableBg, other.availableBg, t)!,
      rented: Color.lerp(rented, other.rented, t)!,
      rentedBg: Color.lerp(rentedBg, other.rentedBg, t)!,
      maintenanceDue: Color.lerp(maintenanceDue, other.maintenanceDue, t)!,
      maintenanceDueBg: Color.lerp(maintenanceDueBg, other.maintenanceDueBg, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
      alertBg: Color.lerp(alertBg, other.alertBg, t)!,
      verified: Color.lerp(verified, other.verified, t)!,
      verifiedBg: Color.lerp(verifiedBg, other.verifiedBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
    );
  }
}
