import 'package:flutter_test/flutter_test.dart';
import 'package:afos_app/features/operations/domain/operations_penalty_calculator.dart';

void main() {
  group('OperationsPenaltyCalculator Tests', () {
    const dailyRate = 400000.0;

    test('grants free grace period for late returns within 30 minutes', () {
      final penalty1 = OperationsPenaltyCalculator.calculateOvertimePenalty(
        dailyRate: dailyRate,
        delay: const Duration(minutes: 15),
      );
      final penalty2 = OperationsPenaltyCalculator.calculateOvertimePenalty(
        dailyRate: dailyRate,
        delay: const Duration(minutes: 30),
      );
      expect(penalty1, 0.0);
      expect(penalty2, 0.0);
    });

    test('charges 10% daily rate per hour between 31 and 120 minutes', () {
      // 45 minutes -> 1 hour (10% of 400,000 = 40,000)
      final penalty1 = OperationsPenaltyCalculator.calculateOvertimePenalty(
        dailyRate: dailyRate,
        delay: const Duration(minutes: 45),
      );
      expect(penalty1, 40000.0);

      // 90 minutes -> 2 hours (20% of 400,000 = 80,000)
      final penalty2 = OperationsPenaltyCalculator.calculateOvertimePenalty(
        dailyRate: dailyRate,
        delay: const Duration(minutes: 90),
      );
      expect(penalty2, 80000.0);

      // 120 minutes -> 2 hours = 80,000
      final penalty3 = OperationsPenaltyCalculator.calculateOvertimePenalty(
        dailyRate: dailyRate,
        delay: const Duration(minutes: 120),
      );
      expect(penalty3, 80000.0);
    });

    test('charges full daily rate when late return exceeds 120 minutes', () {
      final penalty = OperationsPenaltyCalculator.calculateOvertimePenalty(
        dailyRate: dailyRate,
        delay: const Duration(minutes: 150),
      );
      expect(penalty, dailyRate);
    });

    test('calculates fuel penalty when fuel is below start level', () {
      // Returned full or equal -> Rp 0
      final penaltyOk = OperationsPenaltyCalculator.calculateFuelPenalty(
        checkoutFuel: 8,
        checkinFuel: 8,
      );
      expect(penaltyOk, 0.0);

      // Returned 6/8 when started 8/8 -> 2 missing bars * 50,000 + 25,000 admin = 125,000
      final penaltyShort = OperationsPenaltyCalculator.calculateFuelPenalty(
        checkoutFuel: 8,
        checkinFuel: 6,
      );
      expect(penaltyShort, 125000.0);
    });

    test('computes delta KM accurately and rejects negative distance', () {
      final delta = OperationsPenaltyCalculator.calculateDeltaKm(
        startKm: 12500,
        endKm: 12750,
      );
      expect(delta, 250);

      expect(
        () => OperationsPenaltyCalculator.calculateDeltaKm(
          startKm: 12500,
          endKm: 12400,
        ),
        throwsArgumentError,
      );
    });
  });
}
