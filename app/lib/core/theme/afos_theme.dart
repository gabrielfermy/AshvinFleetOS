import 'package:flutter/material.dart';
import 'afos_colors.dart';
import 'afos_typography.dart';

/// Official Brand Suite ThemeData for Ashvin FleetOS (AFOS)
/// High-contrast Light Theme engineered for outdoor field mobility & dense desktop operations
class AfosTheme {
  static ThemeData get lightTheme {
    final textTheme = AfosTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AfosColors.primaryNavy,
        primary: AfosColors.primaryNavy,
        secondary: AfosColors.jogjaTeal,
        tertiary: AfosColors.warmAmber,
        surface: AfosColors.pureWhite,
        surfaceContainerLow: AfosColors.slateMist,
        error: AfosColors.crimsonAlert,
      ),
      scaffoldBackgroundColor: AfosColors.slateMist,
      textTheme: textTheme,
      extensions: const [
        AfosStatusColors.light,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: AfosColors.pureWhite,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AfosColors.primaryNavy),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AfosColors.primaryNavy,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AfosColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AfosColors.borderSlate),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AfosColors.pureWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AfosColors.slateMist,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfosColors.borderSlate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfosColors.borderSlate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfosColors.jogjaTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfosColors.crimsonAlert),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfosColors.crimsonAlert, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AfosColors.mutedSlate),
        hintStyle: textTheme.bodyMedium?.copyWith(color: const Color(0xFF94A3B8)),
        prefixIconColor: AfosColors.mutedSlate,
        suffixIconColor: AfosColors.mutedSlate,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AfosColors.primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AfosColors.jogjaTeal,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AfosColors.slateMist),
        headingTextStyle: textTheme.titleSmall?.copyWith(
          color: AfosColors.primaryNavy,
          fontWeight: FontWeight.w700,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return AfosColors.jogjaTeal.withValues(alpha: 0.06);
          }
          return AfosColors.pureWhite;
        }),
        dataTextStyle: textTheme.bodyMedium,
        dividerThickness: 1,
      ),
    );
  }
}
