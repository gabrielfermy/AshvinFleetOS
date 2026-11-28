/// Penalty calculation engine according to AFOS Business Rules (Section 7.2)
class OperationsPenaltyCalculator {
  static const double refuelingAdminFee = 25000.0;
  static const double fuelBarPrice = 50000.0; // Estimated cost per 1/8 tank bar

  /// Calculates overtime late return penalty:
  /// - <= 30 min: Rp 0 (Grace period)
  /// - 31 - 120 min: 10% daily rate per hour (rounded up to nearest hour)
  /// - > 120 min: 1 full additional day (100% daily rate)
  static double calculateOvertimePenalty({
    required double dailyRate,
    required Duration delay,
  }) {
    if (delay.isNegative || delay.inMinutes <= 30) {
      return 0.0;
    }

    final totalMinutes = delay.inMinutes;

    if (totalMinutes > 120) {
      return dailyRate; // 1 full day fee
    }

    // 31 - 120 minutes: 10% daily rate per started hour
    final hours = (totalMinutes / 60.0).ceil();
    return hours * (dailyRate * 0.10);
  }

  /// Calculates fuel shortage penalty:
  /// - If checkinFuel < checkoutFuel: missing bars * fuelBarPrice + admin fee
  /// - Otherwise: Rp 0
  static double calculateFuelPenalty({
    required int checkoutFuel,
    required int checkinFuel,
  }) {
    if (checkinFuel >= checkoutFuel) {
      return 0.0;
    }

    final missingBars = checkoutFuel - checkinFuel;
    return (missingBars * fuelBarPrice) + refuelingAdminFee;
  }

  /// Calculates distance traveled (delta KM)
  /// Throws [ArgumentError] if endKm < startKm
  static int calculateDeltaKm({
    required int startKm,
    required int endKm,
  }) {
    if (endKm < startKm) {
      throw ArgumentError('End KM ($endKm) cannot be less than start KM ($startKm)');
    }
    return endKm - startKm;
  }
}
