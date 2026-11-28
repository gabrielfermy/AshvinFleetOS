import 'package:flutter/material.dart';
import '../../../../core/theme/afos_colors.dart';
import '../../domain/inspection_point.dart';

/// Interactive 8-point vehicle body inspection list
class InspectionChecklistWidget extends StatelessWidget {
  final List<InspectionPoint> points;
  final ValueChanged<List<InspectionPoint>> onChanged;

  const InspectionChecklistWidget({
    super.key,
    required this.points,
    required this.onChanged,
  });

  void _updateCondition(int index, InspectionCondition condition) {
    final updated = List<InspectionPoint>.from(points);
    updated[index] = updated[index].copyWith(condition: condition);
    onChanged(updated);
  }

  void _updateNotes(int index, String notes) {
    final updated = List<InspectionPoint>.from(points);
    updated[index] = updated[index].copyWith(notes: notes);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inspeksi Fisik 8 Titik SOP AFOS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AfosColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: points.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final pt = points[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AfosColors.borderSlate),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      pt.defaultLabel,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _conditionChip(index, InspectionCondition.good, 'Baik', AfosColors.emeraldVerified, pt.condition),
                  const SizedBox(width: 4),
                  _conditionChip(index, InspectionCondition.minorScratch, 'Baret', AfosColors.warmAmber, pt.condition),
                  const SizedBox(width: 4),
                  _conditionChip(index, InspectionCondition.damaged, 'Rusak', AfosColors.crimsonAlert, pt.condition),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _conditionChip(
    int index,
    InspectionCondition cond,
    String label,
    Color color,
    InspectionCondition current,
  ) {
    final isSelected = current == cond;
    return InkWell(
      onTap: () => _updateCondition(index, cond),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : AfosColors.borderSlate,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : AfosColors.mutedSlate,
          ),
        ),
      ),
    );
  }
}
