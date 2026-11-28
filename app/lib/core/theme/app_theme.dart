import 'package:flutter/material.dart';
import 'afos_colors.dart';
import 'afos_theme.dart';
import 'afos_typography.dart';

export 'afos_colors.dart';
export 'afos_theme.dart';
export 'afos_typography.dart';

/// Legacy Theme Delegate for Ashvin FleetOS (AFOS)
/// Forwards to AfosTheme and AfosColors for full backwards-compatibility.
class AppTheme {
  static const Color primaryNavy = AfosColors.primaryNavy;
  static const Color accentTeal = AfosColors.jogjaTeal;
  static const Color bgCanvas = AfosColors.slateMist;
  static const Color surfaceCard = AfosColors.pureWhite;
  static const Color alertRed = AfosColors.crimsonAlert;
  static const Color warningAmber = AfosColors.warmAmber;
  static const Color successGreen = AfosColors.emeraldVerified;

  static ThemeData get lightTheme => AfosTheme.lightTheme;
}
