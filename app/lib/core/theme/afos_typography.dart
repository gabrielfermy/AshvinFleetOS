import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'afos_colors.dart';

/// Official Brand Suite Typography for Ashvin FleetOS (AFOS)
/// - UI & Headings: Plus Jakarta Sans / Inter
/// - Technical, Audit & Numeric Data: JetBrains Mono with Tabular Figures
class AfosTypography {
  // Standard UI Text Theme
  static TextTheme get textTheme {
    return GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AfosColors.primaryNavy,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AfosColors.primaryNavy,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AfosColors.charcoalInk,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AfosColors.charcoalInk,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AfosColors.charcoalInk,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AfosColors.charcoalInk,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AfosColors.primaryNavy,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AfosColors.mutedSlate,
      ),
    );
  }

  // Technical & Monospace Data Styles (JetBrains Mono + Tabular Figures)
  static TextStyle get licensePlate {
    return GoogleFonts.jetBrainsMono(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: AfosColors.primaryNavy,
    );
  }

  static TextStyle get odometer {
    return GoogleFonts.jetBrainsMono(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: AfosColors.charcoalInk,
    );
  }

  static TextStyle get currency {
    return GoogleFonts.jetBrainsMono(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: AfosColors.jogjaTeal,
    );
  }

  static TextStyle get auditLog {
    return GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: AfosColors.charcoalInk,
    );
  }

  static TextStyle get bookingCode {
    return GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: AfosColors.primaryNavy,
    );
  }
}
