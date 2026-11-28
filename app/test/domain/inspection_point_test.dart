import 'package:flutter_test/flutter_test.dart';
import 'package:afos_app/features/operations/domain/inspection_point.dart';

void main() {
  group('InspectionPoint Domain Tests', () {
    test('creates default standard 8-point checklist', () {
      final checklist = InspectionPoint.createDefaultChecklist();
      expect(checklist.length, 8);
      expect(checklist.map((e) => e.id).toList(), [
        'front_bumper',
        'rear_bumper',
        'left_body',
        'right_body',
        'windshield',
        'tires_wheels',
        'interior_cabin',
        'trunk_spare',
      ]);
      expect(checklist.every((e) => e.condition == InspectionCondition.good), isTrue);
    });

    test('serializes and deserializes inspection point faithfully', () {
      const point = InspectionPoint(
        id: 'front_bumper',
        defaultLabel: 'Bumper Depan',
        condition: InspectionCondition.minorScratch,
        notes: 'Baret tipis sisi kiri bawah',
      );

      final json = point.toJson();
      final parsed = InspectionPoint.fromJson(json);

      expect(parsed.id, point.id);
      expect(parsed.defaultLabel, point.defaultLabel);
      expect(parsed.condition, InspectionCondition.minorScratch);
      expect(parsed.notes, point.notes);
    });
  });
}
